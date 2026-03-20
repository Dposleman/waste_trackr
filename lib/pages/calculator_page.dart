import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/waste_entry.dart';
import '../services/waste_storage_service.dart';
import '../widgets/app_card.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _quantityController =
      TextEditingController(text: '1');
  final TextEditingController _unitCostController =
      TextEditingController(text: '0');
  final TextEditingController _noteController = TextEditingController();

  String _selectedUnit = 'kg';
  String _selectedReason = 'Spoilage';
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  static const List<String> _units = [
    'kg',
    'g',
    'l',
    'ml',
    'pcs',
    'portions',
  ];

  static const List<String> _reasons = [
    'Spoilage',
    'Overproduction',
    'Prep waste',
    'Expired',
    'Burnt',
    'Returned by customer',
    'Staff mistake',
    'Other',
  ];

  @override
  void dispose() {
    _itemController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _unitCostController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double get _quantity => double.tryParse(_quantityController.text) ?? 0;
  double get _unitCost => double.tryParse(_unitCostController.text) ?? 0;
  double get _totalLoss => _quantity * _unitCost;

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final entry = WasteEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        itemName: _itemController.text.trim(),
        category: _categoryController.text.trim(),
        quantity: _quantity,
        unit: _selectedUnit,
        unitCost: _unitCost,
        reason: _selectedReason,
        date: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
        ),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        createdAt: DateTime.now(),
      );

      await WasteStorageService.addEntry(entry);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Entry saved: ${entry.itemName} • € ${entry.totalLoss.toStringAsFixed(2)}',
          ),
        ),
      );

      _resetForm();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save waste entry.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _resetForm() {
    _itemController.clear();
    _categoryController.clear();
    _quantityController.text = '1';
    _unitCostController.text = '0';
    _noteController.clear();

    setState(() {
      _selectedUnit = 'kg';
      _selectedReason = 'Spoilage';
      _selectedDate = DateTime.now();
    });
  }

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2032),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      setState(() => _selectedDate = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add waste entry',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Log wasted ingredients, products, and prep losses to measure real kitchen waste in euros.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Entry details',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _itemController,
                    decoration: const InputDecoration(
                      labelText: 'Item name',
                      hintText: 'Tomatoes, fries, salmon...',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter an item name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      hintText: 'Vegetables, meat, dairy...',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _quantityController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Quantity',
                          ),
                          validator: (value) {
                            final parsed = double.tryParse(value ?? '');
                            if (parsed == null || parsed <= 0) {
                              return 'Invalid quantity';
                            }
                            return null;
                          },
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedUnit,
                          decoration: const InputDecoration(
                            labelText: 'Unit',
                          ),
                          items: _units
                              .map(
                                (unit) => DropdownMenuItem<String>(
                                  value: unit,
                                  child: Text(unit),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedUnit = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _unitCostController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Unit cost',
                      hintText: '0.00',
                      prefixText: '€ ',
                    ),
                    validator: (value) {
                      final parsed = double.tryParse(value ?? '');
                      if (parsed == null || parsed < 0) {
                        return 'Invalid cost';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedReason,
                    decoration: const InputDecoration(
                      labelText: 'Waste reason',
                    ),
                    items: _reasons
                        .map(
                          (reason) => DropdownMenuItem<String>(
                            value: reason,
                            child: Text(reason),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedReason = value);
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(18),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                      ),
                      child: Text(
                        '${_selectedDate.day.toString().padLeft(2, '0')}/'
                        '${_selectedDate.month.toString().padLeft(2, '0')}/'
                        '${_selectedDate.year}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _noteController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Note',
                      hintText: 'Optional context for this waste entry...',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Loss preview',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 14),
                  _PreviewRow(
                    label: 'Quantity',
                    value: '${_quantity.toStringAsFixed(2)} $_selectedUnit',
                  ),
                  const SizedBox(height: 10),
                  _PreviewRow(
                    label: 'Unit cost',
                    value: '€ ${_unitCost.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 10),
                  _PreviewRow(
                    label: 'Total loss',
                    value: '€ ${_totalLoss.toStringAsFixed(2)}',
                    emphasize: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: _isSaving ? null : _saveEntry,
              child: Text(_isSaving ? 'Saving...' : 'Save entry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _PreviewRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = emphasize
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMuted,
                ),
          ),
        ),
        Text(
          value,
          style: style?.copyWith(
            color: emphasize ? AppTheme.cyan : AppTheme.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}