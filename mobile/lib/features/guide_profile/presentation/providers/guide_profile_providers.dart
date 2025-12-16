import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client.dart';
import '../../data/datasources/guide_profile_remote_datasource.dart';
import '../../data/repositories/guide_profile_repository_impl.dart';
import '../../domain/entities/guide_profile_entity.dart';
import '../../domain/repositories/guide_profile_repository.dart';

// Repository Provider
final guideProfileRepositoryProvider = Provider<GuideProfileRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final datasource = GuideProfileRemoteDatasource(supabase);
  return GuideProfileRepositoryImpl(datasource);
});

// Guide Profile Provider (Family - takes guideId as parameter)
final guideProfileProvider = FutureProvider.family<GuideProfileEntity, String>(
  (ref, guideId) async {
    final repository = ref.watch(guideProfileRepositoryProvider);
    final result = await repository.getGuideProfile(guideId);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (profile) => profile,
    );
  },
);

// All Reviews Provider
final guideReviewsProvider = FutureProvider.family<List<ReviewEntity>, String>(
  (ref, guideId) async {
    final repository = ref.watch(guideProfileRepositoryProvider);
    final result = await repository.getGuideReviews(guideId, limit: 50);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (reviews) => reviews,
    );
  },
);

// Availability Provider
final guideAvailabilityProvider = FutureProvider.family<List<DateTime>, GuideAvailabilityParams>(
  (ref, params) async {
    final repository = ref.watch(guideProfileRepositoryProvider);
    final result = await repository.getGuideAvailability(
      params.guideId,
      params.month,
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (dates) => dates,
    );
  },
);

// Favorites Provider
final isFavoriteProvider = FutureProvider.family<bool, String>(
  (ref, guideId) async {
    final repository = ref.watch(guideProfileRepositoryProvider);
    final result = await repository.isInFavorites(guideId);

    return result.fold(
      (failure) => false,
      (isFavorite) => isFavorite,
    );
  },
);

// Favorites Controller
final favoritesControllerProvider = Provider<FavoritesController>((ref) {
  return FavoritesController(ref);
});

class FavoritesController {
  final Ref _ref;

  FavoritesController(this._ref);

  Future<bool> toggleFavorite(String guideId) async {
    final repository = _ref.read(guideProfileRepositoryProvider);
    final isFavorite = await _ref.read(isFavoriteProvider(guideId).future);

    final result = isFavorite
        ? await repository.removeFromFavorites(guideId)
        : await repository.addToFavorites(guideId);

    return result.fold(
      (failure) {
        print('Error toggling favorite: ${failure.message}');
        return false;
      },
      (_) {
        // Invalidate to refetch
        _ref.invalidate(isFavoriteProvider(guideId));
        return true;
      },
    );
  }
}

// Params class for availability
class GuideAvailabilityParams {
  final String guideId;
  final DateTime month;

  GuideAvailabilityParams({
    required this.guideId,
    required this.month,
  });
}
