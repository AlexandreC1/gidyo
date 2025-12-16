import '../../domain/entities/guide_profile_entity.dart';

class GuideProfileModel {
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
  final List<GuideServiceDetailModel> services;
  final VehicleInfoModel? vehicleInfo;
  final List<ReviewModel> recentReviews;
  final Map<int, int> ratingBreakdown;
  final List<DateTime> availableDates;
  final DateTime createdAt;

  GuideProfileModel({
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

  factory GuideProfileModel.fromJson(Map<String, dynamic> json) {
    // Parse rating breakdown
    Map<int, int> ratingBreakdown = {};
    if (json['rating_breakdown'] != null) {
      final Map<String, dynamic> breakdown = json['rating_breakdown'];
      breakdown.forEach((key, value) {
        ratingBreakdown[int.parse(key)] = value as int;
      });
    }

    return GuideProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      firstName: json['users']?['first_name'] ?? json['first_name'] ?? '',
      lastName: json['users']?['last_name'] ?? json['last_name'] ?? '',
      bio: json['bio'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      galleryImages: (json['gallery_images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      videoIntroUrl: json['video_intro_url'] as String?,
      rating: (json['average_rating'] ?? 0.0).toDouble(),
      reviewCount: json['total_reviews'] ?? 0,
      completedBookings: json['total_bookings'] ?? 0,
      isVerified: json['is_verified'] ?? false,
      isSuperGuide: json['is_super_guide'] ?? false,
      responseRate: (json['response_rate'] ?? 0.0).toDouble(),
      responseTime: json['response_time'] ?? 'Unknown',
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      yearsOfExperience: json['years_of_experience'] ?? 0,
      serviceAreas: (json['service_areas'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      services: (json['guide_services'] as List<dynamic>?)
              ?.map((e) => GuideServiceDetailModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      vehicleInfo: json['vehicle_info'] != null
          ? VehicleInfoModel.fromJson(json['vehicle_info'] as Map<String, dynamic>)
          : null,
      recentReviews: (json['reviews'] as List<dynamic>?)
              ?.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      ratingBreakdown: ratingBreakdown,
      availableDates: (json['available_dates'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  GuideProfileEntity toEntity() {
    return GuideProfileEntity(
      id: id,
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      bio: bio,
      profileImageUrl: profileImageUrl,
      coverImageUrl: coverImageUrl,
      galleryImages: galleryImages,
      videoIntroUrl: videoIntroUrl,
      rating: rating,
      reviewCount: reviewCount,
      completedBookings: completedBookings,
      isVerified: isVerified,
      isSuperGuide: isSuperGuide,
      responseRate: responseRate,
      responseTime: responseTime,
      languages: languages,
      yearsOfExperience: yearsOfExperience,
      serviceAreas: serviceAreas,
      services: services.map((e) => e.toEntity()).toList(),
      vehicleInfo: vehicleInfo?.toEntity(),
      recentReviews: recentReviews.map((e) => e.toEntity()).toList(),
      ratingBreakdown: ratingBreakdown,
      availableDates: availableDates,
      createdAt: createdAt,
    );
  }
}

class GuideServiceDetailModel {
  final String id;
  final String serviceTypeId;
  final String serviceTypeName;
  final double price;
  final String? description;
  final String duration;
  final List<String> included;
  final bool isActive;

  GuideServiceDetailModel({
    required this.id,
    required this.serviceTypeId,
    required this.serviceTypeName,
    required this.price,
    this.description,
    required this.duration,
    this.included = const [],
    required this.isActive,
  });

  factory GuideServiceDetailModel.fromJson(Map<String, dynamic> json) {
    return GuideServiceDetailModel(
      id: json['id'] as String,
      serviceTypeId: json['service_type_id'] as String,
      serviceTypeName: json['service_types']?['name_en'] ?? 'Unknown',
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'] as String?,
      duration: json['duration'] ?? '1 day',
      included: (json['included'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isActive: json['is_active'] ?? true,
    );
  }

  GuideServiceDetail toEntity() {
    return GuideServiceDetail(
      id: id,
      serviceTypeId: serviceTypeId,
      serviceTypeName: serviceTypeName,
      price: price,
      description: description,
      duration: duration,
      included: included,
      isActive: isActive,
    );
  }
}

class VehicleInfoModel {
  final String type;
  final int capacity;
  final bool hasAC;
  final List<String> photos;
  final String? plateNumber;
  final String? make;
  final String? model;
  final int? year;

  VehicleInfoModel({
    required this.type,
    required this.capacity,
    required this.hasAC,
    this.photos = const [],
    this.plateNumber,
    this.make,
    this.model,
    this.year,
  });

  factory VehicleInfoModel.fromJson(Map<String, dynamic> json) {
    return VehicleInfoModel(
      type: json['type'] as String,
      capacity: json['capacity'] ?? 4,
      hasAC: json['has_ac'] ?? false,
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      plateNumber: json['plate_number'] as String?,
      make: json['make'] as String?,
      model: json['model'] as String?,
      year: json['year'] as int?,
    );
  }

  VehicleInfo toEntity() {
    return VehicleInfo(
      type: type,
      capacity: capacity,
      hasAC: hasAC,
      photos: photos,
      plateNumber: plateNumber,
      make: make,
      model: model,
      year: year,
    );
  }
}

class ReviewModel {
  final String id;
  final String bookingId;
  final String visitorId;
  final String visitorName;
  final String? visitorAvatar;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.bookingId,
    required this.visitorId,
    required this.visitorName,
    this.visitorAvatar,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      visitorId: json['visitor_id'] as String,
      visitorName: json['visitor']?['first_name'] ?? 'Anonymous',
      visitorAvatar: json['visitor']?['profile_image_url'] as String?,
      rating: json['rating'] ?? 5,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  ReviewEntity toEntity() {
    return ReviewEntity(
      id: id,
      bookingId: bookingId,
      visitorId: visitorId,
      visitorName: visitorName,
      visitorAvatar: visitorAvatar,
      rating: rating,
      comment: comment,
      createdAt: createdAt,
    );
  }
}
