import 'package:flutter/material.dart';
import '../../../core/constants/app_animations.dart';
import 'lottie_empty_state.dart';

/// Empty state for when search returns no results
class NoSearchResultsState extends StatelessWidget {
  /// The search query that returned no results
  final String? query;

  /// Callback for the "Clear Filters" action
  final VoidCallback? onClearFilters;

  const NoSearchResultsState({
    super.key,
    this.query,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final description = query != null
        ? 'We couldn\'t find any guides matching "$query". Try adjusting your search or filters.'
        : 'We couldn\'t find any guides matching your criteria. Try adjusting your filters.';

    return LottieEmptyState(
      animationPath: AppAnimations.searchAnimation,
      title: 'No Results Found',
      description: description,
      actionText: onClearFilters != null ? 'Clear Filters' : null,
      onAction: onClearFilters,
      loop: true,
    );
  }
}
