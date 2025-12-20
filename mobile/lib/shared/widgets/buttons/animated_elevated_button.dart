import 'package:flutter/material.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Enhanced elevated button with animations and loading/success states
///
/// Features:
/// - Scale animation on press
/// - Loading state with spinner
/// - Success state with checkmark animation
/// - Smooth state transitions
class AnimatedElevatedButton extends StatefulWidget {
  /// Button text
  final String text;

  /// Button callback
  final VoidCallback? onPressed;

  /// Loading state
  final bool isLoading;

  /// Success state
  final bool isSuccess;

  /// Icon to display (optional)
  final IconData? icon;

  /// Button width (null for expanded)
  final double? width;

  /// Button height
  final double height;

  /// Background color
  final Color? backgroundColor;

  /// Text color
  final Color? textColor;

  const AnimatedElevatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSuccess = false,
    this.icon,
    this.width,
    this.height = AppDimensions.buttonHeightM,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<AnimatedElevatedButton> createState() => _AnimatedElevatedButtonState();
}

class _AnimatedElevatedButtonState extends State<AnimatedElevatedButton>
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

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading && !widget.isSuccess) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: widget.height,
          child: ElevatedButton(
            onPressed: widget.isLoading || widget.isSuccess
                ? null
                : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: _getBackgroundColor(),
              foregroundColor: widget.textColor ?? AppColors.white,
              disabledBackgroundColor: AppColors.gray,
            ),
            child: AnimatedSwitcher(
              duration: AppAnimations.normal,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                );
              },
              child: _buildButtonContent(),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (widget.isSuccess) {
      return AppColors.success;
    }
    return widget.backgroundColor ?? AppColors.accentTeal;
  }

  Widget _buildButtonContent() {
    // Success state
    if (widget.isSuccess) {
      return const Icon(
        Icons.check_circle,
        key: ValueKey('success'),
        color: AppColors.white,
        size: 24,
      );
    }

    // Loading state
    if (widget.isLoading) {
      return const SizedBox(
        key: ValueKey('loading'),
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
        ),
      );
    }

    // Normal state
    if (widget.icon != null) {
      return Row(
        key: const ValueKey('content_with_icon'),
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: 20),
          const SizedBox(width: AppDimensions.paddingS),
          Text(widget.text),
        ],
      );
    }

    return Text(
      widget.text,
      key: const ValueKey('content'),
    );
  }
}
