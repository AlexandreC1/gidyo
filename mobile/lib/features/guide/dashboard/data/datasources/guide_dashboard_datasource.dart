import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../domain/entities/guide_stats_entity.dart';

class GuideDashboardDatasource {
  final SupabaseClient _supabase;

  GuideDashboardDatasource(this._supabase);

  Future<GuideStatsEntity> getGuideStats() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException('User not logged in');
      }

      // Get guide profile
      final profile = await _supabase
          .from('guide_profiles')
          .select('id, average_rating, total_reviews, total_bookings')
          .eq('user_id', userId)
          .single();

      final guideId = profile['id'] as String;

      // Get pending requests count
      final pendingRequests = await _supabase
          .from('bookings')
          .select('id')
          .eq('guide_id', guideId)
          .eq('status', 'pending');

      // Get upcoming bookings count
      final upcomingBookings = await _supabase
          .from('bookings')
          .select('id')
          .eq('guide_id', guideId)
          .eq('status', 'confirmed')
          .gte('booking_date', DateTime.now().toIso8601String());

      // Mock calculations for now
      final totalTrips = profile['total_bookings'] as int? ?? 0;
      final responseRate = 0.95; // TODO: Calculate from response times
      final completionRate = 0.98; // TODO: Calculate from completed bookings

      // Mock earnings
      final thisWeekEarnings = 450.0;
      final lastWeekEarnings = 380.0;

      return GuideStatsEntity(
        totalTrips: totalTrips,
        responseRate: responseRate,
        completionRate: completionRate,
        averageRating: (profile['average_rating'] as num?)?.toDouble() ?? 0.0,
        totalReviews: profile['total_reviews'] as int? ?? 0,
        thisWeekEarnings: thisWeekEarnings,
        lastWeekEarnings: lastWeekEarnings,
        pendingRequestsCount: (pendingRequests as List).length,
        upcomingBookingsCount: (upcomingBookings as List).length,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<List<TodayBookingEntity>> getTodayBookings() async {
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
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('bookings')
          .select('''
            id, visitor_id, time_slot, pickup_location, number_of_participants, status,
            booking_date,
            visitor:visitor_profiles!bookings_visitor_id_fkey(
              user_id,
              users!inner(first_name, last_name, profile_image_url)
            ),
            service:guide_services!bookings_service_id_fkey(
              service_types(name_en)
            )
          ''')
          .eq('guide_id', guideId)
          .gte('booking_date', startOfDay.toIso8601String())
          .lt('booking_date', endOfDay.toIso8601String())
          .in_('status', ['confirmed', 'in_progress'])
          .order('booking_date');

      return (response as List).map((json) {
        final visitor = json['visitor'] as Map<String, dynamic>;
        final visitorUser = visitor['users'] as Map<String, dynamic>;
        final service = json['service'] as Map<String, dynamic>;
        final serviceType = service['service_types'] as Map<String, dynamic>;

        return TodayBookingEntity(
          id: json['id'] as String,
          visitorId: json['visitor_id'] as String,
          visitorName:
              '${visitorUser['first_name']} ${visitorUser['last_name']}',
          visitorAvatar: visitorUser['profile_image_url'] as String?,
          serviceTypeName: serviceType['name_en'] as String,
          startTime: DateTime.parse(json['booking_date'] as String),
          pickupLocation: json['pickup_location'] as String? ?? 'Not specified',
          numberOfParticipants: json['number_of_participants'] as int,
          status: json['status'] as String,
        );
      }).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<List<PendingRequestEntity>> getPendingRequests() async {
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

      final response = await _supabase
          .from('bookings')
          .select('''
            id, visitor_id, booking_date, time_slot, number_of_participants,
            total_amount, created_at,
            visitor:visitor_profiles!bookings_visitor_id_fkey(
              user_id,
              users!inner(first_name, last_name, profile_image_url)
            ),
            service:guide_services!bookings_service_id_fkey(
              service_types(name_en)
            )
          ''')
          .eq('guide_id', guideId)
          .eq('status', 'pending')
          .order('created_at', ascending: false)
          .limit(10);

      return (response as List).map((json) {
        final visitor = json['visitor'] as Map<String, dynamic>;
        final visitorUser = visitor['users'] as Map<String, dynamic>;
        final service = json['service'] as Map<String, dynamic>;
        final serviceType = service['service_types'] as Map<String, dynamic>;
        final createdAt = DateTime.parse(json['created_at'] as String);
        final expiresAt = createdAt.add(const Duration(hours: 24));

        return PendingRequestEntity(
          id: json['id'] as String,
          visitorId: json['visitor_id'] as String,
          visitorName:
              '${visitorUser['first_name']} ${visitorUser['last_name']}',
          visitorAvatar: visitorUser['profile_image_url'] as String?,
          serviceTypeName: serviceType['name_en'] as String,
          requestedDate: DateTime.parse(json['booking_date'] as String),
          requestedTimeSlot: json['time_slot'] as String,
          numberOfParticipants: json['number_of_participants'] as int,
          totalAmount: (json['total_amount'] as num).toDouble(),
          requestedAt: createdAt,
          expiresAt: expiresAt,
        );
      }).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<List<UpcomingBookingEntity>> getUpcomingBookings() async {
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

      final response = await _supabase
          .from('bookings')
          .select('''
            id, visitor_id, booking_date, time_slot, number_of_participants,
            pickup_location, total_amount,
            visitor:visitor_profiles!bookings_visitor_id_fkey(
              user_id,
              users!inner(first_name, last_name, profile_image_url)
            ),
            service:guide_services!bookings_service_id_fkey(
              service_types(name_en)
            )
          ''')
          .eq('guide_id', guideId)
          .eq('status', 'confirmed')
          .gte('booking_date', DateTime.now().toIso8601String())
          .order('booking_date')
          .limit(5);

      return (response as List).map((json) {
        final visitor = json['visitor'] as Map<String, dynamic>;
        final visitorUser = visitor['users'] as Map<String, dynamic>;
        final service = json['service'] as Map<String, dynamic>;
        final serviceType = service['service_types'] as Map<String, dynamic>;

        return UpcomingBookingEntity(
          id: json['id'] as String,
          visitorId: json['visitor_id'] as String,
          visitorName:
              '${visitorUser['first_name']} ${visitorUser['last_name']}',
          visitorAvatar: visitorUser['profile_image_url'] as String?,
          serviceTypeName: serviceType['name_en'] as String,
          bookingDate: DateTime.parse(json['booking_date'] as String),
          timeSlot: json['time_slot'] as String,
          numberOfParticipants: json['number_of_participants'] as int,
          pickupLocation: json['pickup_location'] as String? ?? 'Not specified',
          totalAmount: (json['total_amount'] as num).toDouble(),
        );
      }).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> acceptBookingRequest(String bookingId) async {
    try {
      await _supabase.from('bookings').update({
        'status': 'confirmed',
        'confirmed_at': DateTime.now().toIso8601String(),
      }).eq('id', bookingId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> declineBookingRequest(String bookingId, String reason) async {
    try {
      await _supabase.from('bookings').update({
        'status': 'declined',
        'declined_at': DateTime.now().toIso8601String(),
        'decline_reason': reason,
      }).eq('id', bookingId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
