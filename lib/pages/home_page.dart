import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../utils/external_links.dart';
import '../widgets/app_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 126),
      children: [
        AppCard(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _HeroBadge(),
              SizedBox(height: 22),
              Text(
                'Fast recipe costing for chefs, kitchens and food businesses.',
                style: TextStyle(
                  fontSize: 18,
                  height: 1.42,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.45,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        AppCard(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'What this app does',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.25,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 20),
              _FeatureRow(
                icon: Icons.receipt_long_rounded,
                title: 'Recipe cost calculation',
                description: 'See total recipe cost based on ingredients used.',
              ),
              SizedBox(height: 18),
              _FeatureRow(
                icon: Icons.pie_chart_outline_rounded,
                title: 'Cost per serving',
                description: 'Understand dish cost by portion instantly.',
              ),
              SizedBox(height: 18),
              _FeatureRow(
                icon: Icons.bar_chart_rounded,
                title: 'Food cost percentage',
                description: 'Quick margin visibility for smarter pricing.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        AppCard(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upgrade path',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.25,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Need stock, waste, planning and broader restaurant operations? Move to GastroApp.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.62,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 22),
              _PremiumCtaButton(
                label: 'Explore GastroApp',
                onTap: ExternalLinks.openGastroApp,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
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
            color: const Color(0xFF58C8FF).withOpacity(0.30),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(1.2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(23),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF64DAFF),
              Color(0xFF69A8FF),
            ],
          ),
        ),
        child: const Icon(
          Icons.calculate_rounded,
          color: Colors.white,
          size: 34,
        ),
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
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.028),
            border: Border.all(
              color: const Color(0xFF69A8FF).withOpacity(0.34),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF69A8FF).withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: const Color(0xFF69A8FF),
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
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