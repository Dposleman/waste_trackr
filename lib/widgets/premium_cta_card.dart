import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../utils/external_links.dart';
import 'app_card.dart';

class PremiumCtaCard extends StatelessWidget {
  const PremiumCtaCard({
    super.key,
    required this.title,
    required this.description,
    this.compact = false,
    this.showSecondary = true,
  });

  final String title;
  final String description;
  final bool compact;
  final bool showSecondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: EdgeInsets.all(compact ? 18 : 22),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.violet.withValues(alpha: 0.14),
              AppTheme.cyan.withValues(alpha: 0.10),
              Colors.white.withValues(alpha: 0.03),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.10),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(compact ? 16 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _MiniTag(label: 'Premium upgrade'),
                  _MiniTag(label: 'GastroApp'),
                  _MiniTag(label: 'UnderStack ecosystem'),
                ],
              ),
              SizedBox(height: compact ? 14 : 16),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMuted,
                  height: 1.45,
                ),
              ),
              SizedBox(height: compact ? 16 : 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white.withValues(alpha: 0.04),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _FeatureRow(
                      icon: Icons.analytics_outlined,
                      text:
                          'Track waste trends across service, station and category',
                    ),
                    SizedBox(height: 10),
                    _FeatureRow(
                      icon: Icons.auto_awesome_outlined,
                      text:
                          'Move from raw waste logs to operational restaurant intelligence',
                    ),
                    SizedBox(height: 10),
                    _FeatureRow(
                      icon: Icons.storefront_outlined,
                      text:
                          'Built for kitchens that outgrow simple local-only utility tools',
                    ),
                  ],
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
                      'Explore GastroApp',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  if (showSecondary)
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
                        'View UnderStack',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSoft,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.cyan,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSoft,
                  height: 1.4,
                ),
          ),
        ),
      ],
    );
  }
}