import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../utils/external_links.dart';
import '../widgets/app_card.dart';
import '../widgets/premium_cta_card.dart';

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
            'WasteTrackr product info, ecosystem links and current MVP implementation status.',
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
                const _ChecklistItem(text: 'Edit and delete saved entries'),
                const _ChecklistItem(text: 'Filter analytics by date range'),
                const _ChecklistItem(text: 'Premium UnderStack dark/glass UI'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const PremiumCtaCard(
            title: 'Ready for the premium layer?',
            description:
                'WasteTrackr is designed as a focused utility app. GastroApp is the next step for restaurants that want broader kitchen operations, stronger workflows and a more complete product ecosystem.',
          ),
          const SizedBox(height: 18),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ecosystem links',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                Text(
                  'Open the main platform sites directly from here.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await ExternalLinks.openGastroApp();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.cyan,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Open GastroApp',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        await ExternalLinks.openUnderStack();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.14),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Open UnderStack',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
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
                  'Next release block',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                const _ChecklistItem(text: 'Packaging polish'),
                const _ChecklistItem(text: 'App icon and store screenshots'),
                const _ChecklistItem(text: 'Store listing copy'),
                const _ChecklistItem(text: 'Release configuration'),
                const _ChecklistItem(text: 'Play Store publish flow'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 118,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({
    required this.text,
  });

  final String text;

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
            decoration: const BoxDecoration(
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