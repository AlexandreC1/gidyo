import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/booking_entity.dart';

class BookingRemoteDatasource {
  final SupabaseClient _supabase;

  BookingRemoteDatasource(this._supabase);

  Future<Map<String, dynamic>> createBooking(
    BookingFormData formData,
    String paymentMethodId,
  ) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException('User not logged in');
      }

      final response = await _supabase.from('bookings').insert({
        'guide_id': formData.guideId,
        'visitor_id': userId,
        'service_id': formData.serviceId,
        'booking_date': formData.bookingDate!.toIso8601String(),
        'time_slot': formData.timeSlot,
        'number_of_participants': formData.numberOfParticipants,
        'pickup_location': formData.pickupLocation,
        'pickup_latitude': formData.pickupLatitude,
        'pickup_longitude': formData.pickupLongitude,
        'destinations': formData.destinations,
        'special_requests': formData.specialRequests,
        'service_fee': formData.serviceFee,
        'platform_fee': formData.platformFee,
        'total_amount': formData.totalAmount,
        'status': 'pending',
      }).select().single();

      return response;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<List<String>> getAvailableTimeSlots(
    String guideId,
    DateTime date,
  ) async {
    // Mock time slots for now
    return [
      '08:00 AM',
      '09:00 AM',
      '10:00 AM',
      '11:00 AM',
      '12:00 PM',
      '01:00 PM',
      '02:00 PM',
      '03:00 PM',
      '04:00 PM',
    ];
  }

  Future<String> processPayment({
    required double amount,
    required String paymentMethodId,
    required String bookingId,
  }) async {
    // Mock payment processing
    await Future.delayed(const Duration(seconds: 2));
    return 'payment_${DateTime.now().millisecondsSinceEpoch}';
  }
}
