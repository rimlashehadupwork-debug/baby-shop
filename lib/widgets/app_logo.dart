import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// BabyShopHub brand logo (stroller + teddy mark) with wordmark.
/// Public API is unchanged so every existing usage keeps working.
class BabyShopHubLogo extends StatelessWidget {
  final double iconSize;
  final bool showText;
  final double fontSize;
  final bool isVertical;

  const BabyShopHubLogo({
    super.key,
    this.iconSize = 56,
    this.showText = true,
    this.fontSize = 26,
    this.isVertical = true,
  });

  @override
  Widget build(BuildContext context) {
    final double side = iconSize + 16;
    final logoMark = Container(
      width: side,
      height: side,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(side * 0.26),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryPink.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(side * 0.26),
        child: Image.asset(
          'assets/images/babyshophub_logo.png',
          width: side,
          height: side,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: AppColors.surface,
            child: Icon(
              Icons.stroller_rounded,
              size: iconSize * 0.7,
              color: AppColors.secondaryPink,
            ),
          ),
        ),
      ),
    );

    if (!showText) return logoMark;

    final logoText = RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        children: const [
          TextSpan(text: 'Baby', style: TextStyle(color: AppColors.primaryBlue)),
          TextSpan(text: 'Shop', style: TextStyle(color: AppColors.secondaryPink)),
          TextSpan(text: 'Hub', style: TextStyle(color: AppColors.primaryBlue)),
        ],
      ),
    );

    if (isVertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [logoMark, SizedBox(height: fontSize * 0.5), logoText],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [logoMark, const SizedBox(width: 10), logoText],
    );
  }
}
