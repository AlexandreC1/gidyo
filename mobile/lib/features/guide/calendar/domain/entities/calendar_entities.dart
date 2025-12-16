import 'package:equatable/equatable.dart';

enum DateStatus {
  available,
  booked,
  unavailable,
  blocked,
}

enum AvailabilityType {
  recurring,
  specific,
}

class CalendarDayEntity extends Equatable {
  final DateTime date;
  final DateStatus status;
  final List<BookingSlot> bookings;
  final List<TimeRange> availableSlots;
  final bool isBlocked;
  final String? blockReason;

  const CalendarDayEntity({
    required this.date,
    required this.status,
    this.bookings = const [],
    this.availableSlots = const [],
    this.isBlocked = false,
    this.blockReason,
  });

  bool get hasBookings => bookings.isNotEmpty;
  bool get isFullyBooked => status == DateStatus.booked;
  bool get isAvailable => status == DateStatus.available;

  @override
  List<Object?> get props => [
        date,
        status,
        bookings,
        availableSlots,
        isBlocked,
        blockReason,
      ];
}

class BookingSlot extends Equatable {
  final String bookingId;
  final String visitorName;
  final String? visitorAvatar;
  final String serviceType;
  final String timeSlot;
  final int numberOfParticipants;
  final String status; // confirmed, in_progress, completed

  const BookingSlot({
    required this.bookingId,
    required this.visitorName,
    this.visitorAvatar,
    required this.serviceType,
    required this.timeSlot,
    required this.numberOfParticipants,
    required this.status,
  });

  @override
  List<Object?> get props => [
        bookingId,
        visitorName,
        visitorAvatar,
        serviceType,
        timeSlot,
        numberOfParticipants,
        status,
      ];
}

class TimeRange extends Equatable {
  final String startTime; // e.g., "08:00"
  final String endTime; // e.g., "18:00"

  const TimeRange({
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [startTime, endTime];
}

class RecurringAvailability extends Equatable {
  final String id;
  final int dayOfWeek; // 1-7 (Monday-Sunday)
  final List<TimeRange> timeRanges;
  final bool isActive;

  const RecurringAvailability({
    required this.id,
    required this.dayOfWeek,
    required this.timeRanges,
    this.isActive = true,
  });

  String get dayName {
    switch (dayOfWeek) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }

  @override
  List<Object?> get props => [id, dayOfWeek, timeRanges, isActive];
}

class SpecificAvailability extends Equatable {
  final String id;
  final DateTime date;
  final List<TimeRange> timeRanges;
  final bool isActive;

  const SpecificAvailability({
    required this.id,
    required this.date,
    required this.timeRanges,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, date, timeRanges, isActive];
}

class BlockedDateRange extends Equatable {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final String? reason;
  final DateTime createdAt;

  const BlockedDateRange({
    required this.id,
    required this.startDate,
    required this.endDate,
    this.reason,
    required this.createdAt,
  });

  bool containsDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    return (dateOnly.isAtSameMomentAs(start) ||
            dateOnly.isAfter(start)) &&
        (dateOnly.isAtSameMomentAs(end) || dateOnly.isBefore(end));
  }

  int get durationInDays {
    return endDate.difference(startDate).inDays + 1;
  }

  @override
  List<Object?> get props => [id, startDate, endDate, reason, createdAt];
}

class CalendarSyncEntity extends Equatable {
  final String id;
  final String provider; // 'google' or 'apple'
  final String accountEmail;
  final bool isActive;
  final DateTime lastSyncedAt;
  final List<ExternalEvent> syncedEvents;

  const CalendarSyncEntity({
    required this.id,
    required this.provider,
    required this.accountEmail,
    required this.isActive,
    required this.lastSyncedAt,
    this.syncedEvents = const [],
  });

  @override
  List<Object?> get props => [
        id,
        provider,
        accountEmail,
        isActive,
        lastSyncedAt,
        syncedEvents,
      ];
}

class ExternalEvent extends Equatable {
  final String eventId;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;

  const ExternalEvent({
    required this.eventId,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.location,
  });

  bool occursOnDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final eventStart =
        DateTime(startTime.year, startTime.month, startTime.day);
    final eventEnd = DateTime(endTime.year, endTime.month, endTime.day);

    return (dateOnly.isAtSameMomentAs(eventStart) ||
            dateOnly.isAfter(eventStart)) &&
        (dateOnly.isAtSameMomentAs(eventEnd) || dateOnly.isBefore(eventEnd));
  }

  @override
  List<Object?> get props => [eventId, title, startTime, endTime, location];
}
