import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../utils/external_links.dart';
import '../widgets/app_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final next = _scrollController.hasClients ? _scrollController.offset : 0.0;
    if ((next - _scrollOffset).abs() > 1) {
      setState(() {
        _scrollOffset = next;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 126),
      children: [
        _SettingsHero(scrollOffset: _scrollOffset),
        const SizedBox(height: 18),
        const _SettingsSummaryStrip(),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 920;

            if (wide) {
              return const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 11,
                    child: _AboutAppCard(),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 9,
                    child: _ProductDirectionCard(),
                  ),
                ],
              );
            }

            return const Column(
              children: [
                _AboutAppCard(),
                SizedBox(height: 16),
                _ProductDirectionCard(),
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 920;

            if (wide) {
              return const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 10,
                    child: _SupportCard(),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 10,
                    child: _UpgradeCard(),
                  ),
                ],
              );
            }

            return const Column(
              children: [
                _SupportCard(),
                SizedBox(height: 16),
                _UpgradeCard(),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SettingsHero extends StatelessWidget {
  final double scrollOffset;

  const _SettingsHero({
    required this.scrollOffset,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 640;
    final parallax = math.min(scrollOffset * 0.18, 18.0);

    return AppCard(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            top: -18 + parallax,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.12,
                child: Container(
                  width: 138,
                  height: 138,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF7B61FF).withOpacity(0.24),
                        const Color(0xFF53D4FF).withOpacity(0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 18 + (parallax * 0.55),
            child: IgnorePointer(
              child: Container(
                width: isCompact ? 64 : 76,
                height: isCompact ? 64 : 76,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF7B61FF),
                      Color(0xFF53D4FF),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7B61FF).withOpacity(0.24),
                      blurRadius: 26,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.settings_rounded,
                  size: isCompact ? 30 : 34,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: isCompact ? 276 : 222,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _HeroTag(label: 'App settings'),
                const SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.only(
                    right: isCompact ? 88 : 128,
                  ),
                  child: Text(
                    'Settings, product context and upgrade path.',
                    style: TextStyle(
                      fontSize: isCompact ? 24 : 28,
                      height: 1.10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.7,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.only(
                    right: isCompact ? 18 : 136,
                  ),
                  child: const Text(
                    'This utility app is part of the UnderStack ecosystem and connects naturally to the broader GastroApp direction.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.58,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: const [
                    _HeroChip(
                      icon: Icons.palette_outlined,
                      label: 'Premium UI',
                    ),
                    _HeroChip(
                      icon: Icons.hub_outlined,
                      label: 'UnderStack ecosystem',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.035),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.white.withOpacity(0.92),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSummaryStrip extends StatelessWidget {
  const _SettingsSummaryStrip();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;

        if (compact) {
          return const Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _SummaryPill(
                      label: 'Design',
                      value: 'UnderStack',
                      icon: Icons.blur_on_rounded,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _SummaryPill(
                      label: 'Category',
                      value: 'Utility app',
                      icon: Icons.apps_rounded,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _SummaryPill(
                      label: 'Focus',
                      value: 'Food costing',
                      icon: Icons.calculate_rounded,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _SummaryPill(
                      label: 'Expansion',
                      value: 'GastroApp',
                      icon: Icons.open_in_new_rounded,
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return const Row(
          children: [
            Expanded(
              child: _SummaryPill(
                label: 'Design',
                value: 'UnderStack',
                icon: Icons.blur_on_rounded,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _SummaryPill(
                label: 'Category',
                value: 'Utility app',
                icon: Icons.apps_rounded,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _SummaryPill(
                label: 'Focus',
                value: 'Food costing',
                icon: Icons.calculate_rounded,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _SummaryPill(
                label: 'Expansion',
                value: 'GastroApp',
                icon: Icons.open_in_new_rounded,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primary.withOpacity(0.22),
                  AppTheme.cyan.withOpacity(0.10),
                  AppTheme.violet.withOpacity(0.08),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.10),
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutAppCard extends StatelessWidget {
  const _AboutAppCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionEyebrow(
            label: 'About this app',
            icon: Icons.info_outline_rounded,
          ),
          SizedBox(height: 18),
          _FeatureRow(
            icon: Icons.receipt_long_rounded,
            title: 'Focused utility tool',
            description:
                'Built to solve recipe costing quickly without the complexity of a full restaurant system.',
          ),
          SizedBox(height: 16),
          _FeatureRow(
            icon: Icons.design_services_outlined,
            title: 'UnderStack design language',
            description:
                'Uses the premium dark/glass aesthetic so the product feels more serious and higher-end.',
          ),
          SizedBox(height: 16),
          _FeatureRow(
            icon: Icons.speed_rounded,
            title: 'Fast operational flow',
            description:
                'Designed to let chefs and operators reach costing clarity with minimal friction.',
          ),
        ],
      ),
    );
  }
}

class _ProductDirectionCard extends StatelessWidget {
  const _ProductDirectionCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionEyebrow(
            label: 'Product direction',
            icon: Icons.trending_up_rounded,
          ),
          SizedBox(height: 16),
          _MiniInfoLine(
            icon: Icons.calculate_outlined,
            title: 'Start simple',
            subtitle:
                'Food Cost Calculator covers the narrow, useful costing workflow extremely well.',
          ),
          SizedBox(height: 12),
          _MiniInfoLine(
            icon: Icons.inventory_2_outlined,
            title: 'Expand operationally',
            subtitle:
                'The next layer is inventory, waste, production and broader kitchen control.',
          ),
          SizedBox(height: 12),
          _MiniInfoLine(
            icon: Icons.hub_outlined,
            title: 'Connect to ecosystem',
            subtitle:
                'This app acts as a clean funnel into the broader UnderStack and GastroApp direction.',
          ),
        ],
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionEyebrow(
            label: 'Support & ecosystem',
            icon: Icons.support_agent_rounded,
          ),
          const SizedBox(height: 16),
          const Text(
            'This app is part of a broader product strategy for restaurants and food businesses.',
            style: TextStyle(
              fontSize: 15,
              height: 1.62,
              fontWeight: FontWeight.w500,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: AppTheme.surfaceAlt.withOpacity(0.74),
              border: Border.all(color: AppTheme.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _UpgradeBullet(text: 'Utility apps as acquisition funnel'),
                SizedBox(height: 10),
                _UpgradeBullet(text: 'Premium product presentation'),
                SizedBox(height: 10),
                _UpgradeBullet(text: 'Natural upgrade into SaaS workflow'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: ExternalLinks.openUnderStack,
            icon: Icon(Icons.open_in_new_rounded),
            label: Text('Explore UnderStack'),
          ),
        ],
      ),
    );
  }
}

class _UpgradeCard extends StatelessWidget {
  const _UpgradeCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionEyebrow(
            label: 'Upgrade path',
            icon: Icons.north_east_rounded,
          ),
          const SizedBox(height: 16),
          const Text(
            'Need restaurant-wide stock, waste, planning and broader kitchen operations? Move to GastroApp.',
            style: TextStyle(
              fontSize: 15,
              height: 1.62,
              fontWeight: FontWeight.w500,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: AppTheme.surfaceAlt.withOpacity(0.74),
              border: Border.all(color: AppTheme.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _UpgradeBullet(text: 'Inventory visibility'),
                SizedBox(height: 10),
                _UpgradeBullet(text: 'Waste and production control'),
                SizedBox(height: 10),
                _UpgradeBullet(text: 'Restaurant-wide operational workflows'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _PremiumCtaButton(
            label: 'Explore GastroApp',
            onTap: ExternalLinks.openGastroApp,
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white.withOpacity(0.028),
            border: Border.all(
              color: const Color(0xFF69A8FF).withOpacity(0.24),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF69A8FF).withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: const Color(0xFF69A8FF),
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniInfoLine extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MiniInfoLine({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white.withOpacity(0.04),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white.withOpacity(0.92),
            size: 19,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UpgradeBullet extends StatelessWidget {
  final String text;

  const _UpgradeBullet({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF6AA8FF),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionEyebrow extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SectionEyebrow({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primary.withOpacity(0.22),
                AppTheme.cyan.withOpacity(0.10),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Icon(
            icon,
            size: 18,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _HeroTag extends StatelessWidget {
  final String label;

  const _HeroTag({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: const Color(0xFF0E1F3D).withOpacity(0.92),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withOpacity(0.90),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

class _PremiumCtaButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PremiumCtaButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF73B2FF),
            Color(0xFF5C99F8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF69A8FF).withOpacity(0.28),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}