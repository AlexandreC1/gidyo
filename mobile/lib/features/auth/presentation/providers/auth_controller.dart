import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import 'auth_providers.dart';
import '../../../../core/utils/logger.dart';

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

class AuthController {
  final Ref _ref;

  AuthController(this._ref);

  /// Login with email and password
  Future<bool> loginWithEmail(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      final repository = _ref.read(authRepositoryProvider);
      final result = await repository.signInWithEmail(email, password);

      return result.fold(
        (failure) {
          _setError(failure.message);
          Logger.error('Login failed', failure.message);
          return false;
        },
        (user) {
          Logger.success('Login successful', user.email);
          return true;
        },
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Register with email and password
  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserType userType,
    String? phone,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final repository = _ref.read(authRepositoryProvider);
      final result = await repository.signUpWithEmail(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        userType: userType,
        phone: phone,
      );

      return result.fold(
        (failure) {
          _setError(failure.message);
          Logger.error('Registration failed', failure.message);
          return false;
        },
        (user) {
          Logger.success('Registration successful', user.email);
          return true;
        },
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      final repository = _ref.read(authRepositoryProvider);
      final result = await repository.signInWithGoogle();

      return result.fold(
        (failure) {
          _setError(failure.message);
          Logger.error('Google sign-in failed', failure.message);
          return false;
        },
        (user) {
          Logger.success('Google sign-in successful', user.email);
          return true;
        },
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with Apple
  Future<bool> signInWithApple() async {
    try {
      _setLoading(true);
      _clearError();

      final repository = _ref.read(authRepositoryProvider);
      final result = await repository.signInWithApple();

      return result.fold(
        (failure) {
          _setError(failure.message);
          Logger.error('Apple sign-in failed', failure.message);
          return false;
        },
        (user) {
          Logger.success('Apple sign-in successful', user.email);
          return true;
        },
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Send OTP to phone
  Future<bool> sendOtp(String phone) async {
    try {
      _setLoading(true);
      _clearError();

      final repository = _ref.read(authRepositoryProvider);
      final result = await repository.sendOtp(phone);

      return result.fold(
        (failure) {
          _setError(failure.message);
          Logger.error('Send OTP failed', failure.message);
          return false;
        },
        (_) {
          Logger.success('OTP sent to $phone');
          return true;
        },
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Verify OTP
  Future<bool> verifyOtp(String phone, String otp) async {
    try {
      _setLoading(true);
      _clearError();

      final repository = _ref.read(authRepositoryProvider);
      final result = await repository.verifyOtp(phone, otp);

      return result.fold(
        (failure) {
          _setError(failure.message);
          Logger.error('OTP verification failed', failure.message);
          return false;
        },
        (user) {
          Logger.success('OTP verified successfully');
          return true;
        },
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      final repository = _ref.read(authRepositoryProvider);
      final result = await repository.resetPassword(email);

      return result.fold(
        (failure) {
          _setError(failure.message);
          Logger.error('Password reset failed', failure.message);
          return false;
        },
        (_) {
          Logger.success('Password reset email sent to $email');
          return true;
        },
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      _setLoading(true);
      _clearError();

      final repository = _ref.read(authRepositoryProvider);
      await repository.signOut();

      Logger.success('Logout successful');
    } finally {
      _setLoading(false);
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _ref.read(authLoadingProvider.notifier).state = loading;
  }

  /// Set error state
  void _setError(String error) {
    _ref.read(authErrorProvider.notifier).state = error;
  }

  /// Clear error state
  void _clearError() {
    _ref.read(authErrorProvider.notifier).state = null;
  }
}
