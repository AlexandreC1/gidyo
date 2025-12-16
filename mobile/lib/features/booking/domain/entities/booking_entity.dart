import 'package:equatable/equatable.dart';

enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
}

class BookingEntity extends Equatable {
  final String id;
  final String bookingNumber;
  final String guideId;
  final String visitorId;
  final String serviceId;
  final DateTime bookingDate;
  final String? timeSlot;
  final int numberOfParticipants;
  final String? pickupLocation;
  final String? pickupLatitude;
  final String? pickupLongitude;
  final List<String> destinations;
  final String? specialRequests;
  final double serviceFee;
  final double platformFee;
  final double totalAmount;
  final BookingStatus status;
  final String? paymentId;
  final String? paymentMethod;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? completedAt;

  const BookingEntity({
    required this.id,
    required this.bookingNumber,
    required this.guideId,
    required this.visitorId,
    required this.serviceId,
    required this.bookingDate,
    this.timeSlot,
    required this.numberOfParticipants,
    this.pickupLocation,
    this.pickupLatitude,
    this.pickupLongitude,
    this.destinations = const [],
    this.specialRequests,
    required this.serviceFee,
    required this.platformFee,
    required this.totalAmount,
    required this.status,
    this.paymentId,
    this.paymentMethod,
    required this.createdAt,
    this.confirmedAt,
    this.completedAt,
  });

  @override
  List<Object?> get props => [
        id,
        bookingNumber,
        guideId,
        visitorId,
        serviceId,
        bookingDate,
        timeSlot,
        numberOfParticipants,
        pickupLocation,
        pickupLatitude,
        pickupLongitude,
        destinations,
        specialRequests,
        serviceFee,
        platformFee,
        totalAmount,
        status,
        paymentId,
        paymentMethod,
        createdAt,
        confirmedAt,
        completedAt,
      ];
}

class BookingFormData extends Equatable {
  final String? guideId;
  final String? guideName;
  final String? guideAvatar;
  final String? serviceId;
  final String? serviceName;
  final double? servicePrice;
  final String? serviceDuration;
  final DateTime? bookingDate;
  final String? timeSlot;
  final int numberOfParticipants;
  final String? pickupLocation;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final List<String> destinations;
  final String? specialRequests;
  final bool termsAccepted;

  const BookingFormData({
    this.guideId,
    this.guideName,
    this.guideAvatar,
    this.serviceId,
    this.serviceName,
    this.servicePrice,
    this.serviceDuration,
    this.bookingDate,
    this.timeSlot,
    this.numberOfParticipants = 1,
    this.pickupLocation,
    this.pickupLatitude,
    this.pickupLongitude,
    this.destinations = const [],
    this.specialRequests,
    this.termsAccepted = false,
  });

  double get serviceFee => (servicePrice ?? 0) * numberOfParticipants;
  double get platformFee => serviceFee * 0.1; // 10% platform fee
  double get totalAmount => serviceFee + platformFee;

  bool get isServiceSelected => serviceId != null;
  bool get isDateTimeSelected => bookingDate != null && timeSlot != null;
  bool get isTripDetailsComplete => pickupLocation != null;
  bool get isReadyForPayment =>
      isServiceSelected && isDateTimeSelected && isTripDetailsComplete && termsAccepted;

  BookingFormData copyWith({
    String? guideId,
    String? guideName,
    String? guideAvatar,
    String? serviceId,
    String? serviceName,
    double? servicePrice,
    String? serviceDuration,
    DateTime? bookingDate,
    String? timeSlot,
    int? numberOfParticipants,
    String? pickupLocation,
    double? pickupLatitude,
    double? pickupLongitude,
    List<String>? destinations,
    String? specialRequests,
    bool? termsAccepted,
  }) {
    return BookingFormData(
      guideId: guideId ?? this.guideId,
      guideName: guideName ?? this.guideName,
      guideAvatar: guideAvatar ?? this.guideAvatar,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      servicePrice: servicePrice ?? this.servicePrice,
      serviceDuration: serviceDuration ?? this.serviceDuration,
      bookingDate: bookingDate ?? this.bookingDate,
      timeSlot: timeSlot ?? this.timeSlot,
      numberOfParticipants: numberOfParticipants ?? this.numberOfParticipants,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      destinations: destinations ?? this.destinations,
      specialRequests: specialRequests ?? this.specialRequests,
      termsAccepted: termsAccepted ?? this.termsAccepted,
    );
  }

  @override
  List<Object?> get props => [
        guideId,
        guideName,
        guideAvatar,
        serviceId,
        serviceName,
        servicePrice,
        serviceDuration,
        bookingDate,
        timeSlot,
        numberOfParticipants,
        pickupLocation,
        pickupLatitude,
        pickupLongitude,
        destinations,
        specialRequests,
        termsAccepted,
      ];
}

class PaymentMethodEntity extends Equatable {
  final String id;
  final String type; // 'card', 'moncash'
  final String? cardLast4;
  final String? cardBrand;
  final String? cardholderName;
  final String? moncashNumber;
  final bool isDefault;

  const PaymentMethodEntity({
    required this.id,
    required this.type,
    this.cardLast4,
    this.cardBrand,
    this.cardholderName,
    this.moncashNumber,
    this.isDefault = false,
  });

  String get displayName {
    if (type == 'card') {
      return '$cardBrand •••• $cardLast4';
    } else if (type == 'moncash') {
      return 'MonCash $moncashNumber';
    }
    return 'Unknown';
  }

  @override
  List<Object?> get props => [
        id,
        type,
        cardLast4,
        cardBrand,
        cardholderName,
        moncashNumber,
        isDefault,
      ];
}
