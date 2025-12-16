import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client.dart';
import '../../data/datasources/booking_remote_datasource.dart';
import '../../domain/entities/booking_entity.dart';

// Datasource Provider
final bookingDatasourceProvider = Provider<BookingRemoteDatasource>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return BookingRemoteDatasource(supabase);
});

// Booking Form State Provider
final bookingFormProvider =
    StateNotifierProvider<BookingFormNotifier, BookingFormData>((ref) {
  return BookingFormNotifier();
});

class BookingFormNotifier extends StateNotifier<BookingFormData> {
  BookingFormNotifier() : super(const BookingFormData());

  void setGuide(String guideId, String guideName, String? guideAvatar) {
    state = state.copyWith(
      guideId: guideId,
      guideName: guideName,
      guideAvatar: guideAvatar,
    );
  }

  void setService(
    String serviceId,
    String serviceName,
    double servicePrice,
    String serviceDuration,
  ) {
    state = state.copyWith(
      serviceId: serviceId,
      serviceName: serviceName,
      servicePrice: servicePrice,
      serviceDuration: serviceDuration,
    );
  }

  void setDateTime(DateTime date, String timeSlot) {
    state = state.copyWith(
      bookingDate: date,
      timeSlot: timeSlot,
    );
  }

  void setParticipants(int count) {
    state = state.copyWith(numberOfParticipants: count);
  }

  void setPickupLocation(
    String location,
    double? latitude,
    double? longitude,
  ) {
    state = state.copyWith(
      pickupLocation: location,
      pickupLatitude: latitude,
      pickupLongitude: longitude,
    );
  }

  void addDestination(String destination) {
    final updated = List<String>.from(state.destinations)..add(destination);
    state = state.copyWith(destinations: updated);
  }

  void removeDestination(int index) {
    final updated = List<String>.from(state.destinations)..removeAt(index);
    state = state.copyWith(destinations: updated);
  }

  void setSpecialRequests(String? requests) {
    state = state.copyWith(specialRequests: requests);
  }

  void setTermsAccepted(bool accepted) {
    state = state.copyWith(termsAccepted: accepted);
  }

  void reset() {
    state = const BookingFormData();
  }
}

// Available Time Slots Provider
final availableTimeSlotsProvider =
    FutureProvider.family<List<String>, TimeSlotParams>((ref, params) async {
  final datasource = ref.watch(bookingDatasourceProvider);
  return await datasource.getAvailableTimeSlots(params.guideId, params.date);
});

class TimeSlotParams {
  final String guideId;
  final DateTime date;

  TimeSlotParams({required this.guideId, required this.date});
}

// Booking Submission Provider
final bookingSubmitProvider =
    StateNotifierProvider<BookingSubmitNotifier, AsyncValue<String?>>((ref) {
  return BookingSubmitNotifier(ref);
});

class BookingSubmitNotifier extends StateNotifier<AsyncValue<String?>> {
  final Ref _ref;

  BookingSubmitNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> submitBooking(String paymentMethodId) async {
    state = const AsyncValue.loading();

    try {
      final formData = _ref.read(bookingFormProvider);
      final datasource = _ref.read(bookingDatasourceProvider);

      // Create booking
      final booking = await datasource.createBooking(formData, paymentMethodId);
      final bookingId = booking['id'] as String;

      // Process payment
      final paymentId = await datasource.processPayment(
        amount: formData.totalAmount,
        paymentMethodId: paymentMethodId,
        bookingId: bookingId,
      );

      state = AsyncValue.data(bookingId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Payment Methods Provider (Mock)
final paymentMethodsProvider = Provider<List<PaymentMethodEntity>>((ref) {
  return [
    const PaymentMethodEntity(
      id: 'pm_1',
      type: 'card',
      cardBrand: 'Visa',
      cardLast4: '4242',
      cardholderName: 'John Doe',
      isDefault: true,
    ),
    const PaymentMethodEntity(
      id: 'pm_2',
      type: 'moncash',
      moncashNumber: '509 1234 5678',
    ),
  ];
});

// Selected Payment Method Provider
final selectedPaymentMethodProvider = StateProvider<String?>((ref) => null);
