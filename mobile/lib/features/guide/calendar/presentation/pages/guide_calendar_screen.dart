import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';

class GuideCalendarScreen extends ConsumerStatefulWidget {
  const GuideCalendarScreen({super.key});

  @override
  ConsumerState<GuideCalendarScreen> createState() => _GuideCalendarScreenState();
}

class _GuideCalendarScreenState extends ConsumerState<GuideCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Mock availability data
  final Map<DateTime, String> _availability = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _initializeMockData();
  }

  void _initializeMockData() {
    // Mock some available/unavailable/booked days
    final today = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final day = today.add(Duration(days: i));
      final normalizedDay = DateTime(day.year, day.month, day.day);

      if (i % 5 == 0) {
        _availability[normalizedDay] = 'booked';
      } else if (i % 3 == 0) {
        _availability[normalizedDay] = 'unavailable';
      } else {
        _availability[normalizedDay] = 'available';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Availability Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showLegend(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar
          Card(
            margin: const EdgeInsets.all(AppDimensions.paddingM),
            child: TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                  color: AppColors.accentTeal,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.accentTeal.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppColors.accentGolden,
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  final normalizedDate = DateTime(date.year, date.month, date.day);
                  final status = _availability[normalizedDate];

                  if (status == null) return null;

                  Color markerColor;
                  switch (status) {
                    case 'booked':
                      markerColor = AppColors.error;
                      break;
                    case 'unavailable':
                      markerColor = AppColors.textSecondary;
                      break;
                    case 'available':
                      markerColor = AppColors.success;
                      break;
                    default:
                      return null;
                  }

                  return Positioned(
                    bottom: 1,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: markerColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LegendItem(
                  color: AppColors.success,
                  label: 'Available',
                ),
                _LegendItem(
                  color: AppColors.error,
                  label: 'Booked',
                ),
                _LegendItem(
                  color: AppColors.textSecondary,
                  label: 'Unavailable',
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.paddingL),

          // Selected Day Info
          if (_selectedDay != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
              child: _SelectedDayCard(
                date: _selectedDay!,
                status: _availability[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] ?? 'available',
                onStatusChange: (newStatus) {
                  setState(() {
                    _availability[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] = newStatus;
                  });
                },
              ),
            ),
          ],

          const Spacer(),

          // Quick Actions
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _bulkUpdateAvailability(context, 'available');
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Mark Range Available'),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _bulkUpdateAvailability(context, 'unavailable');
                    },
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Mark Range Unavailable'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLegend(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calendar Legend'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LegendExplanation(
              color: AppColors.success,
              title: 'Available',
              description: 'You are available for bookings on this day',
            ),
            const SizedBox(height: AppDimensions.paddingM),
            _LegendExplanation(
              color: AppColors.error,
              title: 'Booked',
              description: 'You have confirmed bookings on this day',
            ),
            const SizedBox(height: AppDimensions.paddingM),
            _LegendExplanation(
              color: AppColors.textSecondary,
              title: 'Unavailable',
              description: 'You have marked yourself as unavailable',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _bulkUpdateAvailability(BuildContext context, String status) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mark Range as ${status == 'available' ? 'Available' : 'Unavailable'}'),
        content: const Text('This feature allows you to select a date range. Coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _LegendExplanation extends StatelessWidget {
  final Color color;
  final String title;
  final String description;

  const _LegendExplanation({
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SelectedDayCard extends StatelessWidget {
  final DateTime date;
  final String status;
  final Function(String) onStatusChange;

  const _SelectedDayCard({
    required this.date,
    required this.status,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = '${_getMonthName(date.month)} ${date.day}, ${date.year}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateStr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              'Status:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppDimensions.paddingS),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Available'),
                  selected: status == 'available',
                  onSelected: (selected) {
                    if (selected) onStatusChange('available');
                  },
                  selectedColor: AppColors.success.withOpacity(0.3),
                ),
                ChoiceChip(
                  label: const Text('Unavailable'),
                  selected: status == 'unavailable',
                  onSelected: (selected) {
                    if (selected) onStatusChange('unavailable');
                  },
                  selectedColor: AppColors.textSecondary.withOpacity(0.3),
                ),
                if (status == 'booked')
                  ChoiceChip(
                    label: const Text('Booked'),
                    selected: true,
                    onSelected: null, // Cannot change booked status
                    selectedColor: AppColors.error.withOpacity(0.3),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
