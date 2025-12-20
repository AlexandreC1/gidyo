import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Reusable empty state widget with Lottie animation
///
/// Displays a Lottie animation, title, description, and optional action button
/// for various empty states throughout the app
class LottieEmptyState extends StatelessWidget {
  /// Path to the Lottie animation file
  final String animationPath;

  /// Title text
  final String title;

  /// Description text (optional)
  final String? description;

  /// Action button text (optional)
  final String? actionText;

  /// Action button callback (optional)
  final VoidCallback? onAction;

  /// Size of the Lottie animation
  final double animationSize;

  /// Whether the animation should loop
  final bool loop;

  const LottieEmptyState({
    super.key,
    required this.animationPath,
    required this.title,
    this.description,
    this.actionText,
    this.onAction,
    this.animationSize = AppAnimations.lottieSizeLarge,
    this.loop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lottie animation
            Lottie.asset(
              animationPath,
              width: animationSize,
              height: animationSize,
              fit: BoxFit.contain,
              repeat: loop,
              // Fallback if animation fails to load
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.error_outline,
                  size: animationSize * 0.6,
                  color: AppColors.gray,
                );
              },
            ),

            const SizedBox(height: AppDimensions.paddingL),

            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),

            // Description
            if (description != null) ...[
              const SizedBox(height: AppDimensions.paddingM),
              Text(
                description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],

            // Action button
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppDimensions.paddingL),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
