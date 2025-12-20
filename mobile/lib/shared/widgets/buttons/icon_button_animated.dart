import 'package:flutter/material.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_colors.dart';

/// Animated icon button with various animation effects
///
/// Features:
/// - Pulse animation (for important actions)
/// - Rotation animation (for toggle states like favorite)
/// - Scale bounce on press
/// - Customizable colors and sizes
class IconButtonAnimated extends StatefulWidget {
  /// Icon to display
  final IconData icon;

  /// Callback when pressed
  final VoidCallback? onPressed;

  /// Icon color
  final Color? color;

  /// Icon size
  final double? size;

  /// Whether to show pulse animation
  final bool pulse;

  /// Whether the button is in an active/selected state (e.g., favorited)
  final bool isActive;

  /// Active state icon (e.g., filled heart)
  final IconData? activeIcon;

  /// Active state color
  final Color? activeColor;

  const IconButtonAnimated({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size,
    this.pulse = false,
    this.isActive = false,
    this.activeIcon,
    this.activeColor,
  });

  @override
  State<IconButtonAnimated> createState() => _IconButtonAnimatedState();
}

class _IconButtonAnimatedState extends State<IconButtonAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.normal,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppAnimations.bounce,
      ),
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: AppAnimations.iconPulseScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Start pulse animation if enabled
    if (widget.pulse) {
      _startPulse();
    }
  }

  @override
  void didUpdateWidget(IconButtonAnimated oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Restart or stop pulse animation based on prop change
    if (widget.pulse != oldWidget.pulse) {
      if (widget.pulse) {
        _startPulse();
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startPulse() {
    _controller.repeat(reverse: true);
  }

  void _handleTap() {
    if (widget.onPressed != null) {
      // Bounce animation
      _controller.forward().then((_) {
        _controller.reverse().then((_) {
          // Restart pulse if it was running
          if (widget.pulse) {
            _startPulse();
          }
        });
      });

      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIcon = widget.isActive && widget.activeIcon != null
        ? widget.activeIcon!
        : widget.icon;

    final currentColor = widget.isActive && widget.activeColor != null
        ? widget.activeColor!
        : (widget.color ?? AppColors.textPrimary);

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = widget.pulse ? _pulseAnimation.value : _scaleAnimation.value;

          return Transform.scale(
            scale: scale,
            child: AnimatedRotation(
              turns: widget.isActive ? 1.0 : 0.0,
              duration: AppAnimations.normal,
              curve: AppAnimations.spring,
              child: Icon(
                currentIcon,
                color: currentColor,
                size: widget.size ?? 24,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Favorite button with heart animation
class FavoriteButton extends StatelessWidget {
  /// Whether the item is favorited
  final bool isFavorite;

  /// Callback when toggled
  final VoidCallback? onToggle;

  /// Button size
  final double? size;

  const FavoriteButton({
    super.key,
    required this.isFavorite,
    this.onToggle,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return IconButtonAnimated(
      icon: Icons.favorite_border,
      activeIcon: Icons.favorite,
      isActive: isFavorite,
      color: AppColors.gray,
      activeColor: AppColors.error,
      size: size,
      onPressed: onToggle,
    );
  }
}
