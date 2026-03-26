import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _glowController;
  late AnimationController _driftController;
  late Animation<double> _waveAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _driftAnimation;

  @override
  void initState() {
    super.initState();

    // Subtle wave at the bottom
    _waveController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat(reverse: true);

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    // Primary glow breathing
    _glowController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Slow drift for a second set of orbs — offset phase
    _driftController = AnimationController(
      duration: const Duration(seconds: 7),
      vsync: this,
    )..repeat(reverse: true);

    _driftAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _driftController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _glowController.dispose();
    _driftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.mainGradient,
      child: Stack(
        children: [
          // ── Orb 1: Top-left primary blue glow ──────────────────────────
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, _) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      -0.6 + _glowAnimation.value * 0.15,
                      -0.6 + _glowAnimation.value * 0.1,
                    ),
                    radius: 0.85,
                    colors: [
                      AppTheme.primaryColor.withValues(
                        alpha: 0.18 + _glowAnimation.value * 0.08,
                      ),
                      AppTheme.primaryColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              );
            },
          ),

          // ── Orb 2: Bottom-right highlight blue glow ──────────────────────
          AnimatedBuilder(
            animation: _driftAnimation,
            builder: (context, _) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      0.7 - _driftAnimation.value * 0.15,
                      0.8 - _driftAnimation.value * 0.1,
                    ),
                    radius: 0.7,
                    colors: [
                      AppTheme.highlightColor.withValues(
                        alpha: 0.12 + _driftAnimation.value * 0.06,
                      ),
                      AppTheme.highlightColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              );
            },
          ),

          // ── Orb 3: Center-top gold accent glow (premium feel) ────────────
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, _) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      0.3 + _glowAnimation.value * 0.1,
                      -0.9,
                    ),
                    radius: 0.5,
                    colors: [
                      AppTheme.accentGold.withValues(
                        alpha: 0.06 + _glowAnimation.value * 0.04,
                      ),
                      AppTheme.accentGold.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              );
            },
          ),

          // ── Orb 4: Bottom-left cyan glow ─────────────────────────────────
          AnimatedBuilder(
            animation: _driftAnimation,
            builder: (context, _) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      -0.9,
                      0.7 + _driftAnimation.value * 0.12,
                    ),
                    radius: 0.45,
                    colors: [
                      AppTheme.accentCyan.withValues(
                        alpha: 0.07 + _driftAnimation.value * 0.04,
                      ),
                      AppTheme.accentCyan.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              );
            },
          ),

          // ── Subtle wave layer at bottom ───────────────────────────────────
          AnimatedBuilder(
            animation: _waveAnimation,
            builder: (context, _) {
              return CustomPaint(
                painter: WavePainter(
                  animationValue: _waveAnimation.value,
                  color: AppTheme.primaryColor.withValues(alpha: 0.055),
                ),
                size: Size.infinite,
              );
            },
          ),

          // ── Content ───────────────────────────────────────────────────────
          widget.child,
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  WavePainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 2; i++) {
      final waveHeight = 18.0 + i * 12;
      final speed = 1.0 + i * 0.4;
      final phase = animationValue * 2 * pi * speed;

      final path = Path();
      path.moveTo(0, size.height);

      for (double x = 0; x <= size.width; x += 6) {
        final y = size.height * 0.72 +
            waveHeight *
                (0.4 + 0.6 * (i + 1) / 2) *
                (sin(x * 0.008 + phase) + sin(x * 0.004 + phase * 0.6));
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.color != color;
}
