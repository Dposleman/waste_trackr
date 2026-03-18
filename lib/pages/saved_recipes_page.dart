import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_theme.dart';
import '../utils/external_links.dart';
import '../widgets/app_card.dart';
import 'recipe_detail_page.dart';

class SavedRecipesPage extends StatefulWidget {
  const SavedRecipesPage({
    super.key,
    required this.onOpenInCalculator,
  });

  final ValueChanged<Map<String, dynamic>> onOpenInCalculator;

  @override
  State<SavedRecipesPage> createState() => _SavedRecipesPageState();
}

class _SavedRecipesPageState extends State<SavedRecipesPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _recipes = [];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final storedRecipes = prefs.getStringList('saved_recipes') ?? [];

    final parsed = storedRecipes
        .map((item) => Map<String, dynamic>.from(jsonDecode(item) as Map))
        .toList();

    if (!mounted) return;

    setState(() {
      _recipes = parsed;
      _isLoading = false;
    });
  }

  Future<void> _deleteRecipe(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final storedRecipes = prefs.getStringList('saved_recipes') ?? [];

    storedRecipes.removeWhere((item) {
      final decoded = jsonDecode(item) as Map<String, dynamic>;
      return decoded['id'].toString() == id;
    });

    await prefs.setStringList('saved_recipes', storedRecipes);
    await _loadRecipes();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recipe deleted.')),
    );
  }

  String _money(String currencyCode, String currencySymbol, dynamic value) {
    final amount = (value as num?)?.toDouble() ?? 0;
    final formatted = amount.toStringAsFixed(2);

    if (currencyCode == 'DKK') {
      return '$currencySymbol $formatted';
    }

    return '$currencySymbol$formatted';
  }

  Future<void> _openRecipeDetail(Map<String, dynamic> recipe) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecipeDetailPage(
          recipe: recipe,
          onOpenInCalculator: widget.onOpenInCalculator,
          onRecipeDeleted: _loadRecipes,
        ),
      ),
    );

    await _loadRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        const Text(
          'Saved Recipes',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Stored recipe calculations saved locally on this device.',
          style: TextStyle(
            color: AppTheme.textMuted,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_recipes.isEmpty) ...[
          const AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.bookmark_border,
                  size: 36,
                  color: AppTheme.primary,
                ),
                SizedBox(height: 12),
                Text(
                  'No saved recipes yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Save a recipe from the Calculator tab and it will appear here.',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    height: 1.5,
                  ),
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
                  'Upgrade path',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Need restaurant-wide stock, waste and operations control? Move to GastroApp.',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: ExternalLinks.openGastroApp,
                  child: const Text('Upgrade to GastroApp'),
                ),
              ],
            ),
          ),
        ] else ...[
          ..._recipes.map((recipe) {
            final name = (recipe['name'] ?? 'Untitled recipe').toString();
            final currencyCode = (recipe['currencyCode'] ?? 'USD').toString();
            final currencySymbol = (recipe['currencySymbol'] ?? '\$').toString();
            final totalCost = recipe['totalCost'];
            final costPerServing = recipe['costPerServing'];
            final foodCostPercent =
                (recipe['foodCostPercent'] as num?)?.toDouble() ?? 0;
            final servings = recipe['servings']?.toString() ?? '0';
            final id = recipe['id'].toString();

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _openRecipeDetail(recipe),
                  child: Padding(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _deleteRecipe(id),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _RecipeInfoRow(label: 'Currency', value: currencyCode),
                        _RecipeInfoRow(label: 'Servings', value: servings),
                        _RecipeInfoRow(
                          label: 'Total cost',
                          value: _money(currencyCode, currencySymbol, totalCost),
                        ),
                        _RecipeInfoRow(
                          label: 'Cost per serving',
                          value: _money(
                            currencyCode,
                            currencySymbol,
                            costPerServing,
                          ),
                        ),
                        _RecipeInfoRow(
                          label: 'Food cost %',
                          value: '${foodCostPercent.toStringAsFixed(1)}%',
                        ),
                        const SizedBox(height: 10),
                        const Row(
                          children: [
                            Icon(
                              Icons.open_in_new,
                              size: 16,
                              color: AppTheme.textMuted,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Tap to view details',
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upgrade path',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Need restaurant-wide stock, waste and operations control? Move to GastroApp.',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: ExternalLinks.openGastroApp,
                  child: const Text('Upgrade to GastroApp'),
                ),
              ],
            ),
          ),
        ],
      ],
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
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}