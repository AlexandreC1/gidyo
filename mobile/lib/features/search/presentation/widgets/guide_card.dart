import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/guide_entity.dart';

class GuideCard extends StatelessWidget {
  final GuideEntity guide;
  final VoidCallback? onTap;
  final bool isCompact;

  const GuideCard({
    super.key,
    required this.guide,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: InkWell(
        onTap: onTap ?? () => context.push('/guide-profile/${guide.id}'),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Guide Image
              _GuideImage(
                imageUrl: guide.profileImageUrl,
                isVerified: guide.isVerified,
                size: isCompact ? 60 : 80,
              ),

              const SizedBox(width: AppDimensions.paddingM),

              // Guide Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Verification
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            guide.fullName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (guide.isVerified)
                          const Icon(
                            Icons.verified,
                            size: 18,
                            color: AppColors.success,
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Location
                    if (guide.location != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              guide.location!.displayName,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 4),

                    // Rating and Reviews
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: AppColors.accentGolden,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${guide.rating.toStringAsFixed(1)} (${guide.reviewCount})',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.event_available,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${guide.completedBookings} trips',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),

                    if (!isCompact) ...[
                      const SizedBox(height: 8),

                      // Services
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: guide.services
                            .where((s) => s.isActive)
                            .take(2)
                            .map((service) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.lightGray,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    service.serviceTypeName,
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                ))
                            .toList(),
                      ),

                      const SizedBox(height: 8),

                      // Languages
                      if (guide.languages.isNotEmpty)
                        Row(
                          children: [
                            const Icon(
                              Icons.language,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                guide.languages.take(3).join(', '),
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ],
                ),
              ),

              // Price
              if (guide.services.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${guide.services.first.price.toInt()}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.accentTeal,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'per day',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (!isCompact) ...[
                      const SizedBox(height: 8),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideImage extends StatelessWidget {
  final String? imageUrl;
  final bool isVerified;
  final double size;

  const _GuideImage({
    required this.imageUrl,
    required this.isVerified,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          child: imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: imageUrl!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: size,
                    height: size,
                    color: AppColors.lightGray,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: size,
                    height: size,
                    color: AppColors.accentTeal,
                    child: const Icon(
                      Icons.person,
                      color: AppColors.white,
                      size: 40,
                    ),
                  ),
                )
              : Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: AppColors.accentTeal,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.white,
                    size: 40,
                  ),
                ),
        ),
        if (isVerified)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified,
                size: 16,
                color: AppColors.success,
              ),
            ),
          ),
      ],
    );
  }
}
