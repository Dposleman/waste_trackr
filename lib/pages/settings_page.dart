import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../widgets/app_card.dart';
import '../utils/external_links.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        const Text(
          'Settings',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Basic app configuration and product links.',
          style: TextStyle(
            color: AppTheme.textMuted,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        const AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'App',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 12),
              _SettingRow(label: 'Version', value: '1.0.0'),
              _SettingRow(label: 'Mode', value: 'MVP local-only'),
              _SettingRow(label: 'Storage', value: 'On-device'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upgrade',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              const Text(
                'Food Cost Calculator is the entry tool. GastroApp is the full restaurant operations system.',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: ExternalLinks.openGastroApp,
                child: const Text('Upgrade to GastroApp'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final String value;

  const _SettingRow({
    required this.label,
    required this.value,
  });

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
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}