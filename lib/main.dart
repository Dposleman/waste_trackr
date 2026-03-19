import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'pages/calculator_page.dart';
import 'pages/home_page.dart';
import 'pages/saved_recipes_page.dart';
import 'pages/settings_page.dart';

void main() {
  runApp(const FoodCostCalculatorApp());
}

class FoodCostCalculatorApp extends StatelessWidget {
  const FoodCostCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Cost Calculator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  Map<String, dynamic>? _recipeToOpenInCalculator;
  int _calculatorKey = 0;

  void _openRecipeInCalculator(Map<String, dynamic> recipe) {
    setState(() {
      _recipeToOpenInCalculator = recipe;
      _calculatorKey++;
      _currentIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _PremiumBackground(),
          SafeArea(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                const HomePage(),
                CalculatorPage(
                  key: ValueKey(_calculatorKey),
                  initialRecipe: _recipeToOpenInCalculator,
                ),
                SavedRecipesPage(
                  onOpenInCalculator: _openRecipeInCalculator,
                ),
                const SettingsPage(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.calculate_outlined),
                selectedIcon: Icon(Icons.calculate_rounded),
                label: 'Calculator',
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmark_border_rounded),
                selectedIcon: Icon(Icons.bookmark_rounded),
                label: 'Saved',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumBackground extends StatelessWidget {
  const _PremiumBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF030816),
                  Color(0xFF071225),
                  Color(0xFF081A30),
                  Color(0xFF050D1E),
                ],
                stops: [0.0, 0.28, 0.72, 1.0],
              ),
            ),
          ),
          const Positioned(
            top: -110,
            left: -90,
            child: _GlowOrb(
              size: 280,
              color: Color(0xFF2563FF),
              opacity: 0.16,
            ),
          ),
          const Positioned(
            top: 110,
            right: -80,
            child: _GlowOrb(
              size: 250,
              color: Color(0xFF22D3EE),
              opacity: 0.10,
            ),
          ),
          const Positioned(
            bottom: 110,
            left: -70,
            child: _GlowOrb(
              size: 240,
              color: Color(0xFF7C3AED),
              opacity: 0.10,
            ),
          ),
          const Positioned(
            bottom: -60,
            right: -40,
            child: _GlowOrb(
              size: 220,
              color: Color(0xFF3B82F6),
              opacity: 0.08,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.012),
                      Colors.transparent,
                      Colors.black.withOpacity(0.10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _GlowOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(opacity),
              color.withOpacity(opacity * 0.52),
              color.withOpacity(0),
            ],
            stops: const [0, 0.42, 1],
          ),
        ),
      ),
    );
  }
}