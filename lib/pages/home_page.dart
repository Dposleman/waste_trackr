import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../widgets/app_card.dart';
import '../utils/external_links.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        const Text(
          'Food Cost Calculator',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Fast costing tool for chefs, restaurants and kitchen operations.',
          style: TextStyle(
            fontSize: 15,
            color: AppTheme.textMuted,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Start a new calculation',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              const Text(
                'Add ingredients, calculate total cost, cost per serving and food cost percentage.',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Open the Calculator tab below.'),
                    ),
                  );
                },
                icon: const Icon(Icons.calculate),
                label: const Text('Go to calculator'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Why this app matters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 12),
              _Bullet(text: 'Understand real plate cost instantly'),
              _Bullet(text: 'Price dishes with better margins'),
              _Bullet(text: 'Prepare kitchens for deeper cost control'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upgrade path',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              const Text(
                'Need stock, waste, production planning and restaurant-wide control? GastroApp is the full system.',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
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

class _Bullet extends StatelessWidget {
  final String text;

  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(
              Icons.check_circle,
              size: 18,
              color: AppTheme.secondary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}