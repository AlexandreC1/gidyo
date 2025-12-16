import 'package:equatable/equatable.dart';

class GuideProfileEntity extends Equatable {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String? bio;
  final String? profileImageUrl;
  final String? coverImageUrl;
  final List<String> galleryImages;
  final String? videoIntroUrl;
  final double rating;
  final int reviewCount;
  final int completedBookings;
  final bool isVerified;
  final bool isSuperGuide;
  final double responseRate;
  final String responseTime;
  final List<String> languages;
  final int yearsOfExperience;
  final List<String> serviceAreas;
  final List<GuideServiceDetail> services;
  final VehicleInfo? vehicleInfo;
  final List<ReviewEntity> recentReviews;
  final Map<int, int> ratingBreakdown;
  final List<DateTime> availableDates;
  final DateTime createdAt;

  const GuideProfileEntity({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.bio,
    this.profileImageUrl,
    this.coverImageUrl,
    this.galleryImages = const [],
    this.videoIntroUrl,
    required this.rating,
    required this.reviewCount,
    required this.completedBookings,
    required this.isVerified,
    this.isSuperGuide = false,
    required this.responseRate,
    required this.responseTime,
    required this.languages,
    this.yearsOfExperience = 0,
    this.serviceAreas = const [],
    required this.services,
    this.vehicleInfo,
    this.recentReviews = const [],
    this.ratingBreakdown = const {},
    this.availableDates = const [],
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        id,
        userId,
        firstName,
        lastName,
        bio,
        profileImageUrl,
        coverImageUrl,
        galleryImages,
        videoIntroUrl,
        rating,
        reviewCount,
        completedBookings,
        isVerified,
        isSuperGuide,
        responseRate,
        responseTime,
        languages,
        yearsOfExperience,
        serviceAreas,
        services,
        vehicleInfo,
        recentReviews,
        ratingBreakdown,
        availableDates,
        createdAt,
      ];
}

class GuideServiceDetail extends Equatable {
  final String id;
  final String serviceTypeId;
  final String serviceTypeName;
  final double price;
  final String? description;
  final String duration;
  final List<String> included;
  final bool isActive;

  const GuideServiceDetail({
    required this.id,
    required this.serviceTypeId,
    required this.serviceTypeName,
    required this.price,
    this.description,
    required this.duration,
    this.included = const [],
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        id,
        serviceTypeId,
        serviceTypeName,
        price,
        description,
        duration,
        included,
        isActive,
      ];
}

class VehicleInfo extends Equatable {
  final String type;
  final int capacity;
  final bool hasAC;
  final List<String> photos;
  final String? plateNumber;
  final String? make;
  final String? model;
  final int? year;

  const VehicleInfo({
    required this.type,
    required this.capacity,
    required this.hasAC,
    this.photos = const [],
    this.plateNumber,
    this.make,
    this.model,
    this.year,
  });

  @override
  List<Object?> get props => [
        type,
        capacity,
        hasAC,
        photos,
        plateNumber,
        make,
        model,
        year,
      ];
}

class ReviewEntity extends Equatable {
  final String id;
  final String bookingId;
  final String visitorId;
  final String visitorName;
  final String? visitorAvatar;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  const ReviewEntity({
    required this.id,
    required this.bookingId,
    required this.visitorId,
    required this.visitorName,
    this.visitorAvatar,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        bookingId,
        visitorId,
        visitorName,
        visitorAvatar,
        rating,
        comment,
        createdAt,
      ];
}
