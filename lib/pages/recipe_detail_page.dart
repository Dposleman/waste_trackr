import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_theme.dart';
import '../widgets/app_card.dart';

class RecipeDetailPage extends StatelessWidget {
  const RecipeDetailPage({
    super.key,
    required this.recipe,
    required this.onOpenInCalculator,
    required this.onRecipeDeleted,
  });

  final Map<String, dynamic> recipe;
  final ValueChanged<Map<String, dynamic>> onOpenInCalculator;
  final VoidCallback onRecipeDeleted;

  String _money(String currencyCode, String currencySymbol, dynamic value) {
    final amount = (value as num?)?.toDouble() ?? 0;
    final formatted = amount.toStringAsFixed(2);

    if (currencyCode == 'DKK') {
      return '$currencySymbol $formatted';
    }

    return '$currencySymbol$formatted';
  }

  Future<void> _duplicateRecipe(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final storedRecipes = prefs.getStringList('saved_recipes') ?? [];

    final duplicated = Map<String, dynamic>.from(recipe)
      ..['id'] = DateTime.now().millisecondsSinceEpoch.toString()
      ..['name'] = '${(recipe['name'] ?? 'Untitled recipe')} (Copy)'
      ..['createdAt'] = DateTime.now().toIso8601String();

    storedRecipes.insert(0, jsonEncode(duplicated));
    await prefs.setStringList('saved_recipes', storedRecipes);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recipe duplicated.')),
    );
  }

  Future<void> _deleteRecipe(BuildContext context) async {
    final id = recipe['id'].toString();
    final prefs = await SharedPreferences.getInstance();
    final storedRecipes = prefs.getStringList('saved_recipes') ?? [];

    storedRecipes.removeWhere((item) {
      final decoded = jsonDecode(item) as Map<String, dynamic>;
      return decoded['id'].toString() == id;
    });

    await prefs.setStringList('saved_recipes', storedRecipes);

    onRecipeDeleted();

    if (!context.mounted) return;
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recipe deleted.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = (recipe['name'] ?? 'Untitled recipe').toString();
    final currencyCode = (recipe['currencyCode'] ?? 'USD').toString();
    final currencySymbol = (recipe['currencySymbol'] ?? '\$').toString();
    final servings = (recipe['servings'] ?? 0).toString();
    final sellingPrice = recipe['sellingPricePerDish'];
    final totalCost = recipe['totalCost'];
    final costPerServing = recipe['costPerServing'];
    final foodCostPercent = (recipe['foodCostPercent'] as num?)?.toDouble() ?? 0;
    final ingredients =
        (recipe['ingredients'] as List<dynamic>? ?? const <dynamic>[]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Detail'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Review the full saved costing and reopen it in the calculator.',
            style: TextStyle(
              color: AppTheme.textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RecipeInfoRow(label: 'Currency', value: currencyCode),
                _RecipeInfoRow(label: 'Servings', value: servings),
                _RecipeInfoRow(
                  label: 'Selling price',
                  value: _money(currencyCode, currencySymbol, sellingPrice),
                ),
                _RecipeInfoRow(
                  label: 'Total cost',
                  value: _money(currencyCode, currencySymbol, totalCost),
                ),
                _RecipeInfoRow(
                  label: 'Cost per serving',
                  value: _money(currencyCode, currencySymbol, costPerServing),
                ),
                _RecipeInfoRow(
                  label: 'Food cost %',
                  value: '${foodCostPercent.toStringAsFixed(1)}%',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ingredients',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                if (ingredients.isEmpty)
                  const Text(
                    'No ingredients found.',
                    style: TextStyle(color: AppTheme.textMuted),
                  )
                else
                  ...ingredients.map((item) {
                    final ingredient = Map<String, dynamic>.from(item as Map);
                    final ingredientName =
                        (ingredient['name'] ?? 'Unnamed ingredient').toString();
                    final unit = (ingredient['unit'] ?? '').toString();
                    final quantity =
                        (ingredient['quantity'] as num?)?.toDouble() ?? 0;
                    final unitPrice =
                        (ingredient['unitPrice'] as num?)?.toDouble() ?? 0;
                    final ingredientTotal =
                        (ingredient['totalCost'] as num?)?.toDouble() ?? 0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceAlt,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ingredientName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Quantity: ${quantity.toStringAsFixed(2)} ${unit.isEmpty ? '' : unit}',
                            style: const TextStyle(color: AppTheme.textMuted),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Unit price: ${_money(currencyCode, currencySymbol, unitPrice)}',
                            style: const TextStyle(color: AppTheme.textMuted),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ingredient cost: ${_money(currencyCode, currencySymbol, ingredientTotal)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              onOpenInCalculator(recipe);
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.calculate),
            label: const Text('Open in calculator'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _duplicateRecipe(context),
            icon: const Icon(Icons.copy_outlined),
            label: const Text('Duplicate recipe'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _deleteRecipe(context),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete recipe'),
          ),
        ],
      ),
    );
  }
}

class _RecipeInfoRow extends StatelessWidget {
  const _RecipeInfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textMuted),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}