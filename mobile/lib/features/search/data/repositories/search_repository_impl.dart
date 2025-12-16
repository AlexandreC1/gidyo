import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/guide_entity.dart';
import '../../domain/entities/search_params_entity.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_datasource.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDatasource _remoteDatasource;

  SearchRepositoryImpl(this._remoteDatasource);

  @override
  Future<Either<Failure, List<GuideEntity>>> searchGuides(
    SearchParamsEntity params,
  ) async {
    try {
      final guideModels = await _remoteDatasource.searchGuides(params);
      final guideEntities = guideModels.map((model) => model.toEntity()).toList();
      return Right(guideEntities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getLocationSuggestions(
    String query,
  ) async {
    try {
      final locations = await _remoteDatasource.getLocationSuggestions(query);
      return Right(locations);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ServiceTypeEntity>>> getServiceTypes() async {
    try {
      final serviceTypes = await _remoteDatasource.getServiceTypes();
      return Right(serviceTypes);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }
}
