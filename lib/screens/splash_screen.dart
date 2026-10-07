import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer(const Duration(seconds: 2, milliseconds: 500), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _timer?.cancel();
          Navigator.pushReplacementNamed(context, '/login');
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.softBlue, AppColors.surface, AppColors.softPink],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOut,
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * 12),
                    child: child,
                  ),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BabyShopHubLogo(iconSize: 80, fontSize: 34),
                    SizedBox(height: 28),
                    _LoadingDots(),
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

/// Three small dots that gently scale and fade one after another, in a loop.
class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const List<Color> _dotColors = [
    AppColors.primaryBlue,
    AppColors.primaryBlue,
    AppColors.secondaryPink,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            // Each dot is delayed a little after the previous one.
            final t = (_controller.value - i * 0.16) % 1.0;
            // Smooth 0 -> 1 -> 0 pulse over the first half of the cycle.
            final pulse = t < 0.5 ? math.sin(t / 0.5 * math.pi) : 0.0;
            final scale = 0.7 + 0.3 * pulse;
            final opacity = 0.3 + 0.7 * pulse;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _dotColors[i].withValues(alpha: opacity),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}