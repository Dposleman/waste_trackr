import 'dart:convert';
import 'dart:math' as math;

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
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _loadRecipes();
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

  Future<void> _loadRecipes() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final storedRecipes = prefs.getStringList('saved_recipes') ?? [];

    final parsed = storedRecipes
        .map((item) => Map<String, dynamic>.from(jsonDecode(item) as Map))
        .toList();

    parsed.sort((a, b) {
      final aDate = DateTime.tryParse(
        (a['updatedAt'] ?? a['createdAt'] ?? '').toString(),
      );
      final bDate = DateTime.tryParse(
        (b['updatedAt'] ?? b['createdAt'] ?? '').toString(),
      );

      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });

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
      final decoded = jsonDecode(item) as Map;
      return decoded['id'].toString() == id;
    });

    await prefs.setStringList('saved_recipes', storedRecipes);
    await _loadRecipes();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recipe deleted.'),
      ),
    );
  }

  String _money(String currencyCode, String currencySymbol, dynamic value) {
    final amount = (value as num?)?.toDouble() ?? 0;
    final formatted = amount.toStringAsFixed(2);

    if (currencyCode == 'DKK') {
      return '$formatted $currencySymbol';
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

  double _foodCostPercent(Map<String, dynamic> recipe) {
    return (recipe['foodCostPercent'] as num?)?.toDouble() ?? 0;
  }

  int _ingredientCount(Map<String, dynamic> recipe) {
    final items = recipe['ingredients'];
    if (items is List) return items.length;
    return 0;
  }

  String _updatedLabel(Map<String, dynamic> recipe) {
    final raw = (recipe['updatedAt'] ?? recipe['createdAt'] ?? '').toString();
    final dt = DateTime.tryParse(raw);
    if (dt == null) return 'Recently saved';

    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year.toString();
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');

    return 'Updated $day/$month/$year · $hour:$minute';
  }

  _RecipeHealth recipeHealth(Map<String, dynamic> recipe) {
    final percent = _foodCostPercent(recipe);

    if (percent <= 0) {
      return const _RecipeHealth(
        label: 'Waiting',
        color: Color(0xFF7C9BFF),
        background: Color(0x147C9BFF),
      );
    }

    if (percent <= 28) {
      return const _RecipeHealth(
        label: 'Healthy',
        color: Color(0xFF4FACC1),
        background: Color(0x144FACC1),
      );
    }

    if (percent <= 35) {
      return const _RecipeHealth(
        label: 'Watch',
        color: Color(0xFFFACC15),
        background: Color(0x14FACC15),
      );
    }

    return const _RecipeHealth(
      label: 'Risk',
      color: Color(0xFFF87171),
      background: Color(0x14F87171),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 126),
      children: [
        _SavedRecipesHero(
          recipeCount: _recipes.length,
          scrollOffset: _scrollOffset,
        ),
        const SizedBox(height: 18),
        _SavedSummaryStrip(
          isLoading: _isLoading,
          totalRecipes: _recipes.length,
          avgFoodCost: _recipes.isEmpty
              ? 0
              : _recipes
                      .map(_foodCostPercent)
                      .reduce((a, b) => a + b) /
                  _recipes.length,
        ),
        const SizedBox(height: 18),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (_recipes.isEmpty) ...[
          const _EmptyStateCard(),
          const SizedBox(height: 16),
          const _UpgradeCard(),
        ] else ...[
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Saved recipes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
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
                  '${_recipes.length} stored',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._recipes.map((recipe) {
            final name = (recipe['name'] ?? 'Untitled recipe').toString();
            final currencyCode = (recipe['currencyCode'] ?? 'USD').toString();
            final currencySymbol =
                (recipe['currencySymbol'] ?? '\$').toString();
            final totalCost = recipe['totalCost'];
            final costPerServing = recipe['costPerServing'];
            final sellingPrice = recipe['sellingPricePerDish'];
            final servings = recipe['servings']?.toString() ?? '0';
            final id = recipe['id'].toString();
            final health = recipeHealth(recipe);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RecipeCard(
                name: name,
                updatedLabel: _updatedLabel(recipe),
                servings: servings,
                ingredientCount: _ingredientCount(recipe).toString(),
                totalCost: _money(currencyCode, currencySymbol, totalCost),
                costPerServing:
                    _money(currencyCode, currencySymbol, costPerServing),
                sellingPrice:
                    _money(currencyCode, currencySymbol, sellingPrice),
                foodCostPercent:
                    '${_foodCostPercent(recipe).toStringAsFixed(1)}%',
                health: health,
                onTap: () => _openRecipeDetail(recipe),
                onDelete: () => _deleteRecipe(id),
              ),
            );
          }),
          const SizedBox(height: 6),
          const _UpgradeCard(),
        ],
      ],
    );
  }
}

class _SavedRecipesHero extends StatelessWidget {
  final int recipeCount;
  final double scrollOffset;

  const _SavedRecipesHero({
    required this.recipeCount,
    required this.scrollOffset,
  });

  @override
  Widget build(BuildContext context) {
    final parallax = math.min(scrollOffset * 0.18, 18.0);

    return AppCard(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      child: SizedBox(
        height: 208,
        child: Stack(
          children: [
            Positioned(
              right: -16,
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
              right: 6,
              top: 16 + (parallax * 0.55),
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
                        color: const Color(0xFF7B61FF).withOpacity(0.22),
                        blurRadius: 26,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.bookmarks_rounded,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroTag(
                  label: recipeCount == 0
                      ? 'Recipe library'
                      : '$recipeCount saved recipe${recipeCount == 1 ? '' : 's'}',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Saved Recipes',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Review, reopen and manage your saved cost calculations with a cleaner premium library view.',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    height: 1.55,
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

class _SavedSummaryStrip extends StatelessWidget {
  final bool isLoading;
  final int totalRecipes;
  final double avgFoodCost;

  const _SavedSummaryStrip({
    required this.isLoading,
    required this.totalRecipes,
    required this.avgFoodCost,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;

        final cards = [
          _SummaryPill(
            label: 'Recipes',
            value: isLoading ? '...' : '$totalRecipes',
            icon: Icons.bookmark_outline_rounded,
          ),
          _SummaryPill(
            label: 'Average food cost',
            value: isLoading ? '...' : '${avgFoodCost.toStringAsFixed(1)}%',
            icon: Icons.auto_graph_rounded,
          ),
          _SummaryPill(
            label: 'Storage',
            value: 'Local device',
            icon: Icons.phone_iphone_rounded,
          ),
          _SummaryPill(
            label: 'Flow',
            value: 'Detail + edit',
            icon: Icons.open_in_new_rounded,
          ),
        ];

        if (compact) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 10),
                  Expanded(child: cards[1]),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: cards[2]),
                  const SizedBox(width: 10),
                  Expanded(child: cards[3]),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 10),
            Expanded(child: cards[1]),
            const SizedBox(width: 10),
            Expanded(child: cards[2]),
            const SizedBox(width: 10),
            Expanded(child: cards[3]),
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

class _RecipeCard extends StatelessWidget {
  final String name;
  final String updatedLabel;
  final String servings;
  final String ingredientCount;
  final String totalCost;
  final String costPerServing;
  final String sellingPrice;
  final String foodCostPercent;
  final _RecipeHealth health;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _RecipeCard({
    required this.name,
    required this.updatedLabel,
    required this.servings,
    required this.ingredientCount,
    required this.totalCost,
    required this.costPerServing,
    required this.sellingPrice,
    required this.foodCostPercent,
    required this.health,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 780;

    return AppCard(
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        updatedLabel,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _HealthBadge(health: health),
                const SizedBox(width: 6),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (wide)
              Row(
                children: [
                  Expanded(
                    child: _MetricTile(
                      label: 'Servings',
                      value: servings,
                      icon: Icons.pie_chart_outline_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricTile(
                      label: 'Ingredients',
                      value: ingredientCount,
                      icon: Icons.inventory_2_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricTile(
                      label: 'Total cost',
                      value: totalCost,
                      icon: Icons.receipt_long_rounded,
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _MetricTile(
                          label: 'Servings',
                          value: servings,
                          icon: Icons.pie_chart_outline_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MetricTile(
                          label: 'Ingredients',
                          value: ingredientCount,
                          icon: Icons.inventory_2_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _MetricTile(
                    label: 'Total cost',
                    value: totalCost,
                    icon: Icons.receipt_long_rounded,
                    fullWidth: true,
                  ),
                ],
              ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    health.background.withOpacity(0.95),
                    Colors.white.withOpacity(0.03),
                  ],
                ),
                border: Border.all(
                  color: health.color.withOpacity(0.28),
                ),
              ),
              child: wide
                  ? Row(
                      children: [
                        Expanded(
                          child: _InlineResult(
                            label: 'Cost per serving',
                            value: costPerServing,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InlineResult(
                            label: 'Selling price',
                            value: sellingPrice,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InlineResult(
                            label: 'Food cost',
                            value: foodCostPercent,
                            valueColor: health.color,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _InlineResult(
                          label: 'Cost per serving',
                          value: costPerServing,
                        ),
                        const SizedBox(height: 10),
                        _InlineResult(
                          label: 'Selling price',
                          value: sellingPrice,
                        ),
                        const SizedBox(height: 10),
                        _InlineResult(
                          label: 'Food cost',
                          value: foodCostPercent,
                          valueColor: health.color,
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 14),
            Row(
              children: const [
                Icon(
                  Icons.open_in_new_rounded,
                  size: 16,
                  color: AppTheme.textMuted,
                ),
                SizedBox(width: 8),
                Text(
                  'Tap to view details',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w700,
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

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool fullWidth;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppTheme.surfaceAlt.withOpacity(0.72),
        border: Border.all(
          color: AppTheme.border.withOpacity(0.9),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.04),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: Colors.white.withOpacity(0.92),
            ),
          ),
          const SizedBox(width: 10),
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

class _InlineResult extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InlineResult({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: valueColor ?? AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
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

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primary.withOpacity(0.24),
                  AppTheme.cyan.withOpacity(0.12),
                  AppTheme.violet.withOpacity(0.10),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
              ),
            ),
            child: const Icon(
              Icons.bookmark_border_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No saved recipes yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Save a recipe from the Calculator tab and it will appear here in your premium recipe library.',
            style: TextStyle(
              color: AppTheme.textMuted,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpgradeCard extends StatelessWidget {
  const _UpgradeCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upgrade path',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Need restaurant-wide stock, waste and operations control? Move to GastroApp.',
            style: TextStyle(
              color: AppTheme.textMuted,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: ExternalLinks.openGastroApp,
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Upgrade to GastroApp'),
            ),
          ),
        ],
      ),
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