import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/waste_entry.dart';
import '../services/waste_storage_service.dart';
import '../widgets/app_card.dart';

class HistoryPage extends StatefulWidget {
  final VoidCallback? onDataChanged;
  final int refreshToken;

  const HistoryPage({
    super.key,
    this.onDataChanged,
    required this.refreshToken,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<WasteEntry>> _entriesFuture;
  final TextEditingController _searchController = TextEditingController();

  String _selectedReason = 'All';
  String _selectedSort = 'Newest';
  String _selectedDateRange = 'All time';

  static const List<String> _sortOptions = [
    'Newest',
    'Oldest',
    'Highest loss',
    'Lowest loss',
  ];

  static const List<String> _reasonOptions = [
    'All',
    'Spoilage',
    'Overproduction',
    'Prep waste',
    'Expired',
    'Burnt',
    'Returned by customer',
    'Staff mistake',
    'Other',
  ];

  static const List<String> _dateRangeOptions = [
    'All time',
    'Today',
    'This week',
    'This month',
  ];

  static const List<String> _units = [
    'kg',
    'g',
    'l',
    'ml',
    'pcs',
    'portions',
  ];

  @override
  void initState() {
    super.initState();
    _entriesFuture = WasteStorageService.getEntries();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(covariant HistoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _entriesFuture = WasteStorageService.getEntries();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final freshEntries = await WasteStorageService.getEntries();
    if (!mounted) return;

    setState(() {
      _entriesFuture = Future.value(freshEntries);
    });
  }

  Future<void> _deleteEntry(WasteEntry entry) async {
    await WasteStorageService.deleteEntry(entry.id);

    if (!mounted) return;

    widget.onDataChanged?.call();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted ${entry.itemName}.'),
      ),
    );

    await _refresh();
  }

  Future<void> _editEntry(WasteEntry entry) async {
    final itemController = TextEditingController(text: entry.itemName);
    final categoryController = TextEditingController(text: entry.category);
    final quantityController =
        TextEditingController(text: entry.quantity.toString());
    final unitCostController =
        TextEditingController(text: entry.unitCost.toString());
    final noteController = TextEditingController(text: entry.note ?? '');

    String selectedUnit = entry.unit;
    String selectedReason = entry.reason;
    DateTime selectedDate = entry.date;

    final formKey = GlobalKey<FormState>();

    final updatedEntry = await showModalBottomSheet<WasteEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickDate() async {
              final result = await showDatePicker(
                context: context,
                initialDate: selectedDate,
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
                setModalState(() => selectedDate = result);
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: AppCard(
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit entry',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: itemController,
                          decoration: const InputDecoration(
                            labelText: 'Item name',
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
                          controller: categoryController,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: quantityController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
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
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: selectedUnit,
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
                                    setModalState(() => selectedUnit = value);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: unitCostController,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Unit cost',
                            prefixText: '€ ',
                          ),
                          validator: (value) {
                            final parsed = double.tryParse(value ?? '');
                            if (parsed == null || parsed < 0) {
                              return 'Invalid cost';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          initialValue: selectedReason,
                          decoration: const InputDecoration(
                            labelText: 'Waste reason',
                          ),
                          items: _reasonOptions
                              .where((reason) => reason != 'All')
                              .map(
                                (reason) => DropdownMenuItem<String>(
                                  value: reason,
                                  child: Text(reason),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setModalState(() => selectedReason = value);
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        InkWell(
                          onTap: pickDate,
                          borderRadius: BorderRadius.circular(18),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date',
                            ),
                            child: Text(
                              '${selectedDate.day.toString().padLeft(2, '0')}/'
                              '${selectedDate.month.toString().padLeft(2, '0')}/'
                              '${selectedDate.year}',
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: noteController,
                          minLines: 3,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Note',
                          ),
                        ),
                        const SizedBox(height: 18),
                        FilledButton(
                          onPressed: () {
                            if (!formKey.currentState!.validate()) return;

                            final quantity =
                                double.tryParse(quantityController.text) ?? 0;
                            final unitCost =
                                double.tryParse(unitCostController.text) ?? 0;

                            Navigator.of(context).pop(
                              WasteEntry(
                                id: entry.id,
                                itemName: itemController.text.trim(),
                                category: categoryController.text.trim(),
                                quantity: quantity,
                                unit: selectedUnit,
                                unitCost: unitCost,
                                reason: selectedReason,
                                date: DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                ),
                                note: noteController.text.trim().isEmpty
                                    ? null
                                    : noteController.text.trim(),
                                createdAt: entry.createdAt,
                              ),
                            );
                          },
                          child: const Text('Save changes'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    itemController.dispose();
    categoryController.dispose();
    quantityController.dispose();
    unitCostController.dispose();
    noteController.dispose();

    if (updatedEntry == null) return;

    await WasteStorageService.updateEntry(updatedEntry);

    if (!mounted) return;

    widget.onDataChanged?.call();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Updated ${updatedEntry.itemName}.'),
      ),
    );

    await _refresh();
  }

  bool _matchesDateRange(WasteEntry entry) {
    if (_selectedDateRange == 'All time') return true;

    final now = DateTime.now();
    final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
    final today = DateTime(now.year, now.month, now.day);

    switch (_selectedDateRange) {
      case 'Today':
        return entryDate == today;
      case 'This week':
        final startOfWeek = today.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 7));
        return !entryDate.isBefore(startOfWeek) && entryDate.isBefore(endOfWeek);
      case 'This month':
        return entryDate.year == now.year && entryDate.month == now.month;
      default:
        return true;
    }
  }

  List<WasteEntry> _applyFilters(List<WasteEntry> entries) {
    final query = _searchController.text.trim().toLowerCase();

    var filtered = entries.where((entry) {
      final matchesQuery = query.isEmpty ||
          entry.itemName.toLowerCase().contains(query) ||
          entry.category.toLowerCase().contains(query) ||
          entry.reason.toLowerCase().contains(query) ||
          (entry.note?.toLowerCase().contains(query) ?? false);

      final matchesReason =
          _selectedReason == 'All' || entry.reason == _selectedReason;

      final matchesDate = _matchesDateRange(entry);

      return matchesQuery && matchesReason && matchesDate;
    }).toList();

    switch (_selectedSort) {
      case 'Oldest':
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'Highest loss':
        filtered.sort((a, b) => b.totalLoss.compareTo(a.totalLoss));
        break;
      case 'Lowest loss':
        filtered.sort((a, b) => a.totalLoss.compareTo(b.totalLoss));
        break;
      case 'Newest':
      default:
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
    }

    return filtered;
  }

  double _totalLoss(List<WasteEntry> entries) {
    return entries.fold<double>(0.0, (sum, entry) => sum + entry.totalLoss);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<WasteEntry>>(
        future: _entriesFuture,
        builder: (context, snapshot) {
          final entries = snapshot.data ?? [];
          final filtered = _applyFilters(entries);
          final total = _totalLoss(filtered);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            children: [
              Text(
                'History',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                'Review saved waste entries, filter them, edit them, and remove records you no longer need.',
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
                      'Filters',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search',
                        hintText: 'Item, category, reason, note...',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedReason,
                            decoration: const InputDecoration(
                              labelText: 'Reason',
                            ),
                            items: _reasonOptions
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
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedSort,
                            decoration: const InputDecoration(
                              labelText: 'Sort',
                            ),
                            items: _sortOptions
                                .map(
                                  (sort) => DropdownMenuItem<String>(
                                    value: sort,
                                    child: Text(sort),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedSort = value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDateRange,
                      decoration: const InputDecoration(
                        labelText: 'Date range',
                      ),
                      items: _dateRangeOptions
                          .map(
                            (range) => DropdownMenuItem<String>(
                              value: range,
                              child: Text(range),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedDateRange = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AppCard(
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryStat(
                        label: 'Entries',
                        value: '${filtered.length}',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SummaryStat(
                        label: 'Visible loss',
                        value: '€ ${total.toStringAsFixed(2)}',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (snapshot.connectionState == ConnectionState.waiting)
                const AppCard(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              else if (filtered.isEmpty)
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No matching entries',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        entries.isEmpty
                            ? 'Save your first waste entry to populate history.'
                            : 'Try changing the filters or search query.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...filtered.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _HistoryEntryCard(
                      entry: entry,
                      onDelete: () => _deleteEntry(entry),
                      onEdit: () => _editEntry(entry),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textMuted,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }
}

class _HistoryEntryCard extends StatelessWidget {
  final WasteEntry entry;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _HistoryEntryCard({
    required this.entry,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.itemName,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              Text(
                '€ ${entry.totalLoss.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.cyan,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(text: entry.category.isEmpty ? 'Uncategorized' : entry.category),
              _Chip(text: entry.reason),
              _Chip(text: '${entry.quantity.toStringAsFixed(2)} ${entry.unit}'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Unit cost: € ${entry.unitCost.toStringAsFixed(2)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _formatDate(entry.date),
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSoft,
            ),
          ),
          if ((entry.note ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              entry.note!,
              style: theme.textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _Chip extends StatelessWidget {
  final String text;

  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textPrimary,
            ),
      ),
    );
  }
}