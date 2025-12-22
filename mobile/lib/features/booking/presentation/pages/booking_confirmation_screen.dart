import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_animations.dart';
import '../../domain/entities/booking_entity.dart';
import '../providers/booking_providers.dart';

class BookingConfirmationScreen extends ConsumerWidget {
  final String bookingId;

  const BookingConfirmationScreen({
    super.key,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingForm = ref.watch(bookingFormProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Booking Confirmed'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          children: [
            const SizedBox(height: AppDimensions.paddingXL),

            // Lottie Success Animation
            Lottie.asset(
              AppAnimations.successAnimation,
              width: AppAnimations.lottieSizeMedium,
              height: AppAnimations.lottieSizeMedium,
              repeat: false,
              // Fallback to animated icon if Lottie fails
              errorBuilder: (context, error, stackTrace) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.success.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 80,
                          color: AppColors.white,
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: AppDimensions.paddingXL),

            // Success Message with animation
            Text(
              'Booking Confirmed!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 400.ms,
                ),

            const SizedBox(height: AppDimensions.paddingM),

            Text(
              'Your adventure is booked and ready to go',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 400.ms,
                ),

            const SizedBox(height: AppDimensions.paddingXL),

            // Booking Reference with animation
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Text(
                    'Booking Reference',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppDimensions.paddingS),
                  Text(
                    '#${bookingId.substring(0, 8).toUpperCase()}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          letterSpacing: 2,
                        ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 700.ms, duration: 400.ms).scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1.0, 1.0),
                  duration: 400.ms,
                ),

            const SizedBox(height: AppDimensions.paddingXL),

            // Booking Summary
            _BookingSummaryCard(bookingForm: bookingForm),

            const SizedBox(height: AppDimensions.paddingXL),

            // Guide Contact Info
            _GuideContactCard(bookingForm: bookingForm),

            const SizedBox(height: AppDimensions.paddingXL),

            // Next Steps
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: BoxDecoration(
                color: AppColors.accentTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                border: Border.all(
                  color: AppColors.accentTeal.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.accentTeal,
                        size: 20,
                      ),
                      const SizedBox(width: AppDimensions.paddingS),
                      Text(
                        'What\'s Next?',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  _NextStepItem(
                    number: 1,
                    text: 'Your guide will receive the booking notification',
                  ),
                  _NextStepItem(
                    number: 2,
                    text: 'You\'ll receive a confirmation email shortly',
                  ),
                  _NextStepItem(
                    number: 3,
                    text: 'Message your guide to coordinate pickup details',
                  ),
                  _NextStepItem(
                    number: 4,
                    text: 'Get ready for an amazing experience!',
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.paddingXL),

            // Action Buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to chat with guide
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Messaging feature coming soon'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.message),
                    label: const Text('Message Guide'),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to booking details
                      context.go('/visitor/bookings');
                    },
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('View Booking Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accentTeal,
                      side: const BorderSide(color: AppColors.accentTeal),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                TextButton(
                  onPressed: () {
                    // Reset booking form
                    ref.read(bookingFormProvider.notifier).reset();
                    // Navigate to home
                    context.go('/visitor');
                  },
                  child: const Text('Back to Home'),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.paddingXL),
          ],
        ),
      ),
    );
  }
}

class _BookingSummaryCard extends StatelessWidget {
  final BookingFormData bookingForm;

  const _BookingSummaryCard({required this.bookingForm});

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Summary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          _SummaryRow(
            icon: Icons.tour,
            label: 'Service',
            value: bookingForm.serviceName ?? 'N/A',
          ),
          _SummaryRow(
            icon: Icons.calendar_today,
            label: 'Date',
            value: _formatDate(bookingForm.bookingDate),
          ),
          _SummaryRow(
            icon: Icons.access_time,
            label: 'Time',
            value: bookingForm.timeSlot ?? 'N/A',
          ),
          _SummaryRow(
            icon: Icons.people,
            label: 'Participants',
            value:
                '${bookingForm.numberOfParticipants} person${bookingForm.numberOfParticipants > 1 ? "s" : ""}',
          ),
          _SummaryRow(
            icon: Icons.location_on,
            label: 'Pickup',
            value: bookingForm.pickupLocation ?? 'N/A',
          ),
          const Divider(),
          _SummaryRow(
            icon: Icons.payment,
            label: 'Total Paid',
            value: '\$${bookingForm.totalAmount.toStringAsFixed(2)}',
            isHighlighted: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isHighlighted;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingS),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isHighlighted ? AppColors.accentTeal : AppColors.textSecondary,
          ),
          const SizedBox(width: AppDimensions.paddingM),
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
                  fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
                  color: isHighlighted ? AppColors.accentTeal : null,
                ),
          ),
        ],
      ),
    );
  }
}

class _GuideContactCard extends StatelessWidget {
  final BookingFormData bookingForm;

  const _GuideContactCard({required this.bookingForm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentTeal.withOpacity(0.1),
            AppColors.accentTeal.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppColors.accentTeal.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: bookingForm.guideAvatar != null
                ? NetworkImage(bookingForm.guideAvatar!)
                : null,
            child: bookingForm.guideAvatar == null
                ? Text(
                    bookingForm.guideName?.substring(0, 1) ?? 'G',
                    style: const TextStyle(fontSize: 24),
                  )
                : null,
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Guide',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                Text(
                  bookingForm.guideName ?? 'N/A',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.verified,
                      size: 16,
                      color: AppColors.accentTeal,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Verified Guide',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.accentTeal,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Navigate to chat
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Messaging feature coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.chat_bubble),
            color: AppColors.accentTeal,
            iconSize: 28,
          ),
        ],
      ),
    );
  }
}

class _NextStepItem extends StatelessWidget {
  final int number;
  final String text;

  const _NextStepItem({
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.accentTeal,
            child: Text(
              '$number',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
