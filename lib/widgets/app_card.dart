import 'dart:ui';

import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 30,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.34),
            blurRadius: 42,
            spreadRadius: -6,
            offset: const Offset(0, 22),
          ),
          BoxShadow(
            color: const Color(0xFF57C8FF).withOpacity(0.08),
            blurRadius: 26,
            spreadRadius: -10,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.03),
            blurRadius: 12,
            spreadRadius: -8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: const Color(0x66141E31),
              border: Border.all(
                color: Colors.white.withOpacity(0.14),
                width: 1.05,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.025),
                  Colors.white.withOpacity(0.01),
                ],
                stops: const [0.0, 0.32, 1.0],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.06),
                          Colors.transparent,
                          Colors.black.withOpacity(0.06),
                        ],
                        stops: const [0.0, 0.28, 1.0],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 0,
                  left: 18,
                  right: 18,
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.26),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: -20,
                  left: 24,
                  child: IgnorePointer(
                    child: Container(
                      width: 150,
                      height: 72,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.16),
                            Colors.white.withOpacity(0.02),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 14,
                  right: 16,
                  child: IgnorePointer(
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF56D7FF).withOpacity(0.10),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  right: -26,
                  bottom: -26,
                  child: IgnorePointer(
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.035),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.02),
                          blurRadius: 20,
                          spreadRadius: 1,
                          offset: const Offset(0, -2),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 22,
                          spreadRadius: 1,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: padding,
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}