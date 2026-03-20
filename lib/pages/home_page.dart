import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/waste_entry.dart';
import '../services/waste_storage_service.dart';
import '../widgets/app_card.dart';

class HomePage extends StatefulWidget {
  final int refreshToken;

  const HomePage({
    super.key,
    required this.refreshToken,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<WasteEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _entriesFuture = WasteStorageService.getEntries();
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _entriesFuture = WasteStorageService.getEntries();
    }
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
          final todayTotal = _calculateTodayTotal(entries);
          final weekTotal = _calculateWeekTotal(entries);
          final topReason = _topReason(entries);
          final topItem = _topItem(entries);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            children: [
              Text(
                'WasteTrackr',
                style: theme.textTheme.headlineLarge,
              ),
              const SizedBox(height: 10),
              Text(
                'Track food waste, reduce losses, and build real kitchen visibility.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 24),
              _HeroCard(entryCount: entries.length),
              const SizedBox(height: 18),
              const _SectionTitle(title: 'Overview'),
              const SizedBox(height: 12),
              _StatsGrid(
                todayTotal: todayTotal,
                weekTotal: weekTotal,
                topReason: topReason,
                topItem: topItem,
              ),
              const SizedBox(height: 18),
              const _SectionTitle(title: 'Latest entries'),
              const SizedBox(height: 12),
              if (snapshot.connectionState == ConnectionState.waiting)
                const _LoadingCard()
              else if (entries.isEmpty)
                const _EmptyStateCard()
              else
                ...entries.take(5).map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _EntryCard(entry: entry),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _refresh() async {
    final freshEntries = await WasteStorageService.getEntries();
    if (!mounted) return;

    setState(() {
      _entriesFuture = Future.value(freshEntries);
    });
  }

  double _calculateTodayTotal(List<WasteEntry> entries) {
    final now = DateTime.now();

    return entries
        .where(
          (entry) =>
              entry.date.year == now.year &&
              entry.date.month == now.month &&
              entry.date.day == now.day,
        )
        .fold(0.0, (sum, entry) => sum + entry.totalLoss);
  }

  double _calculateWeekTotal(List<WasteEntry> entries) {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    return entries
        .where(
          (entry) =>
              !entry.date.isBefore(startOfWeek) && entry.date.isBefore(endOfWeek),
        )
        .fold(0.0, (sum, entry) => sum + entry.totalLoss);
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
}

class _HeroCard extends StatelessWidget {
  final int entryCount;

  const _HeroCard({required this.entryCount});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Waste tracking for real kitchens',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(
            entryCount == 0
                ? 'Start by adding your first waste entry. Once you log data, the dashboard will show real loss metrics.'
                : 'You already have $entryCount waste entr${entryCount == 1 ? 'y' : 'ies'} stored locally.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMuted,
                ),
          ),
          const SizedBox(height: 18),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Tag(label: 'UnderStack UI'),
              _Tag(label: 'Live dashboard'),
              _Tag(label: 'Local storage'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final double todayTotal;
  final double weekTotal;
  final String topReason;
  final String topItem;

  const _StatsGrid({
    required this.todayTotal,
    required this.weekTotal,
    required this.topReason,
    required this.topItem,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Today',
                value: '€ ${todayTotal.toStringAsFixed(2)}',
                subtitle: 'Today loss',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'This week',
                value: '€ ${weekTotal.toStringAsFixed(2)}',
                subtitle: 'Weekly loss',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Top reason',
                value: topReason,
                subtitle: 'Most frequent',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Top item',
                value: topItem,
                subtitle: 'Highest total loss',
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
        height: 128,
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

class _EntryCard extends StatelessWidget {
  final WasteEntry entry;

  const _EntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.itemName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '€ ${entry.totalLoss.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.cyan,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${entry.quantity.toStringAsFixed(2)} ${entry.unit} • ${entry.reason}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMuted,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            _formatDate(entry.date),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSoft,
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

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(),
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
          Text(
            'No entries yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(
            'Go to Add Entry and save your first waste record to start seeing dashboard metrics.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMuted,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;

  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.09),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textPrimary,
            ),
      ),
    );
  }
}