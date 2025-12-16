import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/search_params_entity.dart';
import '../../domain/repositories/search_repository.dart';
import '../models/guide_model.dart';

class SearchRemoteDatasource {
  final SupabaseClient _supabase;

  SearchRemoteDatasource(this._supabase);

  /// Search guides with filters and sorting
  Future<List<GuideModel>> searchGuides(SearchParamsEntity params) async {
    try {
      // Build the query
      var query = _supabase
          .from('guide_profiles')
          .select('''
            id,
            user_id,
            bio,
            profile_image_url,
            average_rating,
            total_reviews,
            total_bookings,
            is_verified,
            languages,
            location,
            latitude,
            longitude,
            created_at,
            users!inner(
              id,
              first_name,
              last_name
            ),
            guide_services!inner(
              id,
              service_type_id,
              price,
              description,
              is_active,
              service_types(
                name_en
              )
            )
          ''')
          .eq('is_verified', true);

      // Apply location filter
      if (params.location != null && params.location!.isNotEmpty) {
        query = query.ilike('location->>city', '%${params.location}%');
      }

      // Apply service type filter
      if (params.serviceTypeIds.isNotEmpty) {
        query = query.in_(
          'guide_services.service_type_id',
          params.serviceTypeIds,
        );
      }

      // Apply price filter
      if (params.minPrice != null) {
        query = query.gte('guide_services.price', params.minPrice!);
      }
      if (params.maxPrice != null) {
        query = query.lte('guide_services.price', params.maxPrice!);
      }

      // Apply rating filter
      if (params.minRating != null) {
        query = query.gte('average_rating', params.minRating!);
      }

      // Apply language filter
      if (params.languages.isNotEmpty) {
        query = query.overlaps('languages', params.languages);
      }

      // Execute query
      final response = await query;

      if (response == null) {
        return [];
      }

      // Convert to models
      final guides = (response as List)
          .map((json) {
            try {
              // Flatten the nested user data
              final userData = json['users'];
              final guideData = {
                ...json,
                'first_name': userData['first_name'],
                'last_name': userData['last_name'],
              };
              guideData.remove('users');

              return GuideModel.fromJson(guideData);
            } catch (e) {
              print('Error parsing guide: $e');
              return null;
            }
          })
          .whereType<GuideModel>()
          .toList();

      // Apply sorting
      _sortGuides(guides, params.sortBy, params.userLatitude, params.userLongitude);

      return guides;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Sort guides based on sort option
  void _sortGuides(
    List<GuideModel> guides,
    SortOption sortBy,
    double? userLat,
    double? userLon,
  ) {
    switch (sortBy) {
      case SortOption.rating:
        guides.sort((a, b) => b.rating.compareTo(a.rating));
        break;

      case SortOption.priceLowToHigh:
        guides.sort((a, b) {
          final aPrice = a.services.isNotEmpty ? a.services.first.price : 0;
          final bPrice = b.services.isNotEmpty ? b.services.first.price : 0;
          return aPrice.compareTo(bPrice);
        });
        break;

      case SortOption.priceHighToLow:
        guides.sort((a, b) {
          final aPrice = a.services.isNotEmpty ? a.services.first.price : 0;
          final bPrice = b.services.isNotEmpty ? b.services.first.price : 0;
          return bPrice.compareTo(aPrice);
        });
        break;

      case SortOption.distance:
        if (userLat != null && userLon != null) {
          guides.sort((a, b) {
            final aDist = _calculateDistance(
              userLat,
              userLon,
              a.latitude ?? 0,
              a.longitude ?? 0,
            );
            final bDist = _calculateDistance(
              userLat,
              userLon,
              b.latitude ?? 0,
              b.longitude ?? 0,
            );
            return aDist.compareTo(bDist);
          });
        }
        break;
    }
  }

  /// Calculate distance between two coordinates (simple Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Pi/180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  /// Get location suggestions for autocomplete
  Future<List<String>> getLocationSuggestions(String query) async {
    try {
      final response = await _supabase
          .from('guide_profiles')
          .select('location->>city')
          .ilike('location->>city', '%$query%')
          .limit(10);

      if (response == null) {
        return [];
      }

      // Extract unique cities
      final cities = (response as List)
          .map((e) => e['city'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      return cities;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Get available service types
  Future<List<ServiceTypeEntity>> getServiceTypes() async {
    try {
      final response = await _supabase
          .from('service_types')
          .select('id, name_en, name_fr, name_ht, icon_name')
          .order('name_en');

      if (response == null) {
        return [];
      }

      return (response as List).map((json) {
        return ServiceTypeEntity(
          id: json['id'] as String,
          nameEn: json['name_en'] as String,
          nameFr: json['name_fr'] as String,
          nameHt: json['name_ht'] as String,
          iconName: json['icon_name'] as String?,
        );
      }).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}

// Import math functions
import 'dart:math' show cos, sqrt, asin;
