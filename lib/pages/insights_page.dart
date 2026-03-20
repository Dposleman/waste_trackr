import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/waste_entry.dart';
import '../services/waste_storage_service.dart';
import '../widgets/app_card.dart';

class InsightsPage extends StatefulWidget {
  final int refreshToken;

  const InsightsPage({
    super.key,
    required this.refreshToken,
  });

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  late Future<List<WasteEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _entriesFuture = WasteStorageService.getEntries();
  }

  @override
  void didUpdateWidget(covariant InsightsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _entriesFuture = WasteStorageService.getEntries();
    }
  }

  Future<void> _refresh() async {
    final freshEntries = await WasteStorageService.getEntries();
    if (!mounted) return;

    setState(() {
      _entriesFuture = Future.value(freshEntries);
    });
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
          final totalLoss = _totalLoss(entries);
          final avgLoss = entries.isEmpty ? 0.0 : totalLoss / entries.length;
          final topCategory = _topCategory(entries);
          final topReason = _topReason(entries);
          final topItem = _topItem(entries);
          final categoryBreakdown = _groupLossByCategory(entries);
          final reasonBreakdown = _groupCountByReason(entries);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            children: [
              Text(
                'Insights',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                'See where waste is happening, what causes it most often, and where the highest losses come from.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 24),
              if (snapshot.connectionState == ConnectionState.waiting)
                const AppCard(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              else if (entries.isEmpty)
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No insights yet',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Add a few waste entries first. Once data exists, this page will show real waste patterns.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                _InsightStatsGrid(
                  totalLoss: totalLoss,
                  avgLoss: avgLoss,
                  topCategory: topCategory,
                  topReason: topReason,
                ),
                const SizedBox(height: 18),
                _HeadlineCard(
                  title: 'Top loss item',
                  value: topItem,
                  subtitle: 'Highest accumulated euro loss',
                ),
                const SizedBox(height: 18),
                _BreakdownCard(
                  title: 'Loss by category',
                  items: categoryBreakdown
                      .map(
                        (entry) => _BreakdownRowData(
                          label: entry.key,
                          value: '€ ${entry.value.toStringAsFixed(2)}',
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 18),
                _BreakdownCard(
                  title: 'Frequency by reason',
                  items: reasonBreakdown
                      .map(
                        (entry) => _BreakdownRowData(
                          label: entry.key,
                          value: '${entry.value}',
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  double _totalLoss(List<WasteEntry> entries) {
    return entries.fold<double>(0.0, (sum, entry) => sum + entry.totalLoss);
  }

  String _topCategory(List<WasteEntry> entries) {
    if (entries.isEmpty) return '—';

    final totals = <String, double>{};
    for (final entry in entries) {
      final key = entry.category.trim().isEmpty ? 'Uncategorized' : entry.category;
      totals[key] = (totals[key] ?? 0) + entry.totalLoss;
    }

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.first.key;
  }

  String _topReason(List<WasteEntry> entries) {
    if (entries.isEmpty) return '—';

    final counts = <String, int>{};
    for (final entry in entries) {
      counts[entry.reason] = (counts[entry.reason] ?? 0) + 1;
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.first.key;
  }

  String _topItem(List<WasteEntry> entries) {
    if (entries.isEmpty) return '—';

    final totals = <String, double>{};
    for (final entry in entries) {
      totals[entry.itemName] = (totals[entry.itemName] ?? 0) + entry.totalLoss;
    }

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.first.key;
  }

  List<MapEntry<String, double>> _groupLossByCategory(List<WasteEntry> entries) {
    final totals = <String, double>{};

    for (final entry in entries) {
      final key = entry.category.trim().isEmpty ? 'Uncategorized' : entry.category;
      totals[key] = (totals[key] ?? 0) + entry.totalLoss;
    }

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(6).toList();
  }

  List<MapEntry<String, int>> _groupCountByReason(List<WasteEntry> entries) {
    final counts = <String, int>{};

    for (final entry in entries) {
      counts[entry.reason] = (counts[entry.reason] ?? 0) + 1;
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(6).toList();
  }
}

class _InsightStatsGrid extends StatelessWidget {
  final double totalLoss;
  final double avgLoss;
  final String topCategory;
  final String topReason;

  const _InsightStatsGrid({
    required this.totalLoss,
    required this.avgLoss,
    required this.topCategory,
    required this.topReason,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total loss',
                value: '€ ${totalLoss.toStringAsFixed(2)}',
                subtitle: 'All saved entries',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Avg / entry',
                value: '€ ${avgLoss.toStringAsFixed(2)}',
                subtitle: 'Average loss',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Top category',
                value: topCategory,
                subtitle: 'Highest loss category',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Top reason',
                value: topReason,
                subtitle: 'Most frequent reason',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: SizedBox(
        height: 132,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSoft,
                  ),
            ),
            const Spacer(),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeadlineCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _HeadlineCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.cyan,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMuted,
                ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  final String title;
  final List<_BreakdownRowData> items;

  const _BreakdownCard({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BreakdownRow(item: item),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownRowData {
  final String label;
  final String value;

  const _BreakdownRowData({
    required this.label,
    required this.value,
  });
}

class _BreakdownRow extends StatelessWidget {
  final _BreakdownRowData item;

  const _BreakdownRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            item.label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          item.value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.cyan,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}