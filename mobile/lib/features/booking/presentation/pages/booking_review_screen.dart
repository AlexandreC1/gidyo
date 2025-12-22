import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/booking_entity.dart';
import '../providers/booking_providers.dart';

class BookingReviewScreen extends ConsumerStatefulWidget {
  const BookingReviewScreen({super.key});

  @override
  ConsumerState<BookingReviewScreen> createState() =>
      _BookingReviewScreenState();
}

class _BookingReviewScreenState extends ConsumerState<BookingReviewScreen> {
  bool _termsAccepted = false;

  @override
  void initState() {
    super.initState();
    _termsAccepted = ref.read(bookingFormProvider).termsAccepted;
  }

  @override
  Widget build(BuildContext context) {
    final bookingForm = ref.watch(bookingFormProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Booking'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          // Guide Info
          _GuideCard(bookingForm: bookingForm),

          const SizedBox(height: AppDimensions.paddingL),

          // Service Details
          _SectionCard(
            title: 'Service Details',
            icon: Icons.tour,
            children: [
              _DetailRow(
                label: 'Service',
                value: bookingForm.serviceName ?? 'N/A',
              ),
              _DetailRow(
                label: 'Duration',
                value: bookingForm.serviceDuration ?? 'N/A',
              ),
              _DetailRow(
                label: 'Date',
                value: bookingForm.bookingDate != null
                    ? '${bookingForm.bookingDate!.month}/${bookingForm.bookingDate!.day}/${bookingForm.bookingDate!.year}'
                    : 'N/A',
              ),
              _DetailRow(
                label: 'Time',
                value: bookingForm.timeSlot ?? 'N/A',
              ),
              _DetailRow(
                label: 'Participants',
                value: '${bookingForm.numberOfParticipants} person${bookingForm.numberOfParticipants > 1 ? "s" : ""}',
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingL),

          // Location Details
          _SectionCard(
            title: 'Location Details',
            icon: Icons.location_on,
            children: [
              _DetailRow(
                label: 'Pickup',
                value: bookingForm.pickupLocation ?? 'N/A',
              ),
              if (bookingForm.destinations.isNotEmpty) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingS,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Destinations',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ...bookingForm.destinations.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundColor:
                                    AppColors.accentTeal.withOpacity(0.2),
                                child: Text(
                                  '${entry.key + 1}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.accentTeal,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: AppDimensions.paddingL),

          // Special Requests
          if (bookingForm.specialRequests != null &&
              bookingForm.specialRequests!.isNotEmpty) ...[
            _SectionCard(
              title: 'Special Requests',
              icon: Icons.notes,
              children: [
                Text(
                  bookingForm.specialRequests!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingL),
          ],

          // Price Breakdown
          _PriceBreakdown(bookingForm: bookingForm),

          const SizedBox(height: AppDimensions.paddingXL),

          // Terms & Conditions
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border: Border.all(
                color: _termsAccepted
                    ? AppColors.accentTeal
                    : AppColors.border,
                width: _termsAccepted ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                CheckboxListTile(
                  value: _termsAccepted,
                  onChanged: (value) {
                    setState(() {
                      _termsAccepted = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        const TextSpan(text: 'I agree to the '),
                        TextSpan(
                          text: 'Terms & Conditions',
                          style: TextStyle(
                            color: AppColors.accentTeal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Cancellation Policy',
                          style: TextStyle(
                            color: AppColors.accentTeal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  activeColor: AppColors.accentTeal,
                ),
                if (_termsAccepted) ...[
                  const Divider(),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Free cancellation up to 24 hours before the trip',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
      bottomNavigationBar: _termsAccepted ? _buildBottomBar() : null,
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
            ref
                .read(bookingFormProvider.notifier)
                .setTermsAccepted(_termsAccepted);
            context.push('/booking/payment');
          },
          child: const Text('Continue to Payment'),
        ),
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  final BookingFormData bookingForm;

  const _GuideCard({required this.bookingForm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.accentTeal, size: 20),
              const SizedBox(width: AppDimensions.paddingS),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingM),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceBreakdown extends StatelessWidget {
  final BookingFormData bookingForm;

  const _PriceBreakdown({required this.bookingForm});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, color: AppColors.accentTeal, size: 20),
              const SizedBox(width: AppDimensions.paddingS),
              Text(
                'Price Breakdown',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingM),
          _PriceRow(
            label:
                '${bookingForm.numberOfParticipants} × \$${bookingForm.servicePrice?.toInt() ?? 0}',
            value: '\$${bookingForm.serviceFee.toStringAsFixed(2)}',
            isSubtotal: true,
          ),
          _PriceRow(
            label: 'Platform Fee (10%)',
            value: '\$${bookingForm.platformFee.toStringAsFixed(2)}',
            isSubtotal: true,
          ),
          const Divider(thickness: 2),
          _PriceRow(
            label: 'Total',
            value: '\$${bookingForm.totalAmount.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isSubtotal;
  final bool isTotal;

  const _PriceRow({
    required this.label,
    required this.value,
    this.isSubtotal = false,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: isTotal ? AppDimensions.paddingS : AppDimensions.paddingXS,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isTotal ? null : AppColors.textSecondary,
                  fontWeight: isTotal ? FontWeight.bold : null,
                  fontSize: isTotal ? 18 : null,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isTotal ? AppColors.accentTeal : null,
                  fontSize: isTotal ? 20 : null,
                ),
          ),
        ],
      ),
    );
  }
}
