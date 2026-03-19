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
        child: _PremiumBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
        ),
      ),
    );
  }
}

class _PremiumBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _PremiumBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_PremiumNavItemData>[
      const _PremiumNavItemData(
        label: 'Home',
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
      ),
      const _PremiumNavItemData(
        label: 'Calculator',
        icon: Icons.calculate_outlined,
        selectedIcon: Icons.calculate_rounded,
      ),
      const _PremiumNavItemData(
        label: 'Saved',
        icon: Icons.bookmark_border_rounded,
        selectedIcon: Icons.bookmark_rounded,
      ),
      const _PremiumNavItemData(
        label: 'Settings',
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings_rounded,
      ),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(34),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          height: 84,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            color: const Color(0x5C0A1323),
            border: Border.all(
              color: Colors.white.withOpacity(0.10),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.34),
                blurRadius: 34,
                offset: const Offset(0, 18),
              ),
              BoxShadow(
                color: const Color(0xFF4CD5FF).withOpacity(0.05),
                blurRadius: 20,
                spreadRadius: -6,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = index == currentIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: selected
                          ? Border.all(
                              color: Colors.white.withOpacity(0.12),
                              width: 1,
                            )
                          : null,
                      gradient: selected
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.14),
                                const Color(0xFF43CFFF).withOpacity(0.12),
                                const Color(0xFF7B61FF).withOpacity(0.10),
                              ],
                            )
                          : null,
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF44D2FF).withOpacity(0.10),
                                blurRadius: 18,
                                spreadRadius: -8,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.04),
                                blurRadius: 10,
                                spreadRadius: -6,
                                offset: const Offset(0, -2),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          height: 34,
                          width: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: selected
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.20),
                                      Colors.white.withOpacity(0.06),
                                    ],
                                  )
                                : null,
                          ),
                          child: Icon(
                            selected ? item.selectedIcon : item.icon,
                            color: selected
                                ? AppTheme.textPrimary
                                : AppTheme.textSoft,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selected
                                ? AppTheme.textPrimary
                                : AppTheme.textSoft,
                            fontSize: 11.5,
                            fontWeight:
                                selected ? FontWeight.w800 : FontWeight.w700,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _PremiumNavItemData {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _PremiumNavItemData({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
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
            Color(0xFF0B1831),
            Color(0xFF081221),
            Color(0xFF050B16),
            Color(0xFF03060E),
          ],
          stops: [0.0, 0.32, 0.74, 1.0],
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
            top: -70,
            right: -34,
            child: _edgeGlow(
              width: 170,
              height: 170,
              color: const Color(0xFF38D4FF).withOpacity(0.09),
            ),
          ),
          Positioned(
            bottom: 110,
            left: -46,
            child: _edgeGlow(
              width: 150,
              height: 150,
              color: const Color(0xFF775EFF).withOpacity(0.08),
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
        imageFilter: ImageFilter.blur(sigmaX: 34, sigmaY: 34),
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
    final subtleLine = Paint()
      ..color = Colors.white.withOpacity(0.026)
      ..strokeWidth = 1;

    final faintLine = Paint()
      ..color = Colors.white.withOpacity(0.014)
      ..strokeWidth = 1;

    final accentLine = Paint()
      ..color = const Color(0xFF58CFFF).withOpacity(0.06)
      ..strokeWidth = 1.15
      ..style = PaintingStyle.stroke;

    final topBeam = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x20FFFFFF),
          Color(0x00FFFFFF),
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width * 0.42, size.height * 0.24),
      );

    final topLeftShape = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.36, 0)
      ..lineTo(size.width * 0.20, size.height * 0.26)
      ..lineTo(0, size.height * 0.38)
      ..close();

    canvas.drawPath(topLeftShape, topBeam);

    final rightGlowPaint = Paint()
      ..color = const Color(0xFF35D4FF).withOpacity(0.030)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

    final rightShape = Path()
      ..moveTo(size.width * 0.88, size.height * 0.03)
      ..quadraticBezierTo(
        size.width * 1.02,
        size.height * 0.15,
        size.width * 0.92,
        size.height * 0.31,
      )
      ..quadraticBezierTo(
        size.width * 0.84,
        size.height * 0.18,
        size.width * 0.88,
        size.height * 0.03,
      )
      ..close();

    canvas.drawPath(rightShape, rightGlowPaint);

    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.13),
      Offset(size.width * 0.82, size.height * 0.13),
      subtleLine,
    );

    canvas.drawLine(
      Offset(size.width * 0.20, size.height * 0.54),
      Offset(size.width * 0.94, size.height * 0.54),
      faintLine,
    );

    canvas.drawLine(
      Offset(size.width * 0.28, size.height * 0.82),
      Offset(size.width * 0.94, size.height * 0.82),
      faintLine,
    );

    final arcRectTopOuter = Rect.fromCircle(
      center: Offset(size.width * 0.92, size.height * 0.10),
      radius: 62,
    );

    final arcRectTopInner = Rect.fromCircle(
      center: Offset(size.width * 0.92, size.height * 0.10),
      radius: 44,
    );

    final arcRectBottom = Rect.fromCircle(
      center: Offset(size.width * 0.08, size.height * 0.88),
      radius: 58,
    );

    canvas.drawArc(
      arcRectTopOuter,
      3.55,
      1.38,
      false,
      accentLine,
    );

    canvas.drawArc(
      arcRectTopInner,
      3.55,
      1.38,
      false,
      Paint()
        ..color = const Color(0xFF38D5FF).withOpacity(0.045)
        ..strokeWidth = 1.1
        ..style = PaintingStyle.stroke,
    );

    canvas.drawArc(
      arcRectBottom,
      5.18,
      1.14,
      false,
      Paint()
        ..color = const Color(0xFF7A63FF).withOpacity(0.040)
        ..strokeWidth = 1.15
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}