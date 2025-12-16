import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../guide_profile/domain/entities/guide_profile_entity.dart';
import '../../../guide_profile/presentation/providers/guide_profile_providers.dart';
import '../providers/booking_providers.dart';

class ServiceSelectionScreen extends ConsumerStatefulWidget {
  final String guideId;

  const ServiceSelectionScreen({
    super.key,
    required this.guideId,
  });

  @override
  ConsumerState<ServiceSelectionScreen> createState() =>
      _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState
    extends ConsumerState<ServiceSelectionScreen> {
  String? _selectedServiceId;

  @override
  Widget build(BuildContext context) {
    final guideAsync = ref.watch(guideProfileProvider(widget.guideId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Service'),
      ),
      body: guideAsync.when(
        data: (guide) => _buildContent(guide),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
      bottomNavigationBar: _selectedServiceId != null
          ? _buildBottomBar()
          : null,
    );
  }

  Widget _buildContent(GuideProfileEntity guide) {
    final activeServices = guide.services.where((s) => s.isActive).toList();

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      children: [
        // Guide Info
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: guide.profileImageUrl != null
                  ? NetworkImage(guide.profileImageUrl!)
                  : null,
              child: guide.profileImageUrl == null
                  ? Text(guide.firstName[0], style: const TextStyle(fontSize: 24))
                  : null,
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guide.fullName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: AppColors.accentGolden),
                      const SizedBox(width: 4),
                      Text('${guide.rating} (${guide.reviewCount})'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.paddingXL),

        Text(
          'Choose a Service',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: AppDimensions.paddingM),

        // Services List
        ...activeServices.map((service) => _ServiceCard(
              service: service,
              isSelected: _selectedServiceId == service.id,
              onTap: () {
                setState(() {
                  _selectedServiceId = service.id;
                });
                // Update booking form
                ref.read(bookingFormProvider.notifier).setGuide(
                      guide.id,
                      guide.fullName,
                      guide.profileImageUrl,
                    );
                ref.read(bookingFormProvider.notifier).setService(
                      service.id,
                      service.serviceTypeName,
                      service.price,
                      service.duration,
                    );
              },
            )),
      ],
    );
  }

  Widget _buildBottomBar() {
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
        child: ElevatedButton(
          onPressed: () {
            context.push('/booking/datetime/${widget.guideId}');
          },
          child: const Text('Continue'),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final GuideServiceDetail service;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.service,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      color: isSelected ? AppColors.accentTeal.withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        side: BorderSide(
          color: isSelected ? AppColors.accentTeal : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Row(
            children: [
              // Selection Radio
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.accentTeal : AppColors.textSecondary,
              ),

              const SizedBox(width: AppDimensions.paddingM),

              // Service Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.serviceTypeName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.duration,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    if (service.description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        service.description!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: AppDimensions.paddingM),

              // Price
              Text(
                '\$${service.price.toInt()}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.accentTeal,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
