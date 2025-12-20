import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Animated statistics card with count-up animation
///
/// Features:
/// - Number count-up animation
/// - Icon entrance animation (scale + rotate)
/// - Color transition on value change
/// - Perfect for dashboard stats
class AnimatedStatCard extends StatefulWidget {
  /// Stat title/label
  final String title;

  /// Stat value (will be animated)
  final num value;

  /// Icon to display
  final IconData icon;

  /// Icon color
  final Color iconColor;

  /// Background color
  final Color? backgroundColor;

  /// Value prefix (e.g., "$")
  final String? prefix;

  /// Value suffix (e.g., "k", "+")
  final String? suffix;

  /// Number of decimal places to show
  final int decimalPlaces;

  /// Animation delay (for staggered effect)
  final Duration? delay;

  const AnimatedStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor = AppColors.accentTeal,
    this.backgroundColor,
    this.prefix,
    this.suffix,
    this.decimalPlaces = 0,
    this.delay,
  });

  @override
  State<AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _valueAnimation;
  double _currentValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.slow,
    );

    _setupAnimation();

    // Delay animation if specified
    if (widget.delay != null) {
      Future.delayed(widget.delay!, () {
        if (mounted) {
          _controller.forward();
        }
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedStatCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _setupAnimation();
      _controller.forward(from: 0);
    }
  }

  void _setupAnimation() {
    _valueAnimation = Tween<double>(
      begin: _currentValue,
      end: widget.value.toDouble(),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppAnimations.easeInOut,
      ),
    );

    _valueAnimation.addListener(() {
      setState(() {
        _currentValue = _valueAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatValue() {
    final prefix = widget.prefix ?? '';
    final suffix = widget.suffix ?? '';
    final value = _currentValue.toStringAsFixed(widget.decimalPlaces);
    return '$prefix$value$suffix';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.backgroundColor ?? AppColors.white,
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with entrance animation
            Animate(
              effects: const [
                ScaleEffect(
                  begin: Offset(0, 0),
                  end: Offset(1, 1),
                  duration: Duration(milliseconds: 400),
                  curve: Curves.elasticOut,
                ),
                FadeEffect(
                  begin: 0,
                  end: 1,
                  duration: Duration(milliseconds: 300),
                ),
              ],
              delay: widget.delay,
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.paddingS),
                decoration: BoxDecoration(
                  color: widget.iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.iconColor,
                  size: 28,
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.paddingM),

            // Animated value
            AnimatedBuilder(
              animation: _valueAnimation,
              builder: (context, child) {
                return Text(
                  _formatValue(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                );
              },
            ),

            const SizedBox(height: 4),

            // Title
            Text(
              widget.title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid of animated stat cards with staggered animation
class AnimatedStatGrid extends StatelessWidget {
  /// List of stat cards
  final List<AnimatedStatCard> statCards;

  /// Number of columns
  final int crossAxisCount;

  /// Gap between cards
  final double gap;

  const AnimatedStatGrid({
    super.key,
    required this.statCards,
    this.crossAxisCount = 2,
    this.gap = AppDimensions.paddingM,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: gap,
        mainAxisSpacing: gap,
        childAspectRatio: 1.3,
      ),
      itemCount: statCards.length,
      itemBuilder: (context, index) {
        // Add stagger delay
        final card = statCards[index];
        return AnimatedStatCard(
          title: card.title,
          value: card.value,
          icon: card.icon,
          iconColor: card.iconColor,
          backgroundColor: card.backgroundColor,
          prefix: card.prefix,
          suffix: card.suffix,
          decimalPlaces: card.decimalPlaces,
          delay: Duration(milliseconds: index * 50), // 50ms stagger
        );
      },
    );
  }
}
