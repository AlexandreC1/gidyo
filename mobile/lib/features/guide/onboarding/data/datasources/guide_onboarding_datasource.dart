import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../domain/entities/guide_onboarding_entity.dart';

class GuideOnboardingDatasource {
  final SupabaseClient _supabase;

  GuideOnboardingDatasource(this._supabase);

  Future<GuideOnboardingData> loadOnboardingData() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException('User not logged in');
      }

      // Check if guide profile exists
      final profile = await _supabase
          .from('guide_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (profile == null) {
        return const GuideOnboardingData();
      }

      // Load services
      final services = await _supabase
          .from('guide_services')
          .select('*, service_types(name_en, requires_vehicle)')
          .eq('guide_id', profile['id']);

      // Convert to entity
      return _mapToEntity(profile, services);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> saveBasicInfo({
    required String fullName,
    required String phone,
    required bool phoneVerified,
    required String email,
    String? profilePhotoUrl,
    String? bio,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException('User not logged in');
      }

      // Update user table
      await _supabase.from('users').update({
        'first_name': fullName.split(' ').first,
        'last_name': fullName.split(' ').skip(1).join(' '),
        'email': email,
        'phone': phone,
        'profile_image_url': profilePhotoUrl,
      }).eq('id', userId);

      // Create or update guide profile
      final existing = await _supabase
          .from('guide_profiles')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        await _supabase.from('guide_profiles').update({
          'bio': bio,
          'phone_verified': phoneVerified,
        }).eq('id', existing['id']);
      } else {
        await _supabase.from('guide_profiles').insert({
          'user_id': userId,
          'bio': bio,
          'phone_verified': phoneVerified,
        });
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> saveIdentification({
    required String idType,
    required String idFrontPhotoUrl,
    required String idBackPhotoUrl,
    required String selfiePhotoUrl,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException('User not logged in');
      }

      final profile = await _supabase
          .from('guide_profiles')
          .select('id')
          .eq('user_id', userId)
          .single();

      await _supabase.from('guide_profiles').update({
        'id_type': idType,
        'id_front_photo_url': idFrontPhotoUrl,
        'id_back_photo_url': idBackPhotoUrl,
        'selfie_photo_url': selfiePhotoUrl,
        'id_verification_status': 'pending',
      }).eq('id', profile['id']);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> saveServices(List<ServiceOffering> services) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException('User not logged in');
      }

      final profile = await _supabase
          .from('guide_profiles')
          .select('id')
          .eq('user_id', userId)
          .single();

      final guideId = profile['id'] as String;

      // Delete existing services
      await _supabase.from('guide_services').delete().eq('guide_id', guideId);

      // Insert new services
      for (var service in services) {
        await _supabase.from('guide_services').insert({
          'guide_id': guideId,
          'service_type_id': service.serviceTypeId,
          'price': service.price,
          'description': service.description,
          'included': service.included,
        });
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> saveVehicleInfo(VehicleInformation vehicleInfo) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException('User not logged in');
      }

      final profile = await _supabase
          .from('guide_profiles')
          .select('id')
          .eq('user_id', userId)
          .single();

      await _supabase.from('guide_profiles').update({
        'vehicle_type': vehicleInfo.vehicleType,
        'vehicle_make': vehicleInfo.make,
        'vehicle_model': vehicleInfo.model,
        'vehicle_year': vehicleInfo.year,
        'vehicle_license_plate': vehicleInfo.licensePlate,
        'vehicle_capacity': vehicleInfo.passengerCapacity,
        'vehicle_photos': vehicleInfo.photoUrls,
        'insurance_document_url': vehicleInfo.insuranceDocumentUrl,
        'has_ac': vehicleInfo.hasAirConditioning,
      }).eq('id', profile['id']);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> saveAvailability({
    WeeklySchedule? weeklySchedule,
    List<DateTime>? specificDates,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException('User not logged in');
      }

      final profile = await _supabase
          .from('guide_profiles')
          .select('id')
          .eq('user_id', userId)
          .single();

      final guideId = profile['id'] as String;

      if (weeklySchedule != null) {
        // Save weekly schedule
        await _supabase.from('guide_profiles').update({
          'weekly_schedule': _weeklyScheduleToJson(weeklySchedule),
        }).eq('id', guideId);
      }

      if (specificDates != null && specificDates.isNotEmpty) {
        // Delete existing availability
        await _supabase
            .from('guide_availability')
            .delete()
            .eq('guide_id', guideId);

        // Insert new dates
        for (var date in specificDates) {
          await _supabase.from('guide_availability').insert({
            'guide_id': guideId,
            'available_date': date.toIso8601String(),
          });
        }
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> savePaymentSetup({
    required String payoutMethod,
    BankAccountInfo? bankAccount,
    String? moncashNumber,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException('User not logged in');
      }

      final profile = await _supabase
          .from('guide_profiles')
          .select('id')
          .eq('user_id', userId)
          .single();

      await _supabase.from('guide_profiles').update({
        'payout_method': payoutMethod,
        'bank_account_info': bankAccount != null
            ? {
                'account_holder_name': bankAccount.accountHolderName,
                'bank_name': bankAccount.bankName,
                'account_number': bankAccount.accountNumber,
                'routing_number': bankAccount.routingNumber,
              }
            : null,
        'moncash_number': moncashNumber,
      }).eq('id', profile['id']);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> submitForReview() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException('User not logged in');
      }

      final profile = await _supabase
          .from('guide_profiles')
          .select('id')
          .eq('user_id', userId)
          .single();

      await _supabase.from('guide_profiles').update({
        'verification_status': 'pending',
        'submitted_at': DateTime.now().toIso8601String(),
      }).eq('id', profile['id']);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<String> uploadPhoto(String path, String filePath) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException('User not logged in');
      }

      // Mock upload - in production, use Supabase Storage
      // final file = File(filePath);
      // await _supabase.storage.from('guide-uploads').upload('$userId/$path', file);
      // final url = _supabase.storage.from('guide-uploads').getPublicUrl('$userId/$path');

      // For now, return a placeholder
      return 'https://placeholder.com/$path';
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<String> sendOTP(String phone) async {
    try {
      // Mock OTP sending - in production, integrate with SMS service
      await Future.delayed(const Duration(seconds: 1));
      return '123456'; // Mock OTP
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<bool> verifyOTP(String phone, String otp) async {
    try {
      // Mock OTP verification
      await Future.delayed(const Duration(seconds: 1));
      return otp == '123456';
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  GuideOnboardingData _mapToEntity(
    Map<String, dynamic> profile,
    List<dynamic> services,
  ) {
    // Map database fields to entity
    // This is simplified - expand based on actual schema
    return const GuideOnboardingData();
  }

  Map<String, dynamic> _weeklyScheduleToJson(WeeklySchedule schedule) {
    return {
      'monday': _dayScheduleToJson(schedule.monday),
      'tuesday': _dayScheduleToJson(schedule.tuesday),
      'wednesday': _dayScheduleToJson(schedule.wednesday),
      'thursday': _dayScheduleToJson(schedule.thursday),
      'friday': _dayScheduleToJson(schedule.friday),
      'saturday': _dayScheduleToJson(schedule.saturday),
      'sunday': _dayScheduleToJson(schedule.sunday),
    };
  }

  Map<String, dynamic> _dayScheduleToJson(DaySchedule schedule) {
    return {
      'is_available': schedule.isAvailable,
      'start_time': schedule.startTime,
      'end_time': schedule.endTime,
    };
  }
}
