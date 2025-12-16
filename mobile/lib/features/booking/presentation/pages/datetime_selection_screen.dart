import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../guide_profile/presentation/providers/guide_profile_providers.dart';
import '../providers/booking_providers.dart';

class DateTimeSelectionScreen extends ConsumerStatefulWidget {
  final String guideId;

  const DateTimeSelectionScreen({
    super.key,
    required this.guideId,
  });

  @override
  ConsumerState<DateTimeSelectionScreen> createState() =>
      _DateTimeSelectionScreenState();
}

class _DateTimeSelectionScreenState
    extends ConsumerState<DateTimeSelectionScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  int _participants = 1;

  @override
  Widget build(BuildContext context) {
    final bookingForm = ref.watch(bookingFormProvider);
    final availableAsync = _selectedDate != null
        ? ref.watch(availableTimeSlotsProvider(
            TimeSlotParams(guideId: widget.guideId, date: _selectedDate!)))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Date & Time'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          // Service Info
          _ServiceSummary(bookingForm: bookingForm),

          const SizedBox(height: AppDimensions.paddingXL),

          // Calendar
          Text(
            'Select Date',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppDimensions.paddingM),

          Card(
            child: TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                  _focusedDay = focusedDay;
                  _selectedTimeSlot = null; // Reset time slot
                });
              },
              calendarFormat: CalendarFormat.month,
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                  color: AppColors.accentTeal,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.accentTeal.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          if (_selectedDate != null) ...[
            const SizedBox(height: AppDimensions.paddingXL),

            // Time Slots
            Text(
              'Select Time',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppDimensions.paddingM),

            availableAsync?.when(
                  data: (timeSlots) => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: timeSlots.map((slot) {
                      final isSelected = _selectedTimeSlot == slot;
                      return ChoiceChip(
                        label: Text(slot),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedTimeSlot = selected ? slot : null;
                          });
                        },
                        selectedColor: AppColors.accentTeal.withOpacity(0.2),
                        checkmarkColor: AppColors.accentTeal,
                      );
                    }).toList(),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (e, s) => Text('Error loading time slots'),
                ) ??
                const SizedBox(),

            const SizedBox(height: AppDimensions.paddingXL),

            // Participants
            Text(
              'Number of Participants',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppDimensions.paddingM),

            Row(
              children: [
                IconButton(
                  onPressed: _participants > 1
                      ? () => setState(() => _participants--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  iconSize: 32,
                  color: AppColors.accentTeal,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingXL,
                    vertical: AppDimensions.paddingM,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: Text(
                    _participants.toString(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: _participants < 10
                      ? () => setState(() => _participants++)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 32,
                  color: AppColors.accentTeal,
                ),
                const Spacer(),
                Text(
                  'Max: 10',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.paddingXL),

            // Running Total
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Service Fee',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '\$${(bookingForm.servicePrice ?? 0) * _participants}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_participants} × \$${bookingForm.servicePrice?.toInt() ?? 0}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ],
      ),
      bottomNavigationBar: _selectedDate != null && _selectedTimeSlot != null
          ? _buildBottomBar()
          : null,
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
            ref.read(bookingFormProvider.notifier).setDateTime(
                  _selectedDate!,
                  _selectedTimeSlot!,
                );
            ref.read(bookingFormProvider.notifier).setParticipants(_participants);
            context.push('/booking/trip-details');
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
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bookingForm.serviceName ?? 'Service',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '\$${bookingForm.servicePrice?.toInt() ?? 0} • ${bookingForm.serviceDuration ?? ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
