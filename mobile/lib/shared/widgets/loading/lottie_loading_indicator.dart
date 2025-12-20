import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_colors.dart';

/// Lottie-based loading indicator
///
/// Replaces CircularProgressIndicator with a more engaging
/// Lottie animation for loading states
class LottieLoadingIndicator extends StatelessWidget {
  /// Size of the loading animation
  final double size;

  /// Whether to show a message below the animation
  final String? message;

  /// Whether to center the indicator
  final bool centered;

  const LottieLoadingIndicator({
    super.key,
    this.size = AppAnimations.lottieSizeSmall,
    this.message,
    this.centered = true,
  });

  /// Small loading indicator (100px)
  factory LottieLoadingIndicator.small({String? message}) {
    return LottieLoadingIndicator(
      size: AppAnimations.lottieSizeSmall,
      message: message,
    );
  }

  /// Medium loading indicator (150px)
  factory LottieLoadingIndicator.medium({String? message}) {
    return LottieLoadingIndicator(
      size: AppAnimations.lottieSizeMedium,
      message: message,
    );
  }

  /// Large loading indicator (200px)
  factory LottieLoadingIndicator.large({String? message}) {
    return LottieLoadingIndicator(
      size: AppAnimations.lottieSizeLarge,
      message: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Lottie animation
        Lottie.asset(
          AppAnimations.loadingAnimation,
          width: size,
          height: size,
          fit: BoxFit.contain,
          // Fallback to circular progress indicator if Lottie fails to load
          frameBuilder: (context, child, composition) {
            if (composition != null) {
              return child;
            }
            return SizedBox(
              width: size,
              height: size,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentTeal),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            // Fallback to circular progress indicator on error
            return SizedBox(
              width: size,
              height: size,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentTeal),
                ),
              ),
            );
          },
        ),

        // Optional message
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (centered) {
      return Center(child: content);
    }

    return content;
  }
}
