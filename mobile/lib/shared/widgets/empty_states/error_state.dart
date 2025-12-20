import 'package:flutter/material.dart';
import '../../../core/constants/app_animations.dart';
import 'lottie_empty_state.dart';

/// Error state widget
///
/// Displays an error animation with message and retry option
class ErrorState extends StatelessWidget {
  /// Error message to display
  final String? message;

  /// Callback for the retry action
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return LottieEmptyState(
      animationPath: AppAnimations.errorAnimation,
      title: 'Oops! Something Went Wrong',
      description: message ?? 'We encountered an error. Please try again.',
      actionText: onRetry != null ? 'Try Again' : null,
      onAction: onRetry,
    );
  }
}
