import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';

class GuideBookingsScreen extends ConsumerStatefulWidget {
  const GuideBookingsScreen({super.key});

  @override
  ConsumerState<GuideBookingsScreen> createState() => _GuideBookingsScreenState();
}

class _GuideBookingsScreenState extends ConsumerState<GuideBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.accentTeal,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.accentTeal,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _BookingsList(status: 'pending'),
          _BookingsList(status: 'upcoming'),
          _BookingsList(status: 'completed'),
          _BookingsList(status: 'cancelled'),
        ],
      ),
    );
  }
}

class _BookingsList extends StatelessWidget {
  final String status;

  const _BookingsList({required this.status});

  @override
  Widget build(BuildContext context) {
    // Mock data
    final bookings = List.generate(
      status == 'pending' ? 2 : status == 'upcoming' ? 3 : 5,
      (index) => _BookingData(
        id: 'GDY-${20241213 + index}',
        visitorName: 'Visitor ${index + 1}',
        visitorAvatar: '',
        service: index % 2 == 0 ? 'City Tour' : 'Airport Pickup',
        date: 'Dec ${15 + index}, 2024',
        time: '${10 + index}:00 AM',
        duration: '${2 + index} hours',
        location: 'Port-au-Prince',
        price: 100 + (index * 20),
        status: status,
        visitorPhone: '+1 (555) 123-456$index',
        specialRequests: index % 2 == 0 ? 'Need wheelchair accessible vehicle' : null,
      ),
    );

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: AppDimensions.paddingL),
            Text(
              'No ${status} bookings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return _BookingCard(booking: bookings[index]);
      },
    );
  }
}

class _BookingCard extends StatelessWidget {
  final _BookingData booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(booking.status);
    final statusLabel = _getStatusLabel(booking.status);

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: InkWell(
        onTap: () {
          // Navigate to booking details
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    booking.id,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingM,
                      vertical: AppDimensions.paddingS,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                    ),
                    child: Text(
                      statusLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.paddingM),

              // Visitor Info
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.accentTeal,
                    child: Text(
                      booking.visitorName[0],
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.visitorName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.service,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (booking.status == 'pending' || booking.status == 'upcoming')
                    IconButton(
                      icon: const Icon(Icons.phone, color: AppColors.accentTeal),
                      onPressed: () {
                        // Call visitor
                      },
                    ),
                ],
              ),

              const SizedBox(height: AppDimensions.paddingM),

              // Details
              _DetailRow(
                icon: Icons.calendar_today,
                text: booking.date,
              ),
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.access_time,
                text: '${booking.time} • ${booking.duration}',
              ),
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.location_on,
                text: booking.location,
              ),

              if (booking.specialRequests != null) ...[
                const SizedBox(height: AppDimensions.paddingM),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.accentGolden.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(
                      color: AppColors.accentGolden.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.accentGolden,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          booking.specialRequests!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppDimensions.paddingM),

              const Divider(),

              const SizedBox(height: AppDimensions.paddingM),

              // Price and Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${booking.price}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.accentTeal,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (booking.status == 'pending')
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            _showDeclineDialog(context, booking);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingM,
                              vertical: AppDimensions.paddingS,
                            ),
                          ),
                          child: const Text('Decline'),
                        ),
                        const SizedBox(width: AppDimensions.paddingS),
                        ElevatedButton(
                          onPressed: () {
                            _showAcceptDialog(context, booking);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingM,
                              vertical: AppDimensions.paddingS,
                            ),
                          ),
                          child: const Text('Accept'),
                        ),
                      ],
                    ),
                  if (booking.status == 'upcoming')
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            // Message visitor
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingM,
                              vertical: AppDimensions.paddingS,
                            ),
                          ),
                          child: const Text('Message'),
                        ),
                        const SizedBox(width: AppDimensions.paddingS),
                        ElevatedButton(
                          onPressed: () {
                            // View details
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingM,
                              vertical: AppDimensions.paddingS,
                            ),
                          ),
                          child: const Text('Details'),
                        ),
                      ],
                    ),
                  if (booking.status == 'completed')
                    ElevatedButton.icon(
                      onPressed: () {
                        // View details
                      },
                      icon: const Icon(Icons.receipt_long, size: 18),
                      label: const Text('View Receipt'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingM,
                          vertical: AppDimensions.paddingS,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.accentGolden;
      case 'upcoming':
        return AppColors.info;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.gray;
    }
  }

  String _getStatusLabel(String status) {
    return status[0].toUpperCase() + status.substring(1);
  }

  void _showAcceptDialog(BuildContext context, _BookingData booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Booking'),
        content: Text('Accept booking from ${booking.visitorName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Accept booking
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking accepted!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _showDeclineDialog(BuildContext context, _BookingData booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Decline booking from ${booking.visitorName}?'),
            const SizedBox(height: AppDimensions.paddingM),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Reason (optional)',
                hintText: 'Let the visitor know why...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Decline booking
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking declined'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Decline'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _BookingData {
  final String id;
  final String visitorName;
  final String visitorAvatar;
  final String service;
  final String date;
  final String time;
  final String duration;
  final String location;
  final int price;
  final String status;
  final String visitorPhone;
  final String? specialRequests;

  _BookingData({
    required this.id,
    required this.visitorName,
    required this.visitorAvatar,
    required this.service,
    required this.date,
    required this.time,
    required this.duration,
    required this.location,
    required this.price,
    required this.status,
    required this.visitorPhone,
    this.specialRequests,
  });
}
