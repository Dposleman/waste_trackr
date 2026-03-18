import 'dart:convert';

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

  String _selectedCurrencyCode = 'USD';
  bool _isSaving = false;

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

  @override
  void initState() {
    super.initState();
    if (widget.initialRecipe != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadRecipeIntoForm(widget.initialRecipe!);
      });
    }
  }

  @override
  void dispose() {
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
        ? 'DKK '
        : '${selectedCurrency.symbol}';
  }

  String get _recipeName {
    final value = _recipeNameController.text.trim();
    return value.isEmpty ? 'Untitled recipe' : value;
  }

  void _clearForm() {
    _recipeNameController.text = '';
    _servingsController.text = '1';
    _sellingPriceController.text = '0';
    _selectedCurrencyCode = 'USD';

    for (final ingredient in _ingredients) {
      ingredient.dispose();
    }
    _ingredients
      ..clear()
      ..add(IngredientRowData());
  }

  void _loadRecipeIntoForm(Map<String, dynamic> recipe) {
    final ingredients =
        (recipe['ingredients'] as List<dynamic>? ?? const <dynamic>[]);

    setState(() {
      _clearForm();

      _recipeNameController.text = (recipe['name'] ?? '').toString();
      _selectedCurrencyCode = (recipe['currencyCode'] ?? 'USD').toString();
      _servingsController.text = (recipe['servings'] ?? 1).toString();

      final sellingPrice = (recipe['sellingPricePerDish'] as num?)?.toDouble() ?? 0;
      _sellingPriceController.text = sellingPrice == 0
          ? '0'
          : sellingPrice.toStringAsFixed(2);

      _ingredients.clear();

      if (ingredients.isEmpty) {
        _ingredients.add(IngredientRowData());
      } else {
        for (final item in ingredients) {
          final map = Map<String, dynamic>.from(item as Map);
          _ingredients.add(
            IngredientRowData.fromMap(map),
          );
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recipe loaded into calculator.'),
      ),
    );
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add(IngredientRowData());
    });
  }

  void _removeIngredient(int index) {
    if (_ingredients.length == 1) return;

    setState(() {
      _ingredients[index].dispose();
      _ingredients.removeAt(index);
    });
  }

  String _money(double value) {
    final symbol = selectedCurrency.symbol;
    final formatted = value.toStringAsFixed(2);

    if (selectedCurrency.code == 'DKK') {
      return '$symbol $formatted';
    }

    return '$symbol$formatted';
  }

  _FoodCostStatus get foodCostStatus {
    final value = foodCostPercent;

    if (sellingPricePerDish <= 0 || servings <= 0) {
      return const _FoodCostStatus(
        label: 'Add valid values',
        color: Color(0xFF7C8AA5),
        background: Color(0x142A3342),
      );
    }

    if (value <= 30) {
      return const _FoodCostStatus(
        label: 'Healthy margin',
        color: Color(0xFF4ADE80),
        background: Color(0x1434D399),
      );
    }

    if (value <= 35) {
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

      final recipe = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': _recipeName,
        'currencyCode': selectedCurrency.code,
        'currencySymbol': selectedCurrency.symbol,
        'servings': servings,
        'sellingPricePerDish': sellingPricePerDish,
        'totalCost': totalCost,
        'costPerServing': costPerServing,
        'foodCostPercent': foodCostPercent,
        'createdAt': DateTime.now().toIso8601String(),
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

      existing.insert(0, jsonEncode(recipe));
      await prefs.setStringList('saved_recipes', existing);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe saved successfully.'),
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        const Text(
          'Calculator',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Build a quick recipe costing calculation.',
          style: TextStyle(
            color: AppTheme.textMuted,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
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
        const Text(
          'Ingredients',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
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
                      : const Icon(Icons.save_outlined),
                  label: Text(_isSaving ? 'Saving...' : 'Save recipe'),
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