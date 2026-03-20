import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'pages/calculator_page.dart';
import 'pages/history_page.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';

void main() {
  runApp(const WasteTrackrApp());
}

class WasteTrackrApp extends StatelessWidget {
  const WasteTrackrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WasteTrackr',
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
  int _refreshToken = 0;

  void _notifyDataChanged() {
    setState(() {
      _refreshToken++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(refreshToken: _refreshToken),
      CalculatorPage(onEntrySaved: _notifyDataChanged),
      HistoryPage(onDataChanged: _notifyDataChanged, refreshToken: _refreshToken),
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
                color: const Color(0xFF07111F).withValues(alpha: 0.44),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.10),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.30),
                    blurRadius: 30,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: NavigationBar(
                  selectedIndex: _currentIndex,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  surfaceTintColor: Colors.transparent,
                  onDestinationSelected: (index) {
                    setState(() => _currentIndex = index);
                  },
                  destinations: const [
                    _NavDestination(
                      activeIcon: Icons.dashboard_rounded,
                      inactiveIcon: Icons.dashboard_outlined,
                      label: 'Dashboard',
                    ),
                    _NavDestination(
                      activeIcon: Icons.add_chart_rounded,
                      inactiveIcon: Icons.add_chart_outlined,
                      label: 'Add Entry',
                    ),
                    _NavDestination(
                      activeIcon: Icons.receipt_long_rounded,
                      inactiveIcon: Icons.receipt_long_outlined,
                      label: 'History',
                    ),
                    _NavDestination(
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
      ),
    );
  }
}

class _NavDestination extends StatelessWidget {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;

  const _NavDestination({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationDestination(
      label: label,
      icon: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Icon(inactiveIcon),
      ),
      selectedIcon: Container(
        height: 32,
        constraints: const BoxConstraints(minWidth: 46),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary.withValues(alpha: 0.22),
              AppTheme.cyan.withValues(alpha: 0.12),
              AppTheme.violet.withValues(alpha: 0.10),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.13),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.14),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          activeIcon,
          color: Colors.white,
          size: 20,
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
              color: const Color(0xFF38D4FF).withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            bottom: 110,
            left: -46,
            child: _edgeGlow(
              width: 150,
              height: 150,
              color: const Color(0xFF775EFF).withValues(alpha: 0.07),
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
      ..color = Colors.white.withValues(alpha: 0.026)
      ..strokeWidth = 1;

    final faintLine = Paint()
      ..color = Colors.white.withValues(alpha: 0.014)
      ..strokeWidth = 1;

    final accentLine = Paint()
      ..color = const Color(0xFF58CFFF).withValues(alpha: 0.055)
      ..strokeWidth = 1.15
      ..style = PaintingStyle.stroke;

    final topBeam = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFFFFFFF).withValues(alpha: 0.09),
          const Color(0xFFFFFFFF).withValues(alpha: 0.0),
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
      ..color = const Color(0xFF35D4FF).withValues(alpha: 0.028)
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
        ..color = const Color(0xFF38D5FF).withValues(alpha: 0.042)
        ..strokeWidth = 1.1
        ..style = PaintingStyle.stroke,
    );

    canvas.drawArc(
      arcRectBottom,
      5.18,
      1.14,
      false,
      Paint()
        ..color = const Color(0xFF7A63FF).withValues(alpha: 0.038)
        ..strokeWidth = 1.15
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}