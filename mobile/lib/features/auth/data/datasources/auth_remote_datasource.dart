import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart' as core_exceptions;
import '../models/user_model.dart';
import '../../domain/entities/user_entity.dart';

class AuthRemoteDatasource {
  final SupabaseClient _supabase;

  AuthRemoteDatasource(this._supabase);

  /// Sign in with email and password
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const core_exceptions.AuthException('Login failed');
      }

      return await _getUserProfile(response.user!.id);
    } on core_exceptions.AuthException {
      rethrow;
    } catch (e) {
      throw core_exceptions.AuthException(e.toString());
    }
  }

  /// Sign up with email and password
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserType userType,
    String? phone,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const core_exceptions.AuthException('Registration failed');
      }

      // Create user profile
      await _supabase.from('users').insert({
        'id': response.user!.id,
        'email': email,
        'phone': phone,
        'user_type': userType.name,
        'first_name': firstName,
        'last_name': lastName,
        'language_preference': 'en',
        'is_active': true,
      });

      return await _getUserProfile(response.user!.id);
    } on core_exceptions.AuthException {
      rethrow;
    } catch (e) {
      throw core_exceptions.AuthException(e.toString());
    }
  }

  /// Sign in with Google
  Future<UserModel> signInWithGoogle() async {
    try {
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'gidyo://login-callback',
      );

      if (!response) {
        throw const core_exceptions.AuthException('Google sign-in failed');
      }

      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const core_exceptions.AuthException('No user found after Google sign-in');
      }

      return await _getUserProfile(user.id);
    } on core_exceptions.AuthException {
      rethrow;
    } catch (e) {
      throw core_exceptions.AuthException(e.toString());
    }
  }

  /// Sign in with Apple
  Future<UserModel> signInWithApple() async {
    try {
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'gidyo://login-callback',
      );

      if (!response) {
        throw const core_exceptions.AuthException('Apple sign-in failed');
      }

      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const core_exceptions.AuthException('No user found after Apple sign-in');
      }

      return await _getUserProfile(user.id);
    } on core_exceptions.AuthException {
      rethrow;
    } catch (e) {
      throw core_exceptions.AuthException(e.toString());
    }
  }

  /// Send OTP to phone
  Future<void> sendOtp(String phone) async {
    try {
      await _supabase.auth.signInWithOtp(phone: phone);
    } catch (e) {
      throw core_exceptions.AuthException(e.toString());
    }
  }

  /// Verify OTP
  Future<UserModel> verifyOtp(String phone, String otp) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        phone: phone,
        token: otp,
        type: OtpType.sms,
      );

      if (response.user == null) {
        throw const core_exceptions.AuthException('OTP verification failed');
      }

      return await _getUserProfile(response.user!.id);
    } on core_exceptions.AuthException {
      rethrow;
    } catch (e) {
      throw core_exceptions.AuthException(e.toString());
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw core_exceptions.AuthException(e.toString());
    }
  }

  /// Get current user
  Future<UserModel> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const core_exceptions.UnauthorizedException('No user logged in');
      }

      return await _getUserProfile(user.id);
    } on core_exceptions.UnauthorizedException {
      rethrow;
    } catch (e) {
      throw core_exceptions.ServerException(e.toString());
    }
  }

  /// Update user profile
  Future<UserModel> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phone,
    UserType? userType,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const core_exceptions.UnauthorizedException('No user logged in');
      }

      final Map<String, dynamic> updates = {};
      if (firstName != null) updates['first_name'] = firstName;
      if (lastName != null) updates['last_name'] = lastName;
      if (phone != null) updates['phone'] = phone;
      if (userType != null) updates['user_type'] = userType.name;

      if (updates.isEmpty) {
        return await _getUserProfile(user.id);
      }

      updates['updated_at'] = DateTime.now().toIso8601String();

      await _supabase.from('users').update(updates).eq('id', user.id);

      return await _getUserProfile(user.id);
    } on core_exceptions.UnauthorizedException {
      rethrow;
    } catch (e) {
      throw core_exceptions.ServerException(e.toString());
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw core_exceptions.AuthException(e.toString());
    }
  }

  /// Get user profile from database
  Future<UserModel> _getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw core_exceptions.ServerException(e.toString());
    }
  }
}
