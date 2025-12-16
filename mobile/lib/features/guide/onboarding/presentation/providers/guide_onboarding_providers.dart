import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/network/supabase_client.dart';
import '../../data/datasources/guide_onboarding_datasource.dart';
import '../../domain/entities/guide_onboarding_entity.dart';

// Datasource Provider
final guideOnboardingDatasourceProvider =
    Provider<GuideOnboardingDatasource>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return GuideOnboardingDatasource(supabase);
});

// Onboarding Data Provider
final guideOnboardingDataProvider =
    StateNotifierProvider<GuideOnboardingNotifier, GuideOnboardingData>((ref) {
  return GuideOnboardingNotifier(ref);
});

class GuideOnboardingNotifier extends StateNotifier<GuideOnboardingData> {
  final Ref _ref;

  GuideOnboardingNotifier(this._ref) : super(const GuideOnboardingData()) {
    _loadOnboardingData();
  }

  Future<void> _loadOnboardingData() async {
    try {
      final datasource = _ref.read(guideOnboardingDatasourceProvider);
      final data = await datasource.loadOnboardingData();
      state = data;
    } catch (e) {
      // Keep default state if loading fails
    }
  }

  // Step 1: Basic Info
  Future<void> saveBasicInfo({
    required String fullName,
    required String phone,
    required bool phoneVerified,
    required String email,
    String? profilePhotoUrl,
    String? bio,
  }) async {
    try {
      final datasource = _ref.read(guideOnboardingDatasourceProvider);
      await datasource.saveBasicInfo(
        fullName: fullName,
        phone: phone,
        phoneVerified: phoneVerified,
        email: email,
        profilePhotoUrl: profilePhotoUrl,
        bio: bio,
      );

      state = state.copyWith(
        fullName: fullName,
        phone: phone,
        phoneVerified: phoneVerified,
        email: email,
        profilePhotoUrl: profilePhotoUrl,
        bio: bio,
        currentStep: OnboardingStep.identification,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadPhoto(String path, String filePath) async {
    final datasource = _ref.read(guideOnboardingDatasourceProvider);
    return await datasource.uploadPhoto(path, filePath);
  }

  Future<String> sendOTP(String phone) async {
    final datasource = _ref.read(guideOnboardingDatasourceProvider);
    return await datasource.sendOTP(phone);
  }

  Future<bool> verifyOTP(String phone, String otp) async {
    final datasource = _ref.read(guideOnboardingDatasourceProvider);
    return await datasource.verifyOTP(phone, otp);
  }

  // Step 2: Identification
  Future<void> saveIdentification({
    required IDType idType,
    required String idFrontPhotoUrl,
    required String idBackPhotoUrl,
    required String selfiePhotoUrl,
  }) async {
    try {
      final datasource = _ref.read(guideOnboardingDatasourceProvider);
      await datasource.saveIdentification(
        idType: _idTypeToString(idType),
        idFrontPhotoUrl: idFrontPhotoUrl,
        idBackPhotoUrl: idBackPhotoUrl,
        selfiePhotoUrl: selfiePhotoUrl,
      );

      state = state.copyWith(
        idType: idType,
        idFrontPhotoUrl: idFrontPhotoUrl,
        idBackPhotoUrl: idBackPhotoUrl,
        selfiePhotoUrl: selfiePhotoUrl,
        idVerificationStatus: VerificationStatus.pending,
        currentStep: OnboardingStep.servicesSetup,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Step 3: Services Setup
  Future<void> saveServices(List<ServiceOffering> services) async {
    try {
      final datasource = _ref.read(guideOnboardingDatasourceProvider);
      await datasource.saveServices(services);

      final requiresVehicle = services.any((s) => s.requiresVehicle);

      state = state.copyWith(
        services: services,
        currentStep: requiresVehicle
            ? OnboardingStep.vehicleInfo
            : OnboardingStep.availability,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Step 4: Vehicle Info
  Future<void> saveVehicleInfo(VehicleInformation vehicleInfo) async {
    try {
      final datasource = _ref.read(guideOnboardingDatasourceProvider);
      await datasource.saveVehicleInfo(vehicleInfo);

      state = state.copyWith(
        vehicleInfo: vehicleInfo,
        currentStep: OnboardingStep.availability,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Step 5: Availability
  Future<void> saveAvailability({
    WeeklySchedule? weeklySchedule,
    List<DateTime>? specificDates,
  }) async {
    try {
      final datasource = _ref.read(guideOnboardingDatasourceProvider);
      await datasource.saveAvailability(
        weeklySchedule: weeklySchedule,
        specificDates: specificDates,
      );

      state = state.copyWith(
        weeklySchedule: weeklySchedule,
        specificAvailableDates: specificDates,
        currentStep: OnboardingStep.paymentSetup,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Step 6: Payment Setup
  Future<void> savePaymentSetup({
    required PayoutMethod payoutMethod,
    BankAccountInfo? bankAccount,
    String? moncashNumber,
  }) async {
    try {
      final datasource = _ref.read(guideOnboardingDatasourceProvider);
      await datasource.savePaymentSetup(
        payoutMethod: _payoutMethodToString(payoutMethod),
        bankAccount: bankAccount,
        moncashNumber: moncashNumber,
      );

      state = state.copyWith(
        payoutMethod: payoutMethod,
        bankAccount: bankAccount,
        moncashNumber: moncashNumber,
        currentStep: OnboardingStep.review,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Step 7: Submit for Review
  Future<void> submitForReview() async {
    try {
      final datasource = _ref.read(guideOnboardingDatasourceProvider);
      await datasource.submitForReview();

      state = state.copyWith(
        overallStatus: VerificationStatus.pending,
        submittedAt: DateTime.now(),
      );
    } catch (e) {
      rethrow;
    }
  }

  void goToStep(OnboardingStep step) {
    state = state.copyWith(currentStep: step);
  }

  String _idTypeToString(IDType type) {
    switch (type) {
      case IDType.nif:
        return 'nif';
      case IDType.passport:
        return 'passport';
      case IDType.driversLicense:
        return 'drivers_license';
    }
  }

  String _payoutMethodToString(PayoutMethod method) {
    switch (method) {
      case PayoutMethod.bankTransfer:
        return 'bank_transfer';
      case PayoutMethod.moncash:
        return 'moncash';
    }
  }
}

// Service Types Provider (for service selection)
final serviceTypesProvider = FutureProvider<List<ServiceType>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);

  try {
    final response = await supabase.from('service_types').select();

    return (response as List).map((json) {
      return ServiceType(
        id: json['id'] as String,
        nameEn: json['name_en'] as String,
        nameFr: json['name_fr'] as String?,
        requiresVehicle: json['requires_vehicle'] as bool? ?? false,
      );
    }).toList();
  } catch (e) {
    return [];
  }
});

class ServiceType {
  final String id;
  final String nameEn;
  final String? nameFr;
  final bool requiresVehicle;

  ServiceType({
    required this.id,
    required this.nameEn,
    this.nameFr,
    this.requiresVehicle = false,
  });
}
