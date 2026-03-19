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
        AppCard(
          child: Column(
            children: [
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
              TextField(
                controller: _servingsController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: false,
                ),
                inputFormatters: _integerInputFormatters,
                decoration: const InputDecoration(
                  labelText: 'Servings',
                  hintText: 'Example: 4',
                  helperText: 'Whole number of portions produced',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _sellingPriceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: _decimalInputFormatters,
                decoration: InputDecoration(
                  labelText: 'Selling price per dish',
                  hintText: 'Example: 18.50 or 18,50',
                  helperText: 'Accepts dot or comma decimals',
                  prefixText: _currencyPrefix,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Ingredients',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
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
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(_ingredients.length, (index) {
          final ingredient = _ingredients[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Ingredient ${index + 1}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _removeIngredient(index),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: ingredient.nameController,
                    decoration: const InputDecoration(
                      labelText: 'Ingredient name',
                      hintText: 'Example: Beef',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: ingredient.unitController,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      hintText: 'kg, g, l, ml, pcs',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: ingredient.unitPriceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: _decimalInputFormatters,
                    decoration: InputDecoration(
                      labelText: 'Unit price',
                      hintText: 'Example: 12.50 or 12,50',
                      helperText: 'Price for 1 full unit',
                      prefixText: _currencyPrefix,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: ingredient.quantityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: _decimalInputFormatters,
                    decoration: const InputDecoration(
                      labelText: 'Quantity used',
                      hintText: 'Example: 0.25 or 0,25',
                      helperText: 'Used amount in the selected unit',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceAlt,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Text(
                      'Ingredient cost: ${_money(ingredient.totalCost)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 4),
        OutlinedButton.icon(
          onPressed: _addIngredient,
          icon: const Icon(Icons.add),
          label: const Text('Add ingredient'),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _ResultRow(label: 'Recipe', value: _recipeName),
              _ResultRow(label: 'Currency', value: selectedCurrency.code),
              _ResultRow(label: 'Total cost', value: _money(totalCost)),
              _ResultRow(
                label: 'Cost per serving',
                value: _money(costPerServing),
              ),
              _ResultRow(
                label: 'Selling price',
                value: _money(sellingPricePerDish),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: status.background,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: status.color.withOpacity(0.45),
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
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${foodCostPercent.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: status.color,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      status.label,
                      style: TextStyle(
                        color: status.color,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
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
                child: OutlinedButton(
                  onPressed: ExternalLinks.openGastroApp,
                  child: const Text('Upgrade to GastroApp'),
                ),
              ),
            ],
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
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
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
              fontWeight: FontWeight.w800,
              fontSize: 15,
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
        height: 198,
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
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
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
                      : 'Build a quick recipe costing calculation with clean pricing visibility and a sharper UnderStack-style flow.',
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