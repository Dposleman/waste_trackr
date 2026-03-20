import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/waste_entry.dart';
import '../services/waste_storage_service.dart';
import '../widgets/app_card.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<WasteEntry>> _entriesFuture;
  final TextEditingController _searchController = TextEditingController();

  String _selectedReason = 'All';
  String _selectedSort = 'Newest';

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

  @override
  void initState() {
    super.initState();
    _entriesFuture = WasteStorageService.getEntries();
    _searchController.addListener(() => setState(() {}));
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted ${entry.itemName}.'),
      ),
    );

    await _refresh();
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

      return matchesQuery && matchesReason;
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
                'Review saved waste entries, filter them, and remove records you no longer need.',
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

  const _HistoryEntryCard({
    required this.entry,
    required this.onDelete,
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
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text('Delete'),
            ),
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