import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_theme.dart';
import '../widgets/app_card.dart';

class RecipeDetailPage extends StatefulWidget {
  const RecipeDetailPage({
    super.key,
    required this.recipe,
    required this.onOpenInCalculator,
    required this.onRecipeDeleted,
  });

  final Map recipe;
  final ValueChanged<Map<String, dynamic>> onOpenInCalculator;
  final VoidCallback onRecipeDeleted;

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  bool _isProcessing = false;

  Map<String, dynamic> get recipe => Map<String, dynamic>.from(widget.recipe);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final next = _scrollController.hasClients ? _scrollController.offset : 0.0;
    if ((next - _scrollOffset).abs() > 1) {
      setState(() {
        _scrollOffset = next;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _money(String currencyCode, String currencySymbol, dynamic value) {
    final amount = (value as num?)?.toDouble() ?? 0;
    final formatted = amount.toStringAsFixed(2);

    if (currencyCode == 'DKK') {
      return '$formatted $currencySymbol';
    }
    return '$currencySymbol$formatted';
  }

  String _formatDate(dynamic value) {
    final dt = DateTime.tryParse((value ?? '').toString());
    if (dt == null) return '—';

    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y · $h:$min';
  }

  _RecipeHealth get recipeHealth {
    final foodCostPercent = (recipe['foodCostPercent'] as num?)?.toDouble() ?? 0;

    if (foodCostPercent <= 0) {
      return const _RecipeHealth(
        label: 'Waiting for inputs',
        color: Color(0xFF7C9BFF),
        background: Color(0x147C9BFF),
      );
    }

    if (foodCostPercent <= 28) {
      return const _RecipeHealth(
        label: 'Healthy margin',
        color: Color(0xFF4FACC1),
        background: Color(0x144FACC1),
      );
    }

    if (foodCostPercent <= 35) {
      return const _RecipeHealth(
        label: 'Watch closely',
        color: Color(0xFFFACC15),
        background: Color(0x14FACC15),
      );
    }

    return const _RecipeHealth(
      label: 'Margin risk',
      color: Color(0xFFF87171),
      background: Color(0x14F87171),
    );
  }

  Future<void> _duplicateRecipe(BuildContext context) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedRecipes = prefs.getStringList('saved_recipes') ?? [];

      final duplicated = Map<String, dynamic>.from(recipe)
        ..['id'] = DateTime.now().millisecondsSinceEpoch.toString()
        ..['name'] = '${(recipe['name'] ?? 'Untitled recipe')} (Copy)'
        ..['createdAt'] = DateTime.now().toIso8601String()
        ..['updatedAt'] = DateTime.now().toIso8601String();

      storedRecipes.insert(0, jsonEncode(duplicated));
      await prefs.setStringList('saved_recipes', storedRecipes);

      widget.onRecipeDeleted();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe duplicated.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _deleteRecipe(BuildContext context) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final id = recipe['id'].toString();
      final prefs = await SharedPreferences.getInstance();
      final storedRecipes = prefs.getStringList('saved_recipes') ?? [];

      storedRecipes.removeWhere((item) {
        final decoded = jsonDecode(item) as Map;
        return decoded['id'].toString() == id;
      });

      await prefs.setStringList('saved_recipes', storedRecipes);
      widget.onRecipeDeleted();

      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe deleted.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
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
    final ingredients = (recipe['ingredients'] as List? ?? const []);
    final grossProfit =
        ((sellingPrice as num?)?.toDouble() ?? 0) - ((costPerServing as num?)?.toDouble() ?? 0);
    final isWide = MediaQuery.of(context).size.width >= 940;
    final health = recipeHealth;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Recipe Detail'),
      ),
      body: ListView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          _RecipeDetailHero(
            recipeName: name,
            health: health,
            scrollOffset: _scrollOffset,
            updatedAt: recipe['updatedAt'],
          ),
          const SizedBox(height: 18),
          _DetailSummaryStrip(
            servings: servings,
            totalCost: _money(currencyCode, currencySymbol, totalCost),
            costPerServing: _money(currencyCode, currencySymbol, costPerServing),
            sellingPrice: _money(currencyCode, currencySymbol, sellingPrice),
          ),
          const SizedBox(height: 18),
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 11,
                  child: _OverviewCard(
                    currencyCode: currencyCode,
                    createdAt: recipe['createdAt'],
                    updatedAt: recipe['updatedAt'],
                    servings: servings,
                    totalCost: _money(currencyCode, currencySymbol, totalCost),
                    costPerServing:
                        _money(currencyCode, currencySymbol, costPerServing),
                    sellingPrice:
                        _money(currencyCode, currencySymbol, sellingPrice),
                    grossProfit: _money(currencyCode, currencySymbol, grossProfit),
                    foodCostPercent: foodCostPercent,
                    health: health,
                    formatDate: _formatDate,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 9,
                  child: _ActionsCard(
                    isProcessing: _isProcessing,
                    onEdit: () {
                      widget.onOpenInCalculator(recipe);
                      Navigator.of(context).pop();
                    },
                    onDuplicate: () => _duplicateRecipe(context),
                    onDelete: () => _deleteRecipe(context),
                  ),
                ),
              ],
            )
          else ...[
            _OverviewCard(
              currencyCode: currencyCode,
              createdAt: recipe['createdAt'],
              updatedAt: recipe['updatedAt'],
              servings: servings,
              totalCost: _money(currencyCode, currencySymbol, totalCost),
              costPerServing: _money(currencyCode, currencySymbol, costPerServing),
              sellingPrice: _money(currencyCode, currencySymbol, sellingPrice),
              grossProfit: _money(currencyCode, currencySymbol, grossProfit),
              foodCostPercent: foodCostPercent,
              health: health,
              formatDate: _formatDate,
            ),
            const SizedBox(height: 16),
            _ActionsCard(
              isProcessing: _isProcessing,
              onEdit: () {
                widget.onOpenInCalculator(recipe);
                Navigator.of(context).pop();
              },
              onDuplicate: () => _duplicateRecipe(context),
              onDelete: () => _deleteRecipe(context),
            ),
          ],
          const SizedBox(height: 18),
          _IngredientsSection(
            ingredients: ingredients,
            currencyCode: currencyCode,
            currencySymbol: currencySymbol,
            money: _money,
          ),
        ],
      ),
    );
  }
}

class _RecipeDetailHero extends StatelessWidget {
  final String recipeName;
  final _RecipeHealth health;
  final double scrollOffset;
  final dynamic updatedAt;

  const _RecipeDetailHero({
    required this.recipeName,
    required this.health,
    required this.scrollOffset,
    required this.updatedAt,
  });

  String _formatDate(dynamic value) {
    final dt = DateTime.tryParse((value ?? '').toString());
    if (dt == null) return 'Recently saved';

    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y · $h:$min';
  }

  @override
  Widget build(BuildContext context) {
    final parallax = math.min(scrollOffset * 0.18, 18.0);

    return AppCard(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      child: SizedBox(
        height: 214,
        child: Stack(
          children: [
            Positioned(
              right: -18,
              top: -18 + parallax,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.12,
                  child: Container(
                    width: 134,
                    height: 134,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF7B61FF).withOpacity(0.24),
                          const Color(0xFF22D3EE).withOpacity(0.12),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 18 + (parallax * 0.55),
              child: IgnorePointer(
                child: Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF7B61FF),
                        Color(0xFF22D3EE),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7B61FF).withOpacity(0.20),
                        blurRadius: 26,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _HeroTag(label: 'Saved recipe'),
                    const SizedBox(width: 10),
                    _HealthBadge(health: health),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  recipeName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Review the full saved costing, inspect margin health and reopen it in the calculator when needed.',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Updated ${_formatDate(updatedAt)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.72),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSummaryStrip extends StatelessWidget {
  final String servings;
  final String totalCost;
  final String costPerServing;
  final String sellingPrice;

  const _DetailSummaryStrip({
    required this.servings,
    required this.totalCost,
    required this.costPerServing,
    required this.sellingPrice,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;

        final children = [
          _SummaryPill(
            label: 'Servings',
            value: servings,
            icon: Icons.pie_chart_outline_rounded,
          ),
          _SummaryPill(
            label: 'Total cost',
            value: totalCost,
            icon: Icons.receipt_long_rounded,
          ),
          _SummaryPill(
            label: 'Per serving',
            value: costPerServing,
            icon: Icons.analytics_outlined,
          ),
          _SummaryPill(
            label: 'Selling price',
            value: sellingPrice,
            icon: Icons.sell_outlined,
          ),
        ];

        if (compact) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: children[0]),
                  const SizedBox(width: 10),
                  Expanded(child: children[1]),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: children[2]),
                  const SizedBox(width: 10),
                  Expanded(child: children[3]),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: children[0]),
            const SizedBox(width: 10),
            Expanded(child: children[1]),
            const SizedBox(width: 10),
            Expanded(child: children[2]),
            const SizedBox(width: 10),
            Expanded(child: children[3]),
          ],
        );
      },
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primary.withOpacity(0.22),
                  AppTheme.cyan.withOpacity(0.10),
                  AppTheme.violet.withOpacity(0.08),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.10),
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String currencyCode;
  final dynamic createdAt;
  final dynamic updatedAt;
  final String servings;
  final String totalCost;
  final String costPerServing;
  final String sellingPrice;
  final String grossProfit;
  final double foodCostPercent;
  final _RecipeHealth health;
  final String Function(dynamic) formatDate;

  const _OverviewCard({
    required this.currencyCode,
    required this.createdAt,
    required this.updatedAt,
    required this.servings,
    required this.totalCost,
    required this.costPerServing,
    required this.sellingPrice,
    required this.grossProfit,
    required this.foodCostPercent,
    required this.health,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionEyebrow(
            label: 'Overview',
            icon: Icons.auto_graph_rounded,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  health.background.withOpacity(0.95),
                  Colors.white.withOpacity(0.03),
                ],
              ),
              border: Border.all(
                color: health.color.withOpacity(0.36),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Food cost %',
                  style: TextStyle(
                    color: AppTheme.textMuted.withOpacity(0.95),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${foodCostPercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: health.color,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  health.label,
                  style: TextStyle(
                    color: health.color,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'Currency', value: currencyCode),
          _InfoRow(label: 'Servings', value: servings),
          _InfoRow(label: 'Total cost', value: totalCost),
          _InfoRow(label: 'Cost per serving', value: costPerServing),
          _InfoRow(label: 'Selling price', value: sellingPrice),
          _InfoRow(
            label: 'Gross profit',
            value: grossProfit,
            valueColor: grossProfit.startsWith('-')
                ? const Color(0xFFF87171)
                : const Color(0xFF7DD3FC),
          ),
          _InfoRow(label: 'Created', value: formatDate(createdAt)),
          _InfoRow(label: 'Updated', value: formatDate(updatedAt)),
        ],
      ),
    );
  }
}

class _ActionsCard extends StatelessWidget {
  final bool isProcessing;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  const _ActionsCard({
    required this.isProcessing,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionEyebrow(
            label: 'Actions',
            icon: Icons.bolt_rounded,
          ),
          const SizedBox(height: 14),
          const Text(
            'Reopen this recipe in the calculator, duplicate it as a new version, or remove it from your saved library.',
            style: TextStyle(
              color: AppTheme.textMuted,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isProcessing ? null : onEdit,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit recipe'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isProcessing ? null : onDuplicate,
              icon: isProcessing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.copy_outlined),
              label: const Text('Duplicate recipe'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isProcessing ? null : onDelete,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete recipe'),
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientsSection extends StatelessWidget {
  final List ingredients;
  final String currencyCode;
  final String currencySymbol;
  final String Function(String, String, dynamic) money;

  const _IngredientsSection({
    required this.ingredients,
    required this.currencyCode,
    required this.currencySymbol,
    required this.money,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: _SectionEyebrow(
                  label: 'Ingredients',
                  icon: Icons.inventory_2_outlined,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: AppTheme.surfaceAlt.withOpacity(0.88),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(
                  '${ingredients.length} rows',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (ingredients.isEmpty)
            const Text(
              'No ingredients found.',
              style: TextStyle(
                color: AppTheme.textMuted,
              ),
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

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _IngredientTile(
                  name: ingredientName,
                  unit: unit,
                  quantity: quantity,
                  unitPrice: money(currencyCode, currencySymbol, unitPrice),
                  ingredientTotal:
                      money(currencyCode, currencySymbol, ingredientTotal),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _IngredientTile extends StatelessWidget {
  final String name;
  final String unit;
  final double quantity;
  final String unitPrice;
  final String ingredientTotal;

  const _IngredientTile({
    required this.name,
    required this.unit,
    required this.quantity,
    required this.unitPrice,
    required this.ingredientTotal,
  });

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 760;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppTheme.surfaceAlt.withOpacity(0.74),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          if (wide)
            Row(
              children: [
                Expanded(
                  child: _MiniMetric(
                    label: 'Quantity',
                    value:
                        '${quantity.toStringAsFixed(2)}${unit.isEmpty ? '' : ' $unit'}',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniMetric(
                    label: 'Unit price',
                    value: unitPrice,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniMetric(
                    label: 'Ingredient cost',
                    value: ingredientTotal,
                    highlight: true,
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                _MiniMetric(
                  label: 'Quantity',
                  value:
                      '${quantity.toStringAsFixed(2)}${unit.isEmpty ? '' : ' $unit'}',
                ),
                const SizedBox(height: 10),
                _MiniMetric(
                  label: 'Unit price',
                  value: unitPrice,
                ),
                const SizedBox(height: 10),
                _MiniMetric(
                  label: 'Ingredient cost',
                  value: ingredientTotal,
                  highlight: true,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _MiniMetric({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: highlight
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.025),
        border: Border.all(
          color: Colors.white.withOpacity(highlight ? 0.10 : 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: valueColor ?? AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionEyebrow extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SectionEyebrow({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primary.withOpacity(0.22),
                AppTheme.cyan.withOpacity(0.10),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Icon(
            icon,
            size: 18,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _RecipeHealth {
  final String label;
  final Color color;
  final Color background;

  const _RecipeHealth({
    required this.label,
    required this.color,
    required this.background,
  });
}

class _HealthBadge extends StatelessWidget {
  final _RecipeHealth health;

  const _HealthBadge({
    required this.health,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: health.background,
        border: Border.all(
          color: health.color.withOpacity(0.32),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        health.label,
        style: TextStyle(
          color: health.color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _HeroTag extends StatelessWidget {
  final String label;

  const _HeroTag({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: const Color(0xFF0E1F3D).withOpacity(0.92),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withOpacity(0.90),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}