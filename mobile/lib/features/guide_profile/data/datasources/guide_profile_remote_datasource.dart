import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/guide_profile_model.dart';

class GuideProfileRemoteDatasource {
  final SupabaseClient _supabase;

  GuideProfileRemoteDatasource(this._supabase);

  /// Get guide profile by ID
  Future<GuideProfileModel> getGuideProfile(String guideId) async {
    try {
      final response = await _supabase
          .from('guide_profiles')
          .select('''
            *,
            users!inner(
              id,
              first_name,
              last_name
            ),
            guide_services(
              id,
              service_type_id,
              price,
              description,
              duration,
              included,
              is_active,
              service_types(
                name_en
              )
            ),
            reviews(
              id,
              booking_id,
              visitor_id,
              rating,
              comment,
              created_at,
              visitor:visitor_profiles(
                user_id,
                users(
                  first_name,
                  profile_image_url
                )
              )
            )
          ''')
          .eq('id', guideId)
          .single();

      if (response == null) {
        throw const ServerException('Guide not found');
      }

      // Fetch availability separately
      final availabilityResponse = await _supabase
          .from('guide_availability')
          .select('date, is_available')
          .eq('guide_id', guideId)
          .eq('is_available', true)
          .gte('date', DateTime.now().toIso8601String());

      final availableDates = (availabilityResponse as List<dynamic>?)
              ?.map((e) => e['date'] as String)
              .map((dateStr) => DateTime.parse(dateStr))
              .toList() ??
          [];

      // Add available dates to response
      final enrichedResponse = {
        ...response,
        'available_dates': availableDates.map((d) => d.toIso8601String()).toList(),
      };

      return GuideProfileModel.fromJson(enrichedResponse);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Get all reviews for a guide
  Future<List<ReviewModel>> getGuideReviews(
    String guideId, {
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select('''
            *,
            visitor:visitor_profiles!inner(
              user_id,
              users(
                first_name,
                profile_image_url
              )
            )
          ''')
          .eq('guide_id', guideId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      if (response == null) {
        return [];
      }

      return (response as List)
          .map((json) => ReviewModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Get guide availability for a specific month
  Future<List<DateTime>> getGuideAvailability(
    String guideId,
    DateTime month,
  ) async {
    try {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0);

      final response = await _supabase
          .from('guide_availability')
          .select('date')
          .eq('guide_id', guideId)
          .eq('is_available', true)
          .gte('date', startOfMonth.toIso8601String())
          .lte('date', endOfMonth.toIso8601String());

      if (response == null) {
        return [];
      }

      return (response as List)
          .map((e) => DateTime.parse(e['date'] as String))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Add guide to favorites
  Future<void> addToFavorites(String guideId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException('User not logged in');
      }

      await _supabase.from('saved_guides').insert({
        'visitor_id': userId,
        'guide_id': guideId,
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Remove guide from favorites
  Future<void> removeFromFavorites(String guideId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException('User not logged in');
      }

      await _supabase
          .from('saved_guides')
          .delete()
          .eq('visitor_id', userId)
          .eq('guide_id', guideId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Check if guide is in favorites
  Future<bool> isInFavorites(String guideId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return false;
      }

      final response = await _supabase
          .from('saved_guides')
          .select('id')
          .eq('visitor_id', userId)
          .eq('guide_id', guideId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }
}
