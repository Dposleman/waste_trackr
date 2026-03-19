import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../utils/external_links.dart';
import '../widgets/app_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        const _SettingsHero(),
        const SizedBox(height: 18),
        const AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'App',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 14),
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
                'Product ecosystem',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Food Cost Calculator is a focused utility. GastroApp expands into broader restaurant operations, workflow visibility and kitchen management.',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: ExternalLinks.openGastroApp,
                child: const Text('Explore GastroApp'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: ExternalLinks.openUnderStack,
                child: const Text('Visit UnderStack'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsHero extends StatefulWidget {
  const _SettingsHero();

  @override
  State<_SettingsHero> createState() => _SettingsHeroState();
}

class _SettingsHeroState extends State<_SettingsHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      child: SizedBox(
        height: 178,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = Curves.easeInOut.transform(_controller.value);
            final logoOpacity = 0.07 + (t * 0.05);
            final glowOpacity = 0.10 + (t * 0.08);
            final scale = 0.985 + (t * 0.025);

            return Stack(
              children: [
                Positioned(
                  top: -14,
                  right: -8,
                  child: IgnorePointer(
                    child: Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: logoOpacity,
                        child: Image.asset(
                          'assets/images/understack_logo.png',
                          width: 142,
                          height: 142,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 4,
                  child: IgnorePointer(
                    child: Transform.scale(
                      scale: 0.96 + (t * 0.06),
                      child: Container(
                        width: 124,
                        height: 124,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF3B82F6).withOpacity(glowOpacity),
                              const Color(0xFF22D3EE)
                                  .withOpacity(glowOpacity * 0.58),
                              const Color(0xFF7C3AED)
                                  .withOpacity(glowOpacity * 0.24),
                              Colors.transparent,
                            ],
                            stops: const [0, 0.38, 0.68, 1],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 245,
                      child: Text(
                        'Basic app configuration, product links and a subtle bridge into the UnderStack ecosystem.',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          height: 1.55,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
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
              style: const TextStyle(
                color: AppTheme.textMuted,
              ),
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