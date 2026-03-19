import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../utils/external_links.dart';
import '../widgets/app_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        AppCard(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF56A8FF),
                      Color(0xFF22D3EE),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.16),
                      blurRadius: 24,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.calculate_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Fast recipe costing for chefs, kitchens and food businesses.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const AppCard(
          padding: EdgeInsets.fromLTRB(22, 22, 22, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What this app does',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 18),
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
                icon: Icons.insert_chart_outlined_rounded,
                title: 'Food cost percentage',
                description: 'Quick margin visibility for smarter pricing.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        AppCard(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upgrade path',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Need stock, waste, planning and broader restaurant operations? Move to GastroApp.',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  height: 1.55,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: ExternalLinks.openGastroApp,
                child: const Text('Explore GastroApp'),
              ),
            ],
          ),
        ),
      ],
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
            color: const Color(0xFF0D2342).withOpacity(0.82),
            border: Border.all(
              color: const Color(0xFF2C67D8).withOpacity(0.38),
            ),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF58A6FF),
            size: 27,
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
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    height: 1.55,
                    fontSize: 14,
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