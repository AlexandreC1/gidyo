import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Glassmorphic card with blur and transparency effects
///
/// Creates a modern frosted glass effect with customizable
/// blur strength, opacity, and border
class GlassmorphicCardWidget extends StatelessWidget {
  /// Card child content
  final Widget child;

  /// Card width
  final double? width;

  /// Card height
  final double? height;

  /// Border radius
  final double borderRadius;

  /// Blur strength (0-40, default 20)
  final double blur;

  /// Card opacity (0-1, default 0.2)
  final double opacity;

  /// Border width
  final double borderWidth;

  /// Border opacity (0-1, default 0.2)
  final double borderOpacity;

  /// Padding inside the card
  final EdgeInsets? padding;

  /// Margin around the card
  final EdgeInsets? margin;

  /// Border gradient colors
  final LinearGradient? borderGradient;

  /// Card alignment
  final AlignmentGeometry? alignment;

  const GlassmorphicCardWidget({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = AppDimensions.radiusL,
    this.blur = 20,
    this.opacity = 0.2,
    this.borderWidth = 1.5,
    this.borderOpacity = 0.2,
    this.padding,
    this.margin,
    this.borderGradient,
    this.alignment,
  });

  /// Light glass preset (10% opacity, 10 blur)
  factory GlassmorphicCardWidget.light({
    required Widget child,
    double? width,
    double? height,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return GlassmorphicCardWidget(
      child: child,
      width: width,
      height: height,
      blur: 10,
      opacity: 0.1,
      padding: padding,
      margin: margin,
    );
  }

  /// Medium glass preset (20% opacity, 20 blur)
  factory GlassmorphicCardWidget.medium({
    required Widget child,
    double? width,
    double? height,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return GlassmorphicCardWidget(
      child: child,
      width: width,
      height: height,
      blur: 20,
      opacity: 0.2,
      padding: padding,
      margin: margin,
    );
  }

  /// Dark glass preset (30% opacity, 30 blur)
  factory GlassmorphicCardWidget.dark({
    required Widget child,
    double? width,
    double? height,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return GlassmorphicCardWidget(
      child: child,
      width: width,
      height: height,
      blur: 30,
      opacity: 0.3,
      padding: padding,
      margin: margin,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: GlassmorphicContainer(
        width: width ?? double.infinity,
        height: height ?? 200.0,
        borderRadius: borderRadius,
        blur: blur,
        alignment: alignment ?? Alignment.center,
        border: borderWidth,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.white.withOpacity(opacity),
            AppColors.white.withOpacity(opacity * 0.5),
          ],
        ),
        borderGradient: borderGradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.white.withOpacity(borderOpacity),
                AppColors.white.withOpacity(borderOpacity * 0.5),
              ],
            ),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppDimensions.paddingM),
          child: child,
        ),
      ),
    );
  }
}
