import 'package:equatable/equatable.dart';

class GuideEntity extends Equatable {
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
  final List<GuideServiceEntity> services;
  final LocationEntity? location;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  const GuideEntity({
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

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        bio,
        profileImageUrl,
        rating,
        reviewCount,
        completedBookings,
        isVerified,
        languages,
        services,
        location,
        latitude,
        longitude,
        createdAt,
      ];
}

class GuideServiceEntity extends Equatable {
  final String id;
  final String serviceTypeId;
  final String serviceTypeName;
  final double price;
  final String? description;
  final bool isActive;

  const GuideServiceEntity({
    required this.id,
    required this.serviceTypeId,
    required this.serviceTypeName,
    required this.price,
    this.description,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        id,
        serviceTypeId,
        serviceTypeName,
        price,
        description,
        isActive,
      ];
}

class LocationEntity extends Equatable {
  final String city;
  final String? department;
  final String country;

  const LocationEntity({
    required this.city,
    this.department,
    required this.country,
  });

  String get displayName {
    if (department != null) {
      return '$city, $department';
    }
    return city;
  }

  @override
  List<Object?> get props => [city, department, country];
}
