import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/booking_entity.dart';
import '../providers/booking_providers.dart';

class TripDetailsScreen extends ConsumerStatefulWidget {
  const TripDetailsScreen({super.key});

  @override
  ConsumerState<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends ConsumerState<TripDetailsScreen> {
  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();
  final _specialRequestsController = TextEditingController();
  final List<String> _destinations = [];

  @override
  void initState() {
    super.initState();
    // Load existing data from provider
    final bookingForm = ref.read(bookingFormProvider);
    if (bookingForm.pickupLocation != null) {
      _pickupController.text = bookingForm.pickupLocation!;
    }
    _destinations.addAll(bookingForm.destinations);
    if (bookingForm.specialRequests != null) {
      _specialRequestsController.text = bookingForm.specialRequests!;
    }
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  void _addDestination() {
    if (_destinationController.text.trim().isEmpty) return;

    setState(() {
      _destinations.add(_destinationController.text.trim());
      _destinationController.clear();
    });
  }

  void _removeDestination(int index) {
    setState(() {
      _destinations.removeAt(index);
    });
  }

  bool get _canContinue {
    return _pickupController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final bookingForm = ref.watch(bookingFormProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          // Service Summary
          _ServiceSummary(bookingForm: bookingForm),

          const SizedBox(height: AppDimensions.paddingXL),

          // Pickup Location
          Text(
            'Pickup Location',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppDimensions.paddingM),

          TextField(
            controller: _pickupController,
            decoration: InputDecoration(
              hintText: 'Enter pickup address',
              prefixIcon: const Icon(Icons.location_on_outlined),
              suffixIcon: IconButton(
                icon: const Icon(Icons.map),
                onPressed: () {
                  // TODO: Open map picker
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Map picker coming soon'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: AppDimensions.paddingXL),

          // Destinations
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Destinations',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Optional',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingM),

          // Add Destination Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _destinationController,
                  decoration: InputDecoration(
                    hintText: 'Add a destination',
                    prefixIcon: const Icon(Icons.add_location_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                  ),
                  onSubmitted: (_) => _addDestination(),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              IconButton(
                onPressed: _addDestination,
                icon: const Icon(Icons.add_circle),
                iconSize: 40,
                color: AppColors.accentTeal,
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingM),

          // Destinations List
          if (_destinations.isNotEmpty) ...[
            Container(
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Column(
                children: _destinations.asMap().entries.map((entry) {
                  final index = entry.key;
                  final destination = entry.value;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.accentTeal.withOpacity(0.2),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: AppColors.accentTeal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(destination),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: AppColors.error),
                      onPressed: () => _removeDestination(index),
                    ),
                  );
                }).toList(),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: Text(
                      'Add destinations you want to visit during the trip',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppDimensions.paddingXL),

          // Special Requests
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Special Requests',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Optional',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingM),

          TextField(
            controller: _specialRequestsController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  'Any special requests or requirements? (e.g., accessibility needs, dietary restrictions)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
      bottomNavigationBar: _canContinue ? _buildBottomBar() : null,
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
            // Update booking form
            ref.read(bookingFormProvider.notifier).setPickupLocation(
                  _pickupController.text.trim(),
                  null, // TODO: Add latitude from map picker
                  null, // TODO: Add longitude from map picker
                );

            // Update destinations
            final currentDestinations = ref.read(bookingFormProvider).destinations;
            // Clear and re-add all destinations
            for (var i = currentDestinations.length - 1; i >= 0; i--) {
              ref.read(bookingFormProvider.notifier).removeDestination(i);
            }
            for (var destination in _destinations) {
              ref.read(bookingFormProvider.notifier).addDestination(destination);
            }

            // Update special requests
            ref.read(bookingFormProvider.notifier).setSpecialRequests(
                  _specialRequestsController.text.trim().isEmpty
                      ? null
                      : _specialRequestsController.text.trim(),
                );

            context.push('/booking/review');
          },
          child: const Text('Continue'),
        ),
      ),
    );
  }
}

class _ServiceSummary extends StatelessWidget {
  final BookingFormData bookingForm;

  const _ServiceSummary({required this.bookingForm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: Text(
                  bookingForm.serviceName ?? 'Service',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${bookingForm.bookingDate != null ? "${bookingForm.bookingDate!.month}/${bookingForm.bookingDate!.day}/${bookingForm.bookingDate!.year}" : ""} at ${bookingForm.timeSlot ?? ""}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${bookingForm.numberOfParticipants} participant${bookingForm.numberOfParticipants > 1 ? "s" : ""} • \$${(bookingForm.servicePrice ?? 0) * bookingForm.numberOfParticipants}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
