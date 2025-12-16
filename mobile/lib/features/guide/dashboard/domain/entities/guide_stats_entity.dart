import 'package:equatable/equatable.dart';

class GuideStatsEntity extends Equatable {
  final int totalTrips;
  final double responseRate; // 0.0 to 1.0
  final double completionRate; // 0.0 to 1.0
  final double averageRating;
  final int totalReviews;
  final double thisWeekEarnings;
  final double lastWeekEarnings;
  final int pendingRequestsCount;
  final int upcomingBookingsCount;

  const GuideStatsEntity({
    required this.totalTrips,
    required this.responseRate,
    required this.completionRate,
    required this.averageRating,
    required this.totalReviews,
    required this.thisWeekEarnings,
    required this.lastWeekEarnings,
    required this.pendingRequestsCount,
    required this.upcomingBookingsCount,
  });

  double get earningsChange {
    if (lastWeekEarnings == 0) return 0;
    return ((thisWeekEarnings - lastWeekEarnings) / lastWeekEarnings) * 100;
  }

  bool get hasGoodResponseRate => responseRate >= 0.9;
  bool get hasGoodCompletionRate => completionRate >= 0.95;
  bool get hasGoodRating => averageRating >= 4.5;

  String? get performanceTip {
    if (!hasGoodResponseRate) {
      return 'Respond to booking requests within 24 hours to improve your response rate';
    }
    if (!hasGoodCompletionRate) {
      return 'Complete all confirmed bookings to improve your completion rate';
    }
    if (!hasGoodRating) {
      return 'Provide exceptional service to improve your average rating';
    }
    if (pendingRequestsCount > 0) {
      return 'You have pending booking requests. Respond quickly to secure more bookings!';
    }
    return null;
  }

  @override
  List<Object?> get props => [
        totalTrips,
        responseRate,
        completionRate,
        averageRating,
        totalReviews,
        thisWeekEarnings,
        lastWeekEarnings,
        pendingRequestsCount,
        upcomingBookingsCount,
      ];
}

class TodayBookingEntity extends Equatable {
  final String id;
  final String visitorId;
  final String visitorName;
  final String? visitorAvatar;
  final String serviceTypeName;
  final DateTime startTime;
  final String pickupLocation;
  final int numberOfParticipants;
  final String status; // pending, confirmed, in_progress, completed

  const TodayBookingEntity({
    required this.id,
    required this.visitorId,
    required this.visitorName,
    this.visitorAvatar,
    required this.serviceTypeName,
    required this.startTime,
    required this.pickupLocation,
    required this.numberOfParticipants,
    required this.status,
  });

  bool get isUpcoming => status == 'confirmed';
  bool get isInProgress => status == 'in_progress';

  @override
  List<Object?> get props => [
        id,
        visitorId,
        visitorName,
        visitorAvatar,
        serviceTypeName,
        startTime,
        pickupLocation,
        numberOfParticipants,
        status,
      ];
}

class PendingRequestEntity extends Equatable {
  final String id;
  final String visitorId;
  final String visitorName;
  final String? visitorAvatar;
  final String serviceTypeName;
  final DateTime requestedDate;
  final String requestedTimeSlot;
  final int numberOfParticipants;
  final double totalAmount;
  final DateTime requestedAt;
  final DateTime expiresAt;

  const PendingRequestEntity({
    required this.id,
    required this.visitorId,
    required this.visitorName,
    this.visitorAvatar,
    required this.serviceTypeName,
    required this.requestedDate,
    required this.requestedTimeSlot,
    required this.numberOfParticipants,
    required this.totalAmount,
    required this.requestedAt,
    required this.expiresAt,
  });

  Duration get timeRemaining {
    return expiresAt.difference(DateTime.now());
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  String get timeRemainingText {
    final duration = timeRemaining;
    if (duration.isNegative) return 'Expired';

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m remaining';
    }
    return '${minutes}m remaining';
  }

  @override
  List<Object?> get props => [
        id,
        visitorId,
        visitorName,
        visitorAvatar,
        serviceTypeName,
        requestedDate,
        requestedTimeSlot,
        numberOfParticipants,
        totalAmount,
        requestedAt,
        expiresAt,
      ];
}

class UpcomingBookingEntity extends Equatable {
  final String id;
  final String visitorId;
  final String visitorName;
  final String? visitorAvatar;
  final String serviceTypeName;
  final DateTime bookingDate;
  final String timeSlot;
  final int numberOfParticipants;
  final String pickupLocation;
  final double totalAmount;

  const UpcomingBookingEntity({
    required this.id,
    required this.visitorId,
    required this.visitorName,
    this.visitorAvatar,
    required this.serviceTypeName,
    required this.bookingDate,
    required this.timeSlot,
    required this.numberOfParticipants,
    required this.pickupLocation,
    required this.totalAmount,
  });

  bool get isToday {
    final now = DateTime.now();
    return bookingDate.year == now.year &&
        bookingDate.month == now.month &&
        bookingDate.day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return bookingDate.year == tomorrow.year &&
        bookingDate.month == tomorrow.month &&
        bookingDate.day == tomorrow.day;
  }

  @override
  List<Object?> get props => [
        id,
        visitorId,
        visitorName,
        visitorAvatar,
        serviceTypeName,
        bookingDate,
        timeSlot,
        numberOfParticipants,
        pickupLocation,
        totalAmount,
      ];
}
