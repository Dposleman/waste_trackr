import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../widgets/app_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            'WasteTrackr product info and current MVP implementation status.',
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
                  'App',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                const _InfoRow(label: 'Product name', value: 'WasteTrackr'),
                const SizedBox(height: 10),
                const _InfoRow(label: 'Version focus', value: 'Waste MVP'),
                const SizedBox(height: 10),
                const _InfoRow(
                  label: 'Core flow',
                  value: 'Log, review and manage waste entries',
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
                  'Current capabilities',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                const _ChecklistItem(text: 'Save waste entries locally'),
                const _ChecklistItem(text: 'See live dashboard totals'),
                const _ChecklistItem(text: 'Review entry history'),
                const _ChecklistItem(text: 'Delete saved entries'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next implementation block',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                const _ChecklistItem(text: 'Edit existing entries'),
                const _ChecklistItem(text: 'Date range filters'),
                const _ChecklistItem(text: 'Category analytics'),
                const _ChecklistItem(text: 'GastroApp funnel CTA'),
                const _ChecklistItem(text: 'Play Store assets and packaging'),
              ],
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

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final String text;

  const _ChecklistItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 9,
            height: 9,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.violet,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}