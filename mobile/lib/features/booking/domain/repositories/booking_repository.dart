import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/booking_entity.dart';

abstract class BookingRepository {
  /// Create a new booking
  Future<Either<Failure, BookingEntity>> createBooking(
    BookingFormData formData,
    String paymentMethodId,
  );

  /// Get booking by ID
  Future<Either<Failure, BookingEntity>> getBooking(String bookingId);

  /// Get user's bookings
  Future<Either<Failure, List<BookingEntity>>> getUserBookings({
    BookingStatus? status,
    int limit = 20,
    int offset = 0,
  });

  /// Cancel booking
  Future<Either<Failure, void>> cancelBooking(
    String bookingId,
    String reason,
  );

  /// Get available time slots for a date
  Future<Either<Failure, List<String>>> getAvailableTimeSlots(
    String guideId,
    DateTime date,
  );

  /// Get saved payment methods
  Future<Either<Failure, List<PaymentMethodEntity>>> getPaymentMethods();

  /// Add payment method
  Future<Either<Failure, PaymentMethodEntity>> addPaymentMethod({
    required String type,
    String? cardToken,
    String? moncashNumber,
  });

  /// Process payment
  Future<Either<Failure, String>> processPayment({
    required double amount,
    required String paymentMethodId,
    required String bookingId,
  });
}
