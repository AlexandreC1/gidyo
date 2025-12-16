import 'package:equatable/equatable.dart';

enum SortOption {
  rating,
  priceLowToHigh,
  priceHighToLow,
  distance,
}

class SearchParamsEntity extends Equatable {
  final String? query;
  final String? location;
  final List<String> serviceTypeIds;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final List<String> languages;
  final String? vehicleType;
  final SortOption sortBy;
  final double? userLatitude;
  final double? userLongitude;

  const SearchParamsEntity({
    this.query,
    this.location,
    this.serviceTypeIds = const [],
    this.startDate,
    this.endDate,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.languages = const [],
    this.vehicleType,
    this.sortBy = SortOption.rating,
    this.userLatitude,
    this.userLongitude,
  });

  SearchParamsEntity copyWith({
    String? query,
    String? location,
    List<String>? serviceTypeIds,
    DateTime? startDate,
    DateTime? endDate,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    List<String>? languages,
    String? vehicleType,
    SortOption? sortBy,
    double? userLatitude,
    double? userLongitude,
  }) {
    return SearchParamsEntity(
      query: query ?? this.query,
      location: location ?? this.location,
      serviceTypeIds: serviceTypeIds ?? this.serviceTypeIds,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      languages: languages ?? this.languages,
      vehicleType: vehicleType ?? this.vehicleType,
      sortBy: sortBy ?? this.sortBy,
      userLatitude: userLatitude ?? this.userLatitude,
      userLongitude: userLongitude ?? this.userLongitude,
    );
  }

  SearchParamsEntity reset() {
    return const SearchParamsEntity();
  }

  bool get hasFilters {
    return serviceTypeIds.isNotEmpty ||
        startDate != null ||
        endDate != null ||
        minPrice != null ||
        maxPrice != null ||
        minRating != null ||
        languages.isNotEmpty ||
        vehicleType != null;
  }

  @override
  List<Object?> get props => [
        query,
        location,
        serviceTypeIds,
        startDate,
        endDate,
        minPrice,
        maxPrice,
        minRating,
        languages,
        vehicleType,
        sortBy,
        userLatitude,
        userLongitude,
      ];
}
