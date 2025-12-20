import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import 'skeleton_text.dart';
import 'skeleton_avatar.dart';

/// Shimmer loading placeholder for guide cards
///
/// Replicates the guide card layout with shimmer effects
/// to provide visual feedback during data loading
class ShimmerGuideCard extends StatelessWidget {
  const ShimmerGuideCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Row(
          children: [
            // Avatar skeleton
            const SkeletonAvatar(size: 60),

            const SizedBox(width: AppDimensions.paddingM),

            // Info section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name skeleton
                  SkeletonText.title(width: 120),

                  const SizedBox(height: 8),

                  // Rating skeleton
                  SkeletonText.caption(width: 100),

                  const SizedBox(height: 8),

                  // Service chips skeleton
                  Row(
                    children: [
                      _ShimmerChip(),
                      const SizedBox(width: AppDimensions.paddingS),
                      _ShimmerChip(),
                    ],
                  ),
                ],
              ),
            ),

            // Price section
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Price skeleton
                SkeletonText.title(width: 50),

                const SizedBox(height: 4),

                // "per day" skeleton
                SkeletonText.caption(width: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer chip placeholder
class _ShimmerChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGray,
      highlightColor: AppColors.white,
      period: const Duration(milliseconds: 1500),
      child: Container(
        height: 24,
        width: 60,
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
        ),
      ),
    );
  }
}

/// List of shimmer guide cards
///
/// Displays multiple shimmer guide cards for loading states
class ShimmerGuideList extends StatelessWidget {
  /// Number of shimmer cards to display
  final int itemCount;

  const ShimmerGuideList({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => const ShimmerGuideCard(),
    );
  }
}
