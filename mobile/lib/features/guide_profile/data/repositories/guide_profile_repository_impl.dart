import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/guide_profile_entity.dart';
import '../../domain/repositories/guide_profile_repository.dart';
import '../datasources/guide_profile_remote_datasource.dart';

class GuideProfileRepositoryImpl implements GuideProfileRepository {
  final GuideProfileRemoteDatasource _remoteDatasource;

  GuideProfileRepositoryImpl(this._remoteDatasource);

  @override
  Future<Either<Failure, GuideProfileEntity>> getGuideProfile(
    String guideId,
  ) async {
    try {
      final guideModel = await _remoteDatasource.getGuideProfile(guideId);
      return Right(guideModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getGuideReviews(
    String guideId, {
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final reviewModels = await _remoteDatasource.getGuideReviews(
        guideId,
        limit: limit,
        offset: offset,
      );
      final reviewEntities = reviewModels.map((model) => model.toEntity()).toList();
      return Right(reviewEntities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DateTime>>> getGuideAvailability(
    String guideId,
    DateTime month,
  ) async {
    try {
      final availableDates = await _remoteDatasource.getGuideAvailability(
        guideId,
        month,
      );
      return Right(availableDates);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToFavorites(String guideId) async {
    try {
      await _remoteDatasource.addToFavorites(guideId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromFavorites(String guideId) async {
    try {
      await _remoteDatasource.removeFromFavorites(guideId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isInFavorites(String guideId) async {
    try {
      final isFavorite = await _remoteDatasource.isInFavorites(guideId);
      return Right(isFavorite);
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }
}
