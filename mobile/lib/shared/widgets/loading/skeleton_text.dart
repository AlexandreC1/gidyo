import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Skeleton loading placeholder for text
///
/// Creates a shimmer effect placeholder that mimics text layout
/// while content is loading.
class SkeletonText extends StatelessWidget {
  /// Width of the skeleton text (null for full width)
  final double? width;

  /// Height of the skeleton text
  final double height;

  /// Border radius of the skeleton
  final double borderRadius;

  const SkeletonText({
    super.key,
    this.width,
    this.height = 12,
    this.borderRadius = AppDimensions.radiusS,
  });

  /// Creates a skeleton for headline text
  factory SkeletonText.headline({double? width}) {
    return SkeletonText(
      width: width ?? 200,
      height: 24,
      borderRadius: AppDimensions.radiusM,
    );
  }

  /// Creates a skeleton for title text
  factory SkeletonText.title({double? width}) {
    return SkeletonText(
      width: width ?? 150,
      height: 18,
      borderRadius: AppDimensions.radiusS,
    );
  }

  /// Creates a skeleton for body text
  factory SkeletonText.body({double? width}) {
    return SkeletonText(
      width: width ?? 250,
      height: 14,
      borderRadius: AppDimensions.radiusS,
    );
  }

  /// Creates a skeleton for caption text
  factory SkeletonText.caption({double? width}) {
    return SkeletonText(
      width: width ?? 100,
      height: 12,
      borderRadius: AppDimensions.radiusS,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGray,
      highlightColor: AppColors.white,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Multiple skeleton text lines
///
/// Creates a column of skeleton text lines with optional spacing
class SkeletonTextLines extends StatelessWidget {
  /// Number of lines to display
  final int lines;

  /// Height of each line
  final double lineHeight;

  /// Spacing between lines
  final double spacing;

  /// Width variation for each line (makes it look more natural)
  final bool varyWidth;

  const SkeletonTextLines({
    super.key,
    this.lines = 3,
    this.lineHeight = 14,
    this.spacing = 8,
    this.varyWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) {
        // Create varying widths for a more natural look
        double? width;
        if (varyWidth) {
          if (index == lines - 1) {
            width = 200; // Last line shorter
          } else {
            width = null; // Full width for other lines
          }
        }

        return Padding(
          padding: EdgeInsets.only(
            bottom: index < lines - 1 ? spacing : 0,
          ),
          child: SkeletonText(
            width: width,
            height: lineHeight,
          ),
        );
      }),
    );
  }
}
