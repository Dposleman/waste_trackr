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
            filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                color: const Color(0x5E081321),
                border: Border.all(
                  color: Colors.white.withOpacity(0.09),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.28),
                    blurRadius: 30,
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
            Color(0xFF0E2347),
            Color(0xFF09182F),
            Color(0xFF050C19),
            Color(0xFF02050E),
          ],
          stops: [0.0, 0.30, 0.72, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _StructuredBackgroundPainter(),
            ),
          ),
          Positioned(
            top: -90,
            right: -40,
            child: _edgeGlow(
              width: 180,
              height: 180,
              color: const Color(0xFF35CFFF).withOpacity(0.10),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -60,
            child: _edgeGlow(
              width: 160,
              height: 160,
              color: const Color(0xFF6E63FF).withOpacity(0.08),
            ),
          ),
        ],
      ),
    );
  }

  Widget _edgeGlow({
    required double width,
    required double height,
    required Color color,
  }) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _StructuredBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final softLine = Paint()
      ..color = Colors.white.withOpacity(0.028)
      ..strokeWidth = 1;

    final softerLine = Paint()
      ..color = Colors.white.withOpacity(0.014)
      ..strokeWidth = 1;

    final accentLine = Paint()
      ..color = const Color(0xFF6CB6FF).withOpacity(0.06)
      ..strokeWidth = 1.2;

    final topBeam = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x22FFFFFF),
          Color(0x00FFFFFF),
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width * 0.42, size.height * 0.22),
      );

    final beamPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.38, 0)
      ..lineTo(size.width * 0.21, size.height * 0.28)
      ..lineTo(0, size.height * 0.40)
      ..close();

    canvas.drawPath(beamPath, topBeam);

    final rightShapePaint = Paint()
      ..color = const Color(0xFF33D6FF).withOpacity(0.035)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    final rightShape = Path()
      ..moveTo(size.width * 0.88, size.height * 0.02)
      ..quadraticBezierTo(
        size.width * 1.02,
        size.height * 0.14,
        size.width * 0.92,
        size.height * 0.32,
      )
      ..quadraticBezierTo(
        size.width * 0.84,
        size.height * 0.18,
        size.width * 0.88,
        size.height * 0.02,
      )
      ..close();

    canvas.drawPath(rightShape, rightShapePaint);

    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.12),
      Offset(size.width * 0.80, size.height * 0.12),
      softLine,
    );

    canvas.drawLine(
      Offset(size.width * 0.18, size.height * 0.52),
      Offset(size.width * 0.92, size.height * 0.52),
      softerLine,
    );

    canvas.drawLine(
      Offset(size.width * 0.24, size.height * 0.82),
      Offset(size.width * 0.94, size.height * 0.82),
      softerLine,
    );

    final arcRect1 = Rect.fromCircle(
      center: Offset(size.width * 0.92, size.height * 0.10),
      radius: 62,
    );
    final arcRect2 = Rect.fromCircle(
      center: Offset(size.width * 0.92, size.height * 0.10),
      radius: 44,
    );
    final arcRect3 = Rect.fromCircle(
      center: Offset(size.width * 0.08, size.height * 0.86),
      radius: 58,
    );

    canvas.drawArc(
      arcRect1,
      3.5,
      1.4,
      false,
      accentLine,
    );
    canvas.drawArc(
      arcRect2,
      3.5,
      1.4,
      false,
      accentLine..color = const Color(0xFF35CFFF).withOpacity(0.045),
    );
    canvas.drawArc(
      arcRect3,
      5.2,
      1.2,
      false,
      Paint()
        ..color = const Color(0xFF7A63FF).withOpacity(0.040)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}