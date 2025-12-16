import '../../domain/entities/guide_entity.dart';

class GuideModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? bio;
  final String? profileImageUrl;
  final double rating;
  final int reviewCount;
  final int completedBookings;
  final bool isVerified;
  final List<String> languages;
  final List<GuideServiceModel> services;
  final LocationModel? location;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  GuideModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.bio,
    this.profileImageUrl,
    required this.rating,
    required this.reviewCount,
    required this.completedBookings,
    required this.isVerified,
    required this.languages,
    required this.services,
    this.location,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  factory GuideModel.fromJson(Map<String, dynamic> json) {
    return GuideModel(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      bio: json['bio'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      rating: (json['average_rating'] ?? 0.0).toDouble(),
      reviewCount: json['total_reviews'] ?? 0,
      completedBookings: json['total_bookings'] ?? 0,
      isVerified: json['is_verified'] ?? false,
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      services: (json['guide_services'] as List<dynamic>?)
              ?.map((e) => GuideServiceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      location: json['location'] != null
          ? LocationModel.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'bio': bio,
      'profile_image_url': profileImageUrl,
      'average_rating': rating,
      'total_reviews': reviewCount,
      'total_bookings': completedBookings,
      'is_verified': isVerified,
      'languages': languages,
      'guide_services': services.map((e) => e.toJson()).toList(),
      'location': location?.toJson(),
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
    };
  }

  GuideEntity toEntity() {
    return GuideEntity(
      id: id,
      firstName: firstName,
      lastName: lastName,
      bio: bio,
      profileImageUrl: profileImageUrl,
      rating: rating,
      reviewCount: reviewCount,
      completedBookings: completedBookings,
      isVerified: isVerified,
      languages: languages,
      services: services.map((e) => e.toEntity()).toList(),
      location: location?.toEntity(),
      latitude: latitude,
      longitude: longitude,
      createdAt: createdAt,
    );
  }
}

class GuideServiceModel {
  final String id;
  final String serviceTypeId;
  final String serviceTypeName;
  final double price;
  final String? description;
  final bool isActive;

  GuideServiceModel({
    required this.id,
    required this.serviceTypeId,
    required this.serviceTypeName,
    required this.price,
    this.description,
    required this.isActive,
  });

  factory GuideServiceModel.fromJson(Map<String, dynamic> json) {
    return GuideServiceModel(
      id: json['id'] as String,
      serviceTypeId: json['service_type_id'] as String,
      serviceTypeName: json['service_type']?['name_en'] ?? 'Unknown',
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'] as String?,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_type_id': serviceTypeId,
      'price': price,
      'description': description,
      'is_active': isActive,
    };
  }

  GuideServiceEntity toEntity() {
    return GuideServiceEntity(
      id: id,
      serviceTypeId: serviceTypeId,
      serviceTypeName: serviceTypeName,
      price: price,
      description: description,
      isActive: isActive,
    );
  }
}

class LocationModel {
  final String city;
  final String? department;
  final String country;

  LocationModel({
    required this.city,
    this.department,
    required this.country,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      city: json['city'] as String,
      department: json['department'] as String?,
      country: json['country'] as String? ?? 'Haiti',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'department': department,
      'country': country,
    };
  }

  LocationEntity toEntity() {
    return LocationEntity(
      city: city,
      department: department,
      country: country,
    );
  }
}
