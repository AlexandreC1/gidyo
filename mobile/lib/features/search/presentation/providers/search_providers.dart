import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client.dart';
import '../../data/datasources/search_remote_datasource.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../domain/entities/guide_entity.dart';
import '../../domain/entities/search_params_entity.dart';
import '../../domain/repositories/search_repository.dart';

// Repository Provider
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final datasource = SearchRemoteDatasource(supabase);
  return SearchRepositoryImpl(datasource);
});

// Search Params Provider
final searchParamsProvider =
    StateNotifierProvider<SearchParamsNotifier, SearchParamsEntity>((ref) {
  return SearchParamsNotifier();
});

class SearchParamsNotifier extends StateNotifier<SearchParamsEntity> {
  SearchParamsNotifier() : super(const SearchParamsEntity());

  void updateQuery(String? query) {
    state = state.copyWith(query: query);
  }

  void updateLocation(String? location) {
    state = state.copyWith(location: location);
  }

  void updateServiceTypes(List<String> serviceTypeIds) {
    state = state.copyWith(serviceTypeIds: serviceTypeIds);
  }

  void updateDateRange(DateTime? startDate, DateTime? endDate) {
    state = state.copyWith(startDate: startDate, endDate: endDate);
  }

  void updatePriceRange(double? minPrice, double? maxPrice) {
    state = state.copyWith(minPrice: minPrice, maxPrice: maxPrice);
  }

  void updateMinRating(double? minRating) {
    state = state.copyWith(minRating: minRating);
  }

  void updateLanguages(List<String> languages) {
    state = state.copyWith(languages: languages);
  }

  void updateVehicleType(String? vehicleType) {
    state = state.copyWith(vehicleType: vehicleType);
  }

  void updateSortBy(SortOption sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void updateUserLocation(double? latitude, double? longitude) {
    state = state.copyWith(
      userLatitude: latitude,
      userLongitude: longitude,
    );
  }

  void reset() {
    state = const SearchParamsEntity();
  }
}

// Search Results Provider
final searchResultsProvider =
    FutureProvider.autoDispose<List<GuideEntity>>((ref) async {
  final params = ref.watch(searchParamsProvider);
  final repository = ref.watch(searchRepositoryProvider);

  final result = await repository.searchGuides(params);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (guides) => guides,
  );
});

// Location Suggestions Provider
final locationSuggestionsProvider =
    FutureProvider.family<List<String>, String>((ref, query) async {
  if (query.isEmpty) return [];

  final repository = ref.watch(searchRepositoryProvider);
  final result = await repository.getLocationSuggestions(query);

  return result.fold(
    (failure) => <String>[],
    (locations) => locations,
  );
});

// Service Types Provider
final serviceTypesProvider =
    FutureProvider<List<ServiceTypeEntity>>((ref) async {
  final repository = ref.watch(searchRepositoryProvider);
  final result = await repository.getServiceTypes();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (serviceTypes) => serviceTypes,
  );
});

// View Mode Provider (List or Map)
enum ViewMode { list, map }

final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.list);
