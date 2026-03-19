import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../utils/external_links.dart';
import '../widgets/app_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        _HomeHero(scrollOffset: _scrollOffset),
        const SizedBox(height: 18),
        const _HomeSummaryStrip(),
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
                    child: _WhatItDoesCard(),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 9,
                    child: _WhyItFeelsBetterCard(),
                  ),
                ],
              );
            }

            return const Column(
              children: [
                _WhatItDoesCard(),
                SizedBox(height: 16),
                _WhyItFeelsBetterCard(),
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
                    child: _WorkflowCard(),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 10,
                    child: _UpgradePathCard(),
                  ),
                ],
              );
            }

            return const Column(
              children: [
                _WorkflowCard(),
                SizedBox(height: 16),
                _UpgradePathCard(),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _HomeHero extends StatelessWidget {
  final double scrollOffset;

  const _HomeHero({
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
            right: -18,
            top: -18 + parallax,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.12,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF53D4FF).withOpacity(0.22),
                        const Color(0xFF7B61FF).withOpacity(0.12),
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
                      Color(0xFF53D4FF),
                      Color(0xFF6AA8FF),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF58C8FF).withOpacity(0.24),
                      blurRadius: 26,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.calculate_rounded,
                  size: isCompact ? 30 : 34,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: isCompact ? 300 : 232,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _HeroTag(label: 'UnderStack utility app'),
                const SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.only(
                    right: isCompact ? 88 : 126,
                  ),
                  child: Text(
                    'Fast recipe costing for chefs, kitchens and food businesses.',
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
                    right: isCompact ? 20 : 138,
                  ),
                  child: const Text(
                    'Calculate recipe cost, portion cost and food cost percentage in a cleaner premium workflow.',
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
                      icon: Icons.flash_on_rounded,
                      label: 'Quick costing',
                    ),
                    _HeroChip(
                      icon: Icons.auto_graph_rounded,
                      label: 'Margin visibility',
                    ),
                  ],
                ),
                if (!isCompact) ...[
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: _HeroMiniPanel(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMiniPanel extends StatelessWidget {
  const _HeroMiniPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.035),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Built for',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Chefs\nRestaurants\nFood teams',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              height: 1.35,
              letterSpacing: -0.2,
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

class _HomeSummaryStrip extends StatelessWidget {
  const _HomeSummaryStrip();

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
                      label: 'Core goal',
                      value: 'Cost clarity',
                      icon: Icons.visibility_outlined,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _SummaryPill(
                      label: 'Main output',
                      value: 'Food cost %',
                      icon: Icons.pie_chart_outline_rounded,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _SummaryPill(
                      label: 'Use case',
                      value: 'Recipe pricing',
                      icon: Icons.receipt_long_rounded,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _SummaryPill(
                      label: 'Upgrade path',
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
                label: 'Core goal',
                value: 'Cost clarity',
                icon: Icons.visibility_outlined,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _SummaryPill(
                label: 'Main output',
                value: 'Food cost %',
                icon: Icons.pie_chart_outline_rounded,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _SummaryPill(
                label: 'Use case',
                value: 'Recipe pricing',
                icon: Icons.receipt_long_rounded,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _SummaryPill(
                label: 'Upgrade path',
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

class _WhatItDoesCard extends StatelessWidget {
  const _WhatItDoesCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionEyebrow(
            label: 'What this app does',
            icon: Icons.dashboard_customize_rounded,
          ),
          SizedBox(height: 18),
          _FeatureRow(
            icon: Icons.receipt_long_rounded,
            title: 'Recipe cost calculation',
            description:
                'See the full recipe cost based on ingredient pricing and quantity used.',
          ),
          SizedBox(height: 16),
          _FeatureRow(
            icon: Icons.pie_chart_outline_rounded,
            title: 'Cost per serving',
            description:
                'Break the full recipe into portion cost instantly for cleaner pricing decisions.',
          ),
          SizedBox(height: 16),
          _FeatureRow(
            icon: Icons.bar_chart_rounded,
            title: 'Food cost percentage',
            description:
                'Get immediate margin visibility so pricing feels sharper and more controlled.',
          ),
        ],
      ),
    );
  }
}

class _WhyItFeelsBetterCard extends StatelessWidget {
  const _WhyItFeelsBetterCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionEyebrow(
            label: 'Why it feels better',
            icon: Icons.auto_awesome_rounded,
          ),
          SizedBox(height: 16),
          _MiniInfoLine(
            icon: Icons.bolt_rounded,
            title: 'Fast to use',
            subtitle:
                'Designed for quick kitchen calculations without clutter or heavy setup.',
          ),
          SizedBox(height: 12),
          _MiniInfoLine(
            icon: Icons.layers_outlined,
            title: 'Clear hierarchy',
            subtitle:
                'Important numbers stand out first, so the workflow feels more professional.',
          ),
          SizedBox(height: 12),
          _MiniInfoLine(
            icon: Icons.blur_on_rounded,
            title: 'Premium glass UI',
            subtitle:
                'Styled to feel aligned with the UnderStack visual system instead of a basic utility app.',
          ),
        ],
      ),
    );
  }
}

class _WorkflowCard extends StatelessWidget {
  const _WorkflowCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionEyebrow(
            label: 'Typical workflow',
            icon: Icons.route_rounded,
          ),
          SizedBox(height: 16),
          _WorkflowStep(
            index: '01',
            title: 'Set recipe inputs',
            subtitle: 'Add recipe name, currency, servings and selling price.',
          ),
          SizedBox(height: 14),
          _WorkflowStep(
            index: '02',
            title: 'Add ingredients',
            subtitle: 'Enter unit, unit price and the quantity used in the dish.',
          ),
          SizedBox(height: 14),
          _WorkflowStep(
            index: '03',
            title: 'Review results',
            subtitle:
                'Check total cost, cost per serving and food cost percentage instantly.',
          ),
        ],
      ),
    );
  }
}

class _UpgradePathCard extends StatelessWidget {
  const _UpgradePathCard();

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
            'Need stock, waste, planning and broader restaurant operations? Move to GastroApp.',
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
          _PremiumCtaButton(
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

class _WorkflowStep extends StatelessWidget {
  final String index;
  final String title;
  final String subtitle;

  const _WorkflowStep({
    required this.index,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          alignment: Alignment.center,
          child: Text(
            index,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
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
                  fontSize: 15,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  height: 1.5,
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