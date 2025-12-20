import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Skeleton loading placeholder for avatar/profile pictures
///
/// Creates a circular shimmer effect placeholder for avatars
class SkeletonAvatar extends StatelessWidget {
  /// Size/radius of the avatar
  final double size;

  const SkeletonAvatar({
    super.key,
    this.size = AppDimensions.avatarM,
  });

  /// Small avatar (32px)
  factory SkeletonAvatar.small() {
    return const SkeletonAvatar(size: AppDimensions.avatarS);
  }

  /// Medium avatar (48px) - default
  factory SkeletonAvatar.medium() {
    return const SkeletonAvatar(size: AppDimensions.avatarM);
  }

  /// Large avatar (64px)
  factory SkeletonAvatar.large() {
    return const SkeletonAvatar(size: AppDimensions.avatarL);
  }

  /// Extra large avatar (96px)
  factory SkeletonAvatar.extraLarge() {
    return const SkeletonAvatar(size: AppDimensions.avatarXL);
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGray,
      highlightColor: AppColors.white,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.lightGray,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
