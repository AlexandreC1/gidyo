import 'package:flutter/material.dart';
import '../../../core/constants/app_animations.dart';
import 'lottie_empty_state.dart';

/// Empty state for when there are no bookings
class NoBookingsState extends StatelessWidget {
  /// Callback for the "Browse Guides" action
  final VoidCallback? onBrowseGuides;

  const NoBookingsState({
    super.key,
    this.onBrowseGuides,
  });

  @override
  Widget build(BuildContext context) {
    return LottieEmptyState(
      animationPath: AppAnimations.emptyStateAnimation,
      title: 'No Bookings Yet',
      description:
          'You haven\'t made any bookings yet. Explore our amazing guides and start your adventure in Haiti!',
      actionText: onBrowseGuides != null ? 'Browse Guides' : null,
      onAction: onBrowseGuides,
    );
  }
}
