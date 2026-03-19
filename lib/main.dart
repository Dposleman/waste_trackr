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
                color: const Color(0x6607111F),
                border: Border.all(
                  color: Colors.white.withOpacity(0.10),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.30),
                    blurRadius: 30,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: NavigationBar(
                selectedIndex: _currentIndex,
                backgroundColor: Colors.transparent,
                elevation: 0,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                onDestinationSelected: (index) {
                  setState(() => _currentIndex = index);
                },
                destinations: [
                  _destination(
                    selected: _currentIndex == 0,
                    activeIcon: Icons.home_rounded,
                    inactiveIcon: Icons.home_outlined,
                    label: 'Home',
                  ),
                  _destination(
                    selected: _currentIndex == 1,
                    activeIcon: Icons.calculate_rounded,
                    inactiveIcon: Icons.calculate_outlined,
                    label: 'Calculator',
                  ),
                  _destination(
                    selected: _currentIndex == 2,
                    activeIcon: Icons.bookmark_rounded,
                    inactiveIcon: Icons.bookmark_border_rounded,
                    label: 'Saved',
                  ),
                  _destination(
                    selected: _currentIndex == 3,
                    activeIcon: Icons.settings_rounded,
                    inactiveIcon: Icons.settings_outlined,
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

  NavigationDestination _destination({
    required bool selected,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required String label,
  }) {
    return NavigationDestination(
      label: label,
      icon: Icon(inactiveIcon),
      selectedIcon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary.withOpacity(0.28),
              AppTheme.cyan.withOpacity(0.18),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.14),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          activeIcon,
          color: Colors.white,
          size: 23,
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
            Color(0xFF0D2042),
            Color(0xFF09172D),
            Color(0xFF050B17),
            Color(0xFF02050D),
          ],
          stops: [0.0, 0.28, 0.70, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _PremiumGridPainter(),
            ),
          ),
          Positioned(
            top: -100,
            left: -70,
            child: _edgeGlow(
              size: 180,
              color: AppTheme.primary.withOpacity(0.10),
            ),
          ),
          Positioned(
            top: 70,
            right: -70,
            child: _edgeGlow(
              size: 150,
              color: AppTheme.cyan.withOpacity(0.07),
            ),
          ),
          Positioned(
            bottom: 120,
            right: -80,
            child: _edgeGlow(
              size: 170,
              color: AppTheme.violet.withOpacity(0.06),
            ),
          ),
        ],
      ),
    );
  }

  Widget _edgeGlow({
    required double size,
    required Color color,
  }) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _PremiumGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final lineSoft = Paint()
      ..color = Colors.white.withOpacity(0.028)
      ..strokeWidth = 1;

    final lineSofter = Paint()
      ..color = Colors.white.withOpacity(0.012)
      ..strokeWidth = 1;

    final accent = Paint()
      ..color = AppTheme.primary.withOpacity(0.045)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;

    final beamPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x18FFFFFF),
          Color(0x00FFFFFF),
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width * 0.48, size.height * 0.26),
      );

    final beamPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.34, 0)
      ..lineTo(size.width * 0.16, size.height * 0.34)
      ..lineTo(0, size.height * 0.46)
      ..close();

    canvas.drawPath(beamPath, beamPaint);

    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.12),
      Offset(size.width * 0.78, size.height * 0.12),
      lineSoft,
    );

    canvas.drawLine(
      Offset(size.width * 0.16, size.height * 0.34),
      Offset(size.width * 0.92, size.height * 0.34),
      lineSofter,
    );

    canvas.drawLine(
      Offset(size.width * 0.24, size.height * 0.70),
      Offset(size.width * 0.94, size.height * 0.70),
      lineSofter,
    );

    final arc1 = Rect.fromCircle(
      center: Offset(size.width * 0.94, size.height * 0.16),
      radius: 58,
    );
    final arc2 = Rect.fromCircle(
      center: Offset(size.width * 0.10, size.height * 0.86),
      radius: 54,
    );

    canvas.drawArc(arc1, 3.6, 1.3, false, accent);
    canvas.drawArc(
      arc2,
      5.1,
      1.25,
      false,
      Paint()
        ..color = AppTheme.violet.withOpacity(0.04)
        ..strokeWidth = 1.1
        ..style = PaintingStyle.stroke,
    );

    final rightShard = Path()
      ..moveTo(size.width * 0.86, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.24)
      ..quadraticBezierTo(
        size.width * 0.88,
        size.height * 0.18,
        size.width * 0.86,
        0,
      )
      ..close();

    canvas.drawPath(
      rightShard,
      Paint()
        ..color = AppTheme.cyan.withOpacity(0.028)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}