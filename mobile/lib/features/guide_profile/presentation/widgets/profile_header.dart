import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/guide_profile_entity.dart';

class ProfileHeader extends StatelessWidget {
  final GuideProfileEntity guide;
  final VoidCallback onFavoriteToggle;
  final bool isFavorite;

  const ProfileHeader({
    super.key,
    required this.guide,
    required this.onFavoriteToggle,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final images = guide.galleryImages.isNotEmpty
        ? guide.galleryImages
        : [guide.coverImageUrl ?? guide.profileImageUrl ?? ''];

    return Column(
      children: [
        // Photo Gallery / Cover
        if (images.isNotEmpty)
          Stack(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: 300,
                  viewportFraction: 1.0,
                  enableInfiniteScroll: images.length > 1,
                ),
                items: images.map((imageUrl) {
                  return CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.lightGray,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.lightGray,
                      child: const Icon(Icons.person, size: 80),
                    ),
                  );
                }).toList(),
              ),

              // Back Button
              Positioned(
                top: AppDimensions.paddingM,
                left: AppDimensions.paddingM,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              // Favorite Button
              Positioned(
                top: AppDimensions.paddingM,
                right: AppDimensions.paddingM,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? AppColors.error : AppColors.textPrimary,
                    ),
                    onPressed: onFavoriteToggle,
                  ),
                ),
              ),

              // Image Counter
              if (images.length > 1)
                Positioned(
                  bottom: AppDimensions.paddingM,
                  right: AppDimensions.paddingM,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingM,
                      vertical: AppDimensions.paddingS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                    ),
                    child: Text(
                      '${images.length} photos',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.white,
                          ),
                    ),
                  ),
                ),
            ],
          ),

        // Profile Info
        Transform.translate(
          offset: const Offset(0, -40),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gray.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Profile Photo
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: guide.profileImageUrl != null
                          ? CachedNetworkImageProvider(guide.profileImageUrl!)
                          : null,
                      backgroundColor: AppColors.accentTeal,
                      child: guide.profileImageUrl == null
                          ? Text(
                              guide.firstName[0],
                              style: const TextStyle(
                                fontSize: 40,
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    if (guide.isVerified)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified,
                            size: 24,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: AppDimensions.paddingM),

                // Name and Badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      guide.fullName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (guide.isSuperGuide) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.accentGradient,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: AppColors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Super Guide',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: AppDimensions.paddingM),

                // Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: AppColors.accentGolden, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      guide.rating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      ' (${guide.reviewCount} reviews)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.paddingM),

                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatItem(
                      icon: Icons.check_circle_outline,
                      value: '${(guide.responseRate * 100).toInt()}%',
                      label: 'Response rate',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.border,
                    ),
                    _StatItem(
                      icon: Icons.access_time,
                      value: guide.responseTime,
                      label: 'Response time',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.border,
                    ),
                    _StatItem(
                      icon: Icons.event_available,
                      value: '${guide.completedBookings}',
                      label: 'Trips completed',
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.paddingM),

                // Languages
                if (guide.languages.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    alignment: WrapAlignment.center,
                    children: guide.languages.map((lang) {
                      return Chip(
                        label: Text(lang),
                        avatar: const Icon(Icons.language, size: 16),
                        backgroundColor: AppColors.lightGray,
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.accentTeal),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
