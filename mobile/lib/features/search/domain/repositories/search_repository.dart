import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/guide_entity.dart';
import '../entities/search_params_entity.dart';

abstract class SearchRepository {
  /// Search guides with filters and sorting
  Future<Either<Failure, List<GuideEntity>>> searchGuides(
    SearchParamsEntity params,
  );

  /// Get location suggestions for autocomplete
  Future<Either<Failure, List<String>>> getLocationSuggestions(String query);

  /// Get available service types
  Future<Either<Failure, List<ServiceTypeEntity>>> getServiceTypes();
}

class ServiceTypeEntity {
  final String id;
  final String nameEn;
  final String nameFr;
  final String nameHt;
  final String? iconName;

  ServiceTypeEntity({
    required this.id,
    required this.nameEn,
    required this.nameFr,
    required this.nameHt,
    this.iconName,
  });
}
