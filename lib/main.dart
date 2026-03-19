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
  int _calculatorSeed = 0;

  void _openRecipeInCalculator(Map<String, dynamic> recipe) {
    setState(() {
      _recipeToOpenInCalculator = Map<String, dynamic>.from(recipe);
      _calculatorSeed++;
      _currentIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomePage(),
      CalculatorPage(
        key: ValueKey('calculator_$_calculatorSeed'),
        initialRecipe: _recipeToOpenInCalculator,
      ),
      SavedRecipesPage(
        onOpenInCalculator: _openRecipeInCalculator,
      ),
      const SettingsPage(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          const _PremiumBackground(),
          SafeArea(
            bottom: false,
            child: IndexedStack(
              index: _currentIndex,
              children: pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppTheme.border.withOpacity(0.85),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xF0101E39),
              const Color(0xF0000717),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.34),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            backgroundColor: Colors.transparent,
            elevation: 0,
            labelBehavior:
                NavigationDestinationLabelBehavior.onlyShowSelected,
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
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.35,
          colors: [
            Color(0xFF0D2450),
            Color(0xFF071226),
            Color(0xFF040914),
          ],
          stops: [0.0, 0.52, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            left: -70,
            child: _glow(
              size: 220,
              color: AppTheme.primary.withOpacity(0.18),
            ),
          ),
          Positioned(
            top: 120,
            right: -70,
            child: _glow(
              size: 200,
              color: AppTheme.cyan.withOpacity(0.10),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -60,
            child: _glow(
              size: 180,
              color: AppTheme.violet.withOpacity(0.10),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _BackgroundPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 90,
            spreadRadius: 18,
          ),
        ],
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = AppTheme.primary.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = AppTheme.cyan.withOpacity(0.04)
      ..style = PaintingStyle.fill;

    final paint3 = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path1 = Path()
      ..moveTo(size.width * 0.72, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.25)
      ..close();

    final path2 = Path()
      ..moveTo(0, size.height * 0.55)
      ..lineTo(size.width * 0.22, size.height * 0.46)
      ..lineTo(size.width * 0.16, size.height * 0.72)
      ..close();

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);

    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.16),
      Offset(size.width * 0.92, size.height * 0.16),
      paint3,
    );

    canvas.drawLine(
      Offset(size.width * 0.12, size.height * 0.52),
      Offset(size.width * 0.88, size.height * 0.52),
      paint3..color = Colors.white.withOpacity(0.018),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}