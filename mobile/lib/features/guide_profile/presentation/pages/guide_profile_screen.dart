import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/guide_profile_entity.dart';
import '../providers/guide_profile_providers.dart';
import '../widgets/profile_header.dart';

class GuideProfileScreen extends ConsumerStatefulWidget {
  final String guideId;

  const GuideProfileScreen({
    super.key,
    required this.guideId,
  });

  @override
  ConsumerState<GuideProfileScreen> createState() => _GuideProfileScreenState();
}

class _GuideProfileScreenState extends ConsumerState<GuideProfileScreen> {
  VideoPlayerController? _videoController;
  DateTime _focusedDay = DateTime.now();

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final guideAsync = ref.watch(guideProfileProvider(widget.guideId));
    final isFavoriteAsync = ref.watch(isFavoriteProvider(widget.guideId));

    return Scaffold(
      body: guideAsync.when(
        data: (guide) => _buildProfileContent(guide, isFavoriteAsync.value ?? false),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: AppColors.error),
              const SizedBox(height: AppDimensions.paddingL),
              Text('Error loading profile', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppDimensions.paddingM),
              ElevatedButton(
                onPressed: () => ref.invalidate(guideProfileProvider(widget.guideId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: guideAsync.maybeWhen(
        data: (guide) => _buildBottomBar(guide),
        orElse: () => null,
      ),
    );
  }

  Widget _buildProfileContent(GuideProfileEntity guide, bool isFavorite) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header with Photos and Basic Info
          ProfileHeader(
            guide: guide,
            isFavorite: isFavorite,
            onFavoriteToggle: () => _toggleFavorite(),
          ),

          // 2. Video Introduction
          if (guide.videoIntroUrl != null)
            _buildVideoSection(guide.videoIntroUrl!),

          // 3. About Section
          _buildAboutSection(guide),

          // 4. Services Offered
          _buildServicesSection(guide),

          // 5. Vehicle Info (if driver)
          if (guide.vehicleInfo != null)
            _buildVehicleSection(guide.vehicleInfo!),

          // 6. Reviews Section
          _buildReviewsSection(guide),

          // 7. Availability Calendar
          _buildAvailabilitySection(guide),

          const SizedBox(height: 100), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildVideoSection(String videoUrl) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Video Introduction',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          GestureDetector(
            onTap: () => _playVideo(videoUrl),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  ),
                  child: const Center(
                    child: Icon(Icons.videocam, size: 60, color: AppColors.textSecondary),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  decoration: BoxDecoration(
                    color: AppColors.accentTeal.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    size: 40,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(GuideProfileEntity guide) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About ${guide.firstName}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          if (guide.bio != null)
            Text(
              guide.bio!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          const SizedBox(height: AppDimensions.paddingM),
          Row(
            children: [
              const Icon(Icons.work_outline, size: 20, color: AppColors.accentTeal),
              const SizedBox(width: 8),
              Text(
                '${guide.yearsOfExperience} years of experience',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          if (guide.serviceAreas.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.paddingM),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, size: 20, color: AppColors.accentTeal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Service areas: ${guide.serviceAreas.join(', ')}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServicesSection(GuideProfileEntity guide) {
    final activeServices = guide.services.where((s) => s.isActive).toList();

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Services Offered',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          ...activeServices.map((service) => _ServiceCard(service: service)),
        ],
      ),
    );
  }

  Widget _buildVehicleSection(VehicleInfo vehicle) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vehicle Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                children: [
                  _VehicleInfoRow(
                    icon: Icons.directions_car,
                    label: 'Type',
                    value: vehicle.type,
                  ),
                  _VehicleInfoRow(
                    icon: Icons.people,
                    label: 'Capacity',
                    value: '${vehicle.capacity} passengers',
                  ),
                  _VehicleInfoRow(
                    icon: Icons.ac_unit,
                    label: 'Air Conditioning',
                    value: vehicle.hasAC ? 'Yes' : 'No',
                  ),
                  if (vehicle.make != null)
                    _VehicleInfoRow(
                      icon: Icons.info_outline,
                      label: 'Vehicle',
                      value: '${vehicle.make} ${vehicle.model ?? ''} ${vehicle.year ?? ''}',
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(GuideProfileEntity guide) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reviews (${guide.reviewCount})',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppDimensions.paddingM),

          // Rating Breakdown
          if (guide.ratingBreakdown.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: Column(
                  children: [
                    for (int star = 5; star >= 1; star--)
                      _RatingBar(
                        stars: star,
                        count: guide.ratingBreakdown[star] ?? 0,
                        total: guide.reviewCount,
                      ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: AppDimensions.paddingM),

          // Recent Reviews
          if (guide.recentReviews.isNotEmpty)
            ...guide.recentReviews.take(3).map(
                  (review) => _ReviewCard(review: review),
                ),

          // See All Reviews Button
          if (guide.reviewCount > 3)
            Center(
              child: TextButton(
                onPressed: () {
                  // Navigate to all reviews
                },
                child: const Text('See All Reviews'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySection(GuideProfileEntity guide) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Availability',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                selectedDayPredicate: (day) => false,
                onDaySelected: (selectedDay, focusedDay) {
                  // Navigate to booking with selected date
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppColors.accentTeal.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    final normalizedDate = DateTime(date.year, date.month, date.day);
                    final isAvailable = guide.availableDates.any((d) =>
                        DateTime(d.year, d.month, d.day) == normalizedDate);

                    if (isAvailable) {
                      return Positioned(
                        bottom: 1,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text('Available dates'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(GuideProfileEntity guide) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.gray.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Open messaging
                },
                icon: const Icon(Icons.message_outlined),
                label: const Text('Message'),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/booking/service/${widget.guideId}');
                },
                child: const Text('Book Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleFavorite() async {
    final controller = ref.read(favoritesControllerProvider);
    await controller.toggleFavorite(widget.guideId);
  }

  void _playVideo(String url) {
    // Implement video player
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Video Introduction'),
        content: const Text('Video player will be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final GuideServiceDetail service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    service.serviceTypeName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Text(
                  '\$${service.price.toInt()}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.accentTeal,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              service.duration,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            if (service.description != null) ...[
              const SizedBox(height: AppDimensions.paddingM),
              Text(service.description!),
            ],
            if (service.included.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.paddingM),
              Text(
                'Included:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              ...service.included.map((item) => Padding(
                    padding: const EdgeInsets.only(left: 8, top: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, size: 16, color: AppColors.success),
                        const SizedBox(width: 8),
                        Expanded(child: Text(item)),
                      ],
                    ),
                  )),
            ],
            const SizedBox(height: AppDimensions.paddingM),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Navigate to booking with this service
                },
                child: const Text('Book This Service'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _VehicleInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.accentTeal),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  final int stars;
  final int count;
  final int total;

  const _RatingBar({
    required this.stars,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (count / total) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Row(
              children: [
                Text('$stars'),
                const SizedBox(width: 4),
                const Icon(Icons.star, size: 16, color: AppColors.accentGolden),
              ],
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: AppColors.lightGray,
              valueColor: const AlwaysStoppedAnimation(AppColors.accentGolden),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 40,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewEntity review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: review.visitorAvatar != null
                      ? NetworkImage(review.visitorAvatar!)
                      : null,
                  child: review.visitorAvatar == null
                      ? Text(review.visitorName[0])
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.visitorName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (index) => Icon(
                              index < review.rating ? Icons.star : Icons.star_border,
                              size: 14,
                              color: AppColors.accentGolden,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(review.createdAt),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (review.comment != null) ...[
              const SizedBox(height: AppDimensions.paddingM),
              Text(review.comment!),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${date.month}/${date.year}';
    }
  }
}
