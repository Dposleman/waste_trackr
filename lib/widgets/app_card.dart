import 'dart:ui';
import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.055),
                const Color(0xFF0A1730).withOpacity(0.48),
                const Color(0xFF091427).withOpacity(0.38),
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.065),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.28),
                blurRadius: 28,
                offset: const Offset(0, 18),
              ),
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.035),
                blurRadius: 32,
                spreadRadius: -8,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}