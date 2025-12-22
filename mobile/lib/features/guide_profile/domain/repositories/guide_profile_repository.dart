import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/guide_profile_entity.dart';

abstract class GuideProfileRepository {
  /// Get guide profile by ID
  Future<Either<Failure, GuideProfileEntity>> getGuideProfile(String guideId);

  /// Get all reviews for a guide
  Future<Either<Failure, List<ReviewEntity>>> getGuideReviews(
    String guideId, {
    int limit = 10,
    int offset = 0,
  });

  /// Get guide availability for a specific month
  Future<Either<Failure, List<DateTime>>> getGuideAvailability(
    String guideId,
    DateTime month,
  );

  /// Add guide to favorites
  Future<Either<Failure, void>> addToFavorites(String guideId);

  /// Remove guide from favorites
  Future<Either<Failure, void>> removeFromFavorites(String guideId);

  /// Check if guide is in favorites
  Future<Either<Failure, bool>> isInFavorites(String guideId);
}
