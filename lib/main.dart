import 'dart:ui';

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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                color: const Color(0x70061222),
                border: Border.all(
                  color: Colors.white.withOpacity(0.09),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.24),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: NavigationBar(
                selectedIndex: _currentIndex,
                backgroundColor: Colors.transparent,
                elevation: 0,
                labelBehavior:
                    NavigationDestinationLabelBehavior.alwaysShow,
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF102650),
            Color(0xFF091A35),
            Color(0xFF040B18),
            Color(0xFF020611),
          ],
          stops: [0.0, 0.26, 0.70, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -150,
            left: -120,
            child: _orb(
              size: 320,
              color: const Color(0xFF5CA8FF).withOpacity(0.26),
            ),
          ),
          Positioned(
            top: -10,
            right: -100,
            child: _orb(
              size: 250,
              color: const Color(0xFF2DD6FF).withOpacity(0.14),
            ),
          ),
          Positioned(
            top: 280,
            left: -120,
            child: _orb(
              size: 240,
              color: const Color(0xFF7B61FF).withOpacity(0.11),
            ),
          ),
          Positioned(
            bottom: 180,
            right: -130,
            child: _orb(
              size: 280,
              color: const Color(0xFF1FC8FF).withOpacity(0.10),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -40,
            child: _orb(
              size: 220,
              color: const Color(0xFF6F5BFF).withOpacity(0.08),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _AmbientPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orb({
    required double size,
    required Color color,
  }) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 52, sigmaY: 52),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

class _AmbientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final topGlow = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x18FFFFFF),
          Color(0x00FFFFFF),
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width * 0.55, size.height * 0.22),
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);

    final topPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.52, 0)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.10,
        0,
        size.height * 0.18,
      )
      ..close();

    canvas.drawPath(topPath, topGlow);

    final rightGlow = Paint()
      ..color = const Color(0x22A7E8FF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    final rightPath = Path()
      ..moveTo(size.width * 0.82, size.height * 0.10)
      ..quadraticBezierTo(
        size.width * 1.02,
        size.height * 0.18,
        size.width * 0.90,
        size.height * 0.34,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.22,
        size.width * 0.82,
        size.height * 0.10,
      )
      ..close();

    canvas.drawPath(rightPath, rightGlow);

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.022)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.14),
      Offset(size.width * 0.78, size.height * 0.14),
      linePaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.22, size.height * 0.82),
      Offset(size.width * 0.94, size.height * 0.82),
      linePaint..color = Colors.white.withOpacity(0.012),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}