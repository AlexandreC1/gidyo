import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../domain/entities/calendar_entities.dart';

class CalendarDatasource {
  final SupabaseClient _supabase;

  CalendarDatasource(this._supabase);

  Future<List<CalendarDayEntity>> getMonthCalendar(DateTime month) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException('User not logged in');
      }

      final profile = await _supabase
          .from('guide_profiles')
          .select('id')
          .eq('user_id', userId)
          .single();

      final guideId = profile['id'] as String;

      // Get bookings for the month
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0);

      final bookings = await _supabase
          .from('bookings')
          .select('''
            id, booking_date, time_slot, number_of_participants, status,
            visitor:visitor_profiles!bookings_visitor_id_fkey(
              users!inner(first_name, last_name, profile_image_url)
            ),
            service:guide_services!bookings_service_id_fkey(
              service_types(name_en)
            )
          ''')
          .eq('guide_id', guideId)
          .gte('booking_date', startOfMonth.toIso8601String())
          .lte('booking_date', endOfMonth.toIso8601String())
          .in_('status', ['confirmed', 'in_progress', 'completed']);

      // Get blocked dates
      final blockedDates = await _supabase
          .from('blocked_dates')
          .select()
          .eq('guide_id', guideId)
          .or('end_date.gte.${startOfMonth.toIso8601String()},start_date.lte.${endOfMonth.toIso8601String()}');

      // Build calendar days
      final days = <CalendarDayEntity>[];
      for (var day = startOfMonth;
          day.isBefore(endOfMonth.add(const Duration(days: 1)));
          day = day.add(const Duration(days: 1))) {
        final dayBookings = (bookings as List)
            .where((b) =>
                DateTime.parse(b['booking_date'] as String).day == day.day)
            .map((b) {
          final visitor = b['visitor'] as Map<String, dynamic>;
          final visitorUser = visitor['users'] as Map<String, dynamic>;
          final service = b['service'] as Map<String, dynamic>;
          final serviceType = service['service_types'] as Map<String, dynamic>;

          return BookingSlot(
            bookingId: b['id'] as String,
            visitorName:
                '${visitorUser['first_name']} ${visitorUser['last_name']}',
            visitorAvatar: visitorUser['profile_image_url'] as String?,
            serviceType: serviceType['name_en'] as String,
            timeSlot: b['time_slot'] as String,
            numberOfParticipants: b['number_of_participants'] as int,
            status: b['status'] as String,
          );
        }).toList();

        final isBlocked = (blockedDates as List).any((bd) {
          final start = DateTime.parse(bd['start_date'] as String);
          final end = DateTime.parse(bd['end_date'] as String);
          return day.isAfter(start.subtract(const Duration(days: 1))) &&
              day.isBefore(end.add(const Duration(days: 1)));
        });

        DateStatus status;
        if (isBlocked) {
          status = DateStatus.blocked;
        } else if (dayBookings.isNotEmpty) {
          status = DateStatus.booked;
        } else if (day.weekday >= 1 && day.weekday <= 7) {
          status = DateStatus.available; // Simplified
        } else {
          status = DateStatus.unavailable;
        }

        days.add(CalendarDayEntity(
          date: day,
          status: status,
          bookings: dayBookings,
          isBlocked: isBlocked,
        ));
      }

      return days;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> blockDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException('User not logged in');
      }

      final profile = await _supabase
          .from('guide_profiles')
          .select('id')
          .eq('user_id', userId)
          .single();

      await _supabase.from('blocked_dates').insert({
        'guide_id': profile['id'],
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'reason': reason,
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> saveRecurringAvailability({
    required int dayOfWeek,
    required List<TimeRange> timeRanges,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException('User not logged in');
      }

      final profile = await _supabase
          .from('guide_profiles')
          .select('id')
          .eq('user_id', userId)
          .single();

      // Simplified - save to guide profile's weekly_schedule
      await _supabase.from('guide_profiles').update({
        'weekly_schedule': {
          'day_$dayOfWeek': timeRanges
              .map((tr) => {'start': tr.startTime, 'end': tr.endTime})
              .toList(),
        }
      }).eq('id', profile['id']);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
