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
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: const Color(0xAA07111F),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.30),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
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
        gradient: RadialGradient(
          center: Alignment(-0.85, -1.0),
          radius: 1.6,
          colors: [
            Color(0xFF132D61),
            Color(0xFF08172F),
            Color(0xFF030814),
          ],
          stops: [0.0, 0.42, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -120,
            child: _blurOrb(
              size: 280,
              color: const Color(0xFF58A6FF).withOpacity(0.24),
            ),
          ),
          Positioned(
            top: 40,
            right: -110,
            child: _blurOrb(
              size: 240,
              color: const Color(0xFF33D6FF).withOpacity(0.14),
            ),
          ),
          Positioned(
            top: 280,
            left: -100,
            child: _blurOrb(
              size: 220,
              color: const Color(0xFF6E6BFF).withOpacity(0.10),
            ),
          ),
          Positioned(
            bottom: 140,
            right: -120,
            child: _blurOrb(
              size: 260,
              color: const Color(0xFF25C8FF).withOpacity(0.10),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -80,
            child: _blurOrb(
              size: 220,
              color: const Color(0xFF7A5CFF).withOpacity(0.08),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _SoftMeshPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blurOrb({
    required double size,
    required Color color,
  }) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
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

class _SoftMeshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path1 = Path()
      ..moveTo(size.width * 0.68, 0)
      ..quadraticBezierTo(
        size.width * 0.94,
        size.height * 0.10,
        size.width,
        size.height * 0.28,
      )
      ..lineTo(size.width, 0)
      ..close();

    final paint1 = Paint()
      ..color = Colors.white.withOpacity(0.018)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    canvas.drawPath(path1, paint1);

    final path2 = Path()
      ..moveTo(0, size.height * 0.42)
      ..quadraticBezierTo(
        size.width * 0.16,
        size.height * 0.36,
        size.width * 0.24,
        size.height * 0.52,
      )
      ..quadraticBezierTo(
        size.width * 0.12,
        size.height * 0.62,
        0,
        size.height * 0.58,
      )
      ..close();

    final paint2 = Paint()
      ..color = AppTheme.primary.withOpacity(0.035)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 35);

    canvas.drawPath(path2, paint2);

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(size.width * 0.10, size.height * 0.16),
      Offset(size.width * 0.78, size.height * 0.16),
      linePaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.22, size.height * 0.78),
      Offset(size.width * 0.92, size.height * 0.78),
      linePaint..color = Colors.white.withOpacity(0.018),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}