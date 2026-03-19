import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_theme.dart';
import '../utils/external_links.dart';
import '../widgets/app_card.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({
    super.key,
    this.initialRecipe,
  });

  final Map<String, dynamic>? initialRecipe;

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final TextEditingController _recipeNameController = TextEditingController();
  final TextEditingController _servingsController =
      TextEditingController(text: '1');
  final TextEditingController _sellingPriceController =
      TextEditingController(text: '0');
  final ScrollController _scrollController = ScrollController();

  String _selectedCurrencyCode = 'USD';
  bool _isSaving = false;
  String? _editingRecipeId;
  DateTime? _loadedAt;
  double _scrollOffset = 0;

  final List<_CurrencyOption> _currencies = const [
    _CurrencyOption(code: 'USD', symbol: '\$'),
    _CurrencyOption(code: 'EUR', symbol: '€'),
    _CurrencyOption(code: 'DKK', symbol: 'DKK'),
  ];

  final List<IngredientRowData> _ingredients = [
    IngredientRowData(),
  ];

  final List<TextInputFormatter> _decimalInputFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\s]')),
  ];

  final List<TextInputFormatter> _integerInputFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
  ];

  bool get isEditingExistingRecipe => _editingRecipeId != null;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);

    if (widget.initialRecipe != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadRecipeIntoForm(widget.initialRecipe!);
      });
    }
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
    _recipeNameController.dispose();
    _servingsController.dispose();
    _sellingPriceController.dispose();

    for (final ingredient in _ingredients) {
      ingredient.dispose();
    }

    super.dispose();
  }

  double _parseNumber(String value) {
    final normalized = value.trim().replaceAll(' ', '').replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0;
  }

  int get servings {
    final parsed = _parseNumber(_servingsController.text).toInt();
    return parsed <= 0 ? 0 : parsed;
  }

  double get sellingPricePerDish {
    return _parseNumber(_sellingPriceController.text);
  }

  double get totalCost {
    double total = 0;
    for (final ingredient in _ingredients) {
      total += ingredient.totalCost;
    }
    return total;
  }

  double get costPerServing {
    if (servings == 0) return 0;
    return totalCost / servings;
  }

  double get foodCostPercent {
    if (sellingPricePerDish == 0) return 0;
    return (costPerServing / sellingPricePerDish) * 100;
  }

  double get grossProfitPerDish {
    return sellingPricePerDish - costPerServing;
  }

  _CurrencyOption get selectedCurrency {
    return _currencies.firstWhere(
      (currency) => currency.code == _selectedCurrencyCode,
      orElse: () => _currencies.first,
    );
  }

  String get _currencyPrefix {
    return selectedCurrency.code == 'DKK'
        ? '${selectedCurrency.symbol} '
        : '${selectedCurrency.symbol} ';
  }

  String get _recipeName {
    final value = _recipeNameController.text.trim();
    return value.isEmpty ? 'Untitled recipe' : value;
  }

  String _money(double value) {
    if (selectedCurrency.code == 'DKK') {
      return '${value.toStringAsFixed(2)} ${selectedCurrency.symbol}';
    }
    return '${selectedCurrency.symbol}${value.toStringAsFixed(2)}';
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add(IngredientRowData());
    });
  }

  void _removeIngredient(int index) {
    if (_ingredients.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least one ingredient row must remain.'),
        ),
      );
      return;
    }

    setState(() {
      final ingredient = _ingredients.removeAt(index);
      ingredient.dispose();
    });
  }

  void _loadRecipeIntoForm(Map<String, dynamic> recipe) {
    _recipeNameController.text = (recipe['name'] ?? '').toString();
    _selectedCurrencyCode = (recipe['currencyCode'] ?? 'USD').toString();
    _servingsController.text = (recipe['servings'] ?? 1).toString();
    _sellingPriceController.text =
        (recipe['sellingPricePerDish'] ?? 0).toString();

    _editingRecipeId = recipe['id']?.toString();
    _loadedAt = DateTime.tryParse(
      (recipe['updatedAt'] ?? recipe['createdAt'] ?? '').toString(),
    );

    for (final ingredient in _ingredients) {
      ingredient.dispose();
    }
    _ingredients.clear();

    final ingredients = (recipe['ingredients'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map(IngredientRowData.fromMap)
        .toList();

    _ingredients.addAll(
      ingredients.isEmpty ? [IngredientRowData()] : ingredients,
    );

    setState(() {});
  }

  _FoodCostStatus get foodCostStatus {
    if (foodCostPercent <= 0) {
      return const _FoodCostStatus(
        label: 'Waiting for inputs',
        color: Color(0xFF7C9BFF),
        background: Color(0x147C9BFF),
      );
    }

    if (foodCostPercent <= 28) {
      return const _FoodCostStatus(
        label: 'Healthy margin',
        color: Color(0xFF4FACC1),
        background: Color(0x144FACC1),
      );
    }

    if (foodCostPercent <= 35) {
      return const _FoodCostStatus(
        label: 'Watch closely',
        color: Color(0xFFFACC15),
        background: Color(0x14FACC15),
      );
    }

    return const _FoodCostStatus(
      label: 'Margin risk',
      color: Color(0xFFF87171),
      background: Color(0x14F87171),
    );
  }

  Future<void> _saveRecipe() async {
    FocusScope.of(context).unfocus();

    final validIngredients = _ingredients.where((ingredient) {
      return ingredient.nameController.text.trim().isNotEmpty ||
          ingredient.unitController.text.trim().isNotEmpty ||
          ingredient.unitPrice > 0 ||
          ingredient.quantity > 0;
    }).toList();

    if (validIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one ingredient before saving.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getStringList('saved_recipes') ?? [];

      final recipeId =
          _editingRecipeId ?? DateTime.now().millisecondsSinceEpoch.toString();

      final recipe = {
        'id': recipeId,
        'name': _recipeName,
        'currencyCode': selectedCurrency.code,
        'currencySymbol': selectedCurrency.symbol,
        'servings': servings,
        'sellingPricePerDish': sellingPricePerDish,
        'totalCost': totalCost,
        'costPerServing': costPerServing,
        'foodCostPercent': foodCostPercent,
        'createdAt': (_loadedAt ?? DateTime.now()).toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'ingredients': validIngredients
            .map(
              (ingredient) => {
                'name': ingredient.nameController.text.trim(),
                'unit': ingredient.unitController.text.trim(),
                'unitPrice': ingredient.unitPrice,
                'quantity': ingredient.quantity,
                'totalCost': ingredient.totalCost,
              },
            )
            .toList(),
      };

      final encodedRecipe = jsonEncode(recipe);

      if (_editingRecipeId != null) {
        final index = existing.indexWhere((item) {
          final decoded = jsonDecode(item) as Map<String, dynamic>;
          return decoded['id'].toString() == _editingRecipeId;
        });

        if (index >= 0) {
          existing[index] = encodedRecipe;
        } else {
          existing.insert(0, encodedRecipe);
        }
      } else {
        existing.insert(0, encodedRecipe);
      }

      await prefs.setStringList('saved_recipes', existing);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditingExistingRecipe
                ? 'Recipe updated successfully.'
                : 'Recipe saved successfully.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = foodCostStatus;
    final isWide = MediaQuery.of(context).size.width >= 920;

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        _CalculatorHero(
          isEditing: isEditingExistingRecipe,
          loadedAt: _loadedAt,
          recipeName: _recipeNameController.text.trim(),
          scrollOffset: _scrollOffset,
        ),
        const SizedBox(height: 18),
        _SummaryStrip(
          totalCost: _money(totalCost),
          costPerServing: _money(costPerServing),
          sellingPrice: _money(sellingPricePerDish),
          profitPerDish: _money(grossProfitPerDish),
        ),
        const SizedBox(height: 18),
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 12,
                child: _buildRecipeSetupCard(),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 10,
                child: _buildResultsCard(status),
              ),
            ],
          )
        else ...[
          _buildRecipeSetupCard(),
          const SizedBox(height: 16),
          _buildResultsCard(status),
        ],
        const SizedBox(height: 18),
        _buildIngredientsHeader(),
        const SizedBox(height: 12),
        ...List.generate(_ingredients.length, (index) {
          final ingredient = _ingredients[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _IngredientCard(
              index: index,
              ingredient: ingredient,
              currencyPrefix: _currencyPrefix,
              decimalInputFormatters: _decimalInputFormatters,
              onChanged: () => setState(() {}),
              onDelete: () => _removeIngredient(index),
              moneyFormatter: _money,
            ),
          );
        }),
        const SizedBox(height: 4),
        OutlinedButton.icon(
          onPressed: _addIngredient,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add ingredient'),
        ),
        const SizedBox(height: 18),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Workflow',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 14),
              const _MiniInfoLine(
                icon: Icons.tune_rounded,
                title: 'Set core recipe inputs',
                subtitle: 'Name, currency, servings and selling price.',
              ),
              const SizedBox(height: 12),
              const _MiniInfoLine(
                icon: Icons.inventory_2_outlined,
                title: 'Add each ingredient',
                subtitle: 'Define unit, unit price and quantity used.',
              ),
              const SizedBox(height: 12),
              const _MiniInfoLine(
                icon: Icons.analytics_outlined,
                title: 'Review margin instantly',
                subtitle: 'Track food cost %, cost per portion and profit.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeSetupCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionEyebrow(
            label: 'Recipe setup',
            icon: Icons.edit_note_rounded,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _recipeNameController,
            decoration: const InputDecoration(
              labelText: 'Recipe name',
              hintText: 'Example: Ribeye with pepper sauce',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _selectedCurrencyCode,
            decoration: const InputDecoration(
              labelText: 'Currency',
            ),
            dropdownColor: const Color(0xFF0F182A),
            items: _currencies.map((currency) {
              return DropdownMenuItem<String>(
                value: currency.code,
                child: Text('${currency.code} (${currency.symbol})'),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _selectedCurrencyCode = value;
              });
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _servingsController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: false,
                  ),
                  inputFormatters: _integerInputFormatters,
                  decoration: const InputDecoration(
                    labelText: 'Servings',
                    hintText: '4',
                    helperText: 'Whole portions',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _sellingPriceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: _decimalInputFormatters,
                  decoration: InputDecoration(
                    labelText: 'Selling price',
                    hintText: '18.50',
                    helperText: 'Per dish',
                    prefixText: _currencyPrefix,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsCard(_FoodCostStatus status) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionEyebrow(
            label: 'Results',
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
                  status.background.withOpacity(0.95),
                  Colors.white.withOpacity(0.03),
                ],
              ),
              border: Border.all(
                color: status.color.withOpacity(0.36),
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
                    color: status.color,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  status.label,
                  style: TextStyle(
                    color: status.color,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ResultRow(label: 'Recipe', value: _recipeName),
          _ResultRow(label: 'Currency', value: selectedCurrency.code),
          _ResultRow(label: 'Total cost', value: _money(totalCost)),
          _ResultRow(label: 'Cost per serving', value: _money(costPerServing)),
          _ResultRow(
            label: 'Selling price',
            value: _money(sellingPricePerDish),
          ),
          _ResultRow(
            label: 'Gross profit',
            value: _money(grossProfitPerDish),
            valueColor:
                grossProfitPerDish >= 0 ? const Color(0xFF7DD3FC) : const Color(0xFFF87171),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _saveRecipe,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      isEditingExistingRecipe
                          ? Icons.check_circle_outline
                          : Icons.save_outlined,
                    ),
              label: Text(
                _isSaving
                    ? (isEditingExistingRecipe ? 'Updating...' : 'Saving...')
                    : (isEditingExistingRecipe
                        ? 'Update recipe'
                        : 'Save recipe'),
              ),
            ),
          ),
          const SizedBox(height: 12),
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

  Widget _buildIngredientsHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Ingredients',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: AppTheme.surfaceAlt.withOpacity(0.88),
            border: Border.all(color: AppTheme.border),
          ),
          child: Text(
            '${_ingredients.length} rows',
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class IngredientRowData {
  IngredientRowData({
    String name = '',
    String unit = '',
    String unitPrice = '0',
    String quantity = '0',
  })  : nameController = TextEditingController(text: name),
        unitController = TextEditingController(text: unit),
        unitPriceController = TextEditingController(text: unitPrice),
        quantityController = TextEditingController(text: quantity);

  factory IngredientRowData.fromMap(Map<String, dynamic> map) {
    final unitPrice = (map['unitPrice'] as num?)?.toDouble() ?? 0;
    final quantity = (map['quantity'] as num?)?.toDouble() ?? 0;

    return IngredientRowData(
      name: (map['name'] ?? '').toString(),
      unit: (map['unit'] ?? '').toString(),
      unitPrice: unitPrice == 0 ? '0' : unitPrice.toStringAsFixed(2),
      quantity: quantity == 0 ? '0' : quantity.toString(),
    );
  }

  final TextEditingController nameController;
  final TextEditingController unitController;
  final TextEditingController unitPriceController;
  final TextEditingController quantityController;

  double _parseNumber(String value) {
    final normalized = value.trim().replaceAll(' ', '').replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0;
  }

  double get unitPrice => _parseNumber(unitPriceController.text);

  double get quantity => _parseNumber(quantityController.text);

  double get totalCost => unitPrice * quantity;

  void dispose() {
    nameController.dispose();
    unitController.dispose();
    unitPriceController.dispose();
    quantityController.dispose();
  }
}

class _CurrencyOption {
  final String code;
  final String symbol;

  const _CurrencyOption({
    required this.code,
    required this.symbol,
  });
}

class _FoodCostStatus {
  final String label;
  final Color color;
  final Color background;

  const _FoodCostStatus({
    required this.label,
    required this.color,
    required this.background,
  });
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

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

class _CalculatorHero extends StatelessWidget {
  final bool isEditing;
  final DateTime? loadedAt;
  final String recipeName;
  final double scrollOffset;

  const _CalculatorHero({
    required this.isEditing,
    required this.loadedAt,
    required this.recipeName,
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
              right: -14,
              top: -20 + parallax,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.12,
                  child: Container(
                    width: 132,
                    height: 132,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF3B82F6).withOpacity(0.22),
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
                        Color(0xFF3B82F6),
                        Color(0xFF22D3EE),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.20),
                        blurRadius: 26,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.calculate_rounded,
                    size: 34,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroTag(
                  label: isEditing ? 'Editing saved recipe' : 'Recipe costing',
                ),
                const SizedBox(height: 16),
                Text(
                  isEditing
                      ? (recipeName.isNotEmpty ? recipeName : 'Edit recipe')
                      : 'Calculator',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isEditing
                      ? 'Update the saved recipe and overwrite the existing version.'
                      : 'Build a clean costing calculation with sharper pricing visibility and a premium UnderStack-style workflow.',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    height: 1.55,
                  ),
                ),
                if (loadedAt != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    'Loaded recipe • ${_formatLoadedAt(loadedAt!)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.72),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatLoadedAt(DateTime value) {
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    final y = value.year.toString();
    final h = value.hour.toString().padLeft(2, '0');
    final min = value.minute.toString().padLeft(2, '0');
    return '$d/$m/$y · $h:$min';
  }
}

class _HeroTag extends StatelessWidget {
  final String label;

  const _HeroTag({required this.label});

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

class _SummaryStrip extends StatelessWidget {
  final String totalCost;
  final String costPerServing;
  final String sellingPrice;
  final String profitPerDish;

  const _SummaryStrip({
    required this.totalCost,
    required this.costPerServing,
    required this.sellingPrice,
    required this.profitPerDish,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;

        final children = [
          _SummaryPill(
            label: 'Total cost',
            value: totalCost,
            icon: Icons.receipt_long_rounded,
          ),
          _SummaryPill(
            label: 'Per serving',
            value: costPerServing,
            icon: Icons.pie_chart_outline_rounded,
          ),
          _SummaryPill(
            label: 'Selling price',
            value: sellingPrice,
            icon: Icons.sell_outlined,
          ),
          _SummaryPill(
            label: 'Profit',
            value: profitPerDish,
            icon: Icons.trending_up_rounded,
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

class _IngredientCard extends StatelessWidget {
  final int index;
  final IngredientRowData ingredient;
  final String currencyPrefix;
  final List<TextInputFormatter> decimalInputFormatters;
  final VoidCallback onChanged;
  final VoidCallback onDelete;
  final String Function(double) moneyFormatter;

  const _IngredientCard({
    required this.index,
    required this.ingredient,
    required this.currencyPrefix,
    required this.decimalInputFormatters,
    required this.onChanged,
    required this.onDelete,
    required this.moneyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 760;

    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white.withOpacity(0.04),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Ingredient ${index + 1}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: ingredient.nameController,
            decoration: const InputDecoration(
              labelText: 'Ingredient name',
              hintText: 'Example: Beef',
            ),
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 12),
          if (isWide)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ingredient.unitController,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      hintText: 'kg, g, l, ml, pcs',
                    ),
                    onChanged: (_) => onChanged(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: ingredient.unitPriceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: decimalInputFormatters,
                    decoration: InputDecoration(
                      labelText: 'Unit price',
                      hintText: '12.50',
                      helperText: 'For 1 unit',
                      prefixText: currencyPrefix,
                    ),
                    onChanged: (_) => onChanged(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: ingredient.quantityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: decimalInputFormatters,
                    decoration: const InputDecoration(
                      labelText: 'Quantity used',
                      hintText: '0.25',
                      helperText: 'Amount used',
                    ),
                    onChanged: (_) => onChanged(),
                  ),
                ),
              ],
            )
          else ...[
            TextField(
              controller: ingredient.unitController,
              decoration: const InputDecoration(
                labelText: 'Unit',
                hintText: 'kg, g, l, ml, pcs',
              ),
              onChanged: (_) => onChanged(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ingredient.unitPriceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: decimalInputFormatters,
              decoration: InputDecoration(
                labelText: 'Unit price',
                hintText: '12.50',
                helperText: 'For 1 unit',
                prefixText: currencyPrefix,
              ),
              onChanged: (_) => onChanged(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ingredient.quantityController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: decimalInputFormatters,
              decoration: const InputDecoration(
                labelText: 'Quantity used',
                hintText: '0.25',
                helperText: 'Amount used',
              ),
              onChanged: (_) => onChanged(),
            ),
          ],
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.surfaceAlt.withOpacity(0.98),
                  Colors.white.withOpacity(0.02),
                ],
              ),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Ingredient cost',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  moneyFormatter(ingredient.totalCost),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
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

class _MiniInfoLine extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MiniInfoLine({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white.withOpacity(0.04),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white.withOpacity(0.92),
            size: 19,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}