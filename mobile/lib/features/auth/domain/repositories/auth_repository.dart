import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Sign in with email and password
  Future<Either<Failure, UserEntity>> signInWithEmail(
    String email,
    String password,
  );

  /// Sign up with email and password
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserType userType,
    String? phone,
  });

  /// Sign in with Google
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Sign in with Apple
  Future<Either<Failure, UserEntity>> signInWithApple();

  /// Send OTP to phone
  Future<Either<Failure, void>> sendOtp(String phone);

  /// Verify OTP
  Future<Either<Failure, UserEntity>> verifyOtp(String phone, String otp);

  /// Reset password
  Future<Either<Failure, void>> resetPassword(String email);

  /// Get current user
  Future<Either<Failure, UserEntity>> getCurrentUser();

  /// Sign out
  Future<void> signOut();
}
