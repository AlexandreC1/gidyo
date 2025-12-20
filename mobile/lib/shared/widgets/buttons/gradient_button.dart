import 'package:flutter/material.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Gradient button with shimmer effect and scale animation
///
/// Features:
/// - Gradient background (teal to golden)
/// - Scale animation on press
/// - Optional icon
/// - Full width by default
class GradientButton extends StatefulWidget {
  /// Button text
  final String text;

  /// Button callback
  final VoidCallback? onPressed;

  /// Icon to display (optional)
  final IconData? icon;

  /// Button width (null for full width)
  final double? width;

  /// Button height
  final double height;

  /// Gradient colors (defaults to accent gradient)
  final List<Color>? gradientColors;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.width,
    this.height = AppDimensions.buttonHeightM,
    this.gradientColors,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.fast,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: AppAnimations.buttonPressScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppAnimations.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onPressed != null) {
      // Quick press animation
      _controller.forward().then((_) {
        _controller.reverse();
      });
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = widget.gradientColors ??
        const [AppColors.accentTeal, AppColors.accentGolden];

    return ScaleTransition(
      scale: _scaleAnimation,
      child: SizedBox(
        width: widget.width ?? double.infinity,
        height: widget.height,
        child: Material(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          child: InkWell(
            onTap: _handleTap,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              ),
              child: Center(
                child: _buildContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.icon,
            color: AppColors.white,
            size: 20,
          ),
          const SizedBox(width: AppDimensions.paddingS),
          Text(
            widget.text,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.text,
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
