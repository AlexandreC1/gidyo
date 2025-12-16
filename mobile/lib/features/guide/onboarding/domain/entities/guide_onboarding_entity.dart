import 'package:equatable/equatable.dart';

enum IDType {
  nif,
  passport,
  driversLicense,
}

enum PayoutMethod {
  bankTransfer,
  moncash,
}

enum OnboardingStep {
  basicInfo,
  identification,
  servicesSetup,
  vehicleInfo,
  availability,
  paymentSetup,
  review,
}

enum VerificationStatus {
  draft,
  pending,
  approved,
  rejected,
}

class GuideOnboardingData extends Equatable {
  // Step 1: Basic Info
  final String? fullName;
  final String? phone;
  final bool phoneVerified;
  final String? email;
  final String? profilePhotoUrl;
  final String? bio;

  // Step 2: Identification
  final IDType? idType;
  final String? idFrontPhotoUrl;
  final String? idBackPhotoUrl;
  final String? selfiePhotoUrl;
  final VerificationStatus idVerificationStatus;

  // Step 3: Services Setup
  final List<ServiceOffering> services;

  // Step 4: Vehicle Info
  final VehicleInformation? vehicleInfo;

  // Step 5: Availability
  final WeeklySchedule? weeklySchedule;
  final List<DateTime> specificAvailableDates;

  // Step 6: Payment Setup
  final PayoutMethod? payoutMethod;
  final BankAccountInfo? bankAccount;
  final String? moncashNumber;
  final bool paymentVerified;

  // Overall Status
  final OnboardingStep currentStep;
  final VerificationStatus overallStatus;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
  final String? rejectionReason;

  const GuideOnboardingData({
    this.fullName,
    this.phone,
    this.phoneVerified = false,
    this.email,
    this.profilePhotoUrl,
    this.bio,
    this.idType,
    this.idFrontPhotoUrl,
    this.idBackPhotoUrl,
    this.selfiePhotoUrl,
    this.idVerificationStatus = VerificationStatus.draft,
    this.services = const [],
    this.vehicleInfo,
    this.weeklySchedule,
    this.specificAvailableDates = const [],
    this.payoutMethod,
    this.bankAccount,
    this.moncashNumber,
    this.paymentVerified = false,
    this.currentStep = OnboardingStep.basicInfo,
    this.overallStatus = VerificationStatus.draft,
    this.submittedAt,
    this.approvedAt,
    this.rejectionReason,
  });

  bool get isBasicInfoComplete =>
      fullName != null &&
      phone != null &&
      phoneVerified &&
      email != null &&
      profilePhotoUrl != null &&
      bio != null &&
      bio!.isNotEmpty;

  bool get isIdentificationComplete =>
      idType != null &&
      idFrontPhotoUrl != null &&
      idBackPhotoUrl != null &&
      selfiePhotoUrl != null;

  bool get isServicesSetupComplete => services.isNotEmpty;

  bool get requiresVehicleInfo => services.any((s) => s.requiresVehicle);

  bool get isVehicleInfoComplete =>
      !requiresVehicleInfo || vehicleInfo != null;

  bool get isAvailabilityComplete =>
      weeklySchedule != null || specificAvailableDates.isNotEmpty;

  bool get isPaymentSetupComplete =>
      payoutMethod != null &&
      ((payoutMethod == PayoutMethod.bankTransfer && bankAccount != null) ||
          (payoutMethod == PayoutMethod.moncash && moncashNumber != null));

  bool get canSubmit =>
      isBasicInfoComplete &&
      isIdentificationComplete &&
      isServicesSetupComplete &&
      isVehicleInfoComplete &&
      isAvailabilityComplete &&
      isPaymentSetupComplete;

  GuideOnboardingData copyWith({
    String? fullName,
    String? phone,
    bool? phoneVerified,
    String? email,
    String? profilePhotoUrl,
    String? bio,
    IDType? idType,
    String? idFrontPhotoUrl,
    String? idBackPhotoUrl,
    String? selfiePhotoUrl,
    VerificationStatus? idVerificationStatus,
    List<ServiceOffering>? services,
    VehicleInformation? vehicleInfo,
    WeeklySchedule? weeklySchedule,
    List<DateTime>? specificAvailableDates,
    PayoutMethod? payoutMethod,
    BankAccountInfo? bankAccount,
    String? moncashNumber,
    bool? paymentVerified,
    OnboardingStep? currentStep,
    VerificationStatus? overallStatus,
    DateTime? submittedAt,
    DateTime? approvedAt,
    String? rejectionReason,
  }) {
    return GuideOnboardingData(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      email: email ?? this.email,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      bio: bio ?? this.bio,
      idType: idType ?? this.idType,
      idFrontPhotoUrl: idFrontPhotoUrl ?? this.idFrontPhotoUrl,
      idBackPhotoUrl: idBackPhotoUrl ?? this.idBackPhotoUrl,
      selfiePhotoUrl: selfiePhotoUrl ?? this.selfiePhotoUrl,
      idVerificationStatus: idVerificationStatus ?? this.idVerificationStatus,
      services: services ?? this.services,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      weeklySchedule: weeklySchedule ?? this.weeklySchedule,
      specificAvailableDates:
          specificAvailableDates ?? this.specificAvailableDates,
      payoutMethod: payoutMethod ?? this.payoutMethod,
      bankAccount: bankAccount ?? this.bankAccount,
      moncashNumber: moncashNumber ?? this.moncashNumber,
      paymentVerified: paymentVerified ?? this.paymentVerified,
      currentStep: currentStep ?? this.currentStep,
      overallStatus: overallStatus ?? this.overallStatus,
      submittedAt: submittedAt ?? this.submittedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  @override
  List<Object?> get props => [
        fullName,
        phone,
        phoneVerified,
        email,
        profilePhotoUrl,
        bio,
        idType,
        idFrontPhotoUrl,
        idBackPhotoUrl,
        selfiePhotoUrl,
        idVerificationStatus,
        services,
        vehicleInfo,
        weeklySchedule,
        specificAvailableDates,
        payoutMethod,
        bankAccount,
        moncashNumber,
        paymentVerified,
        currentStep,
        overallStatus,
        submittedAt,
        approvedAt,
        rejectionReason,
      ];
}

class ServiceOffering extends Equatable {
  final String serviceTypeId;
  final String serviceTypeName;
  final double price;
  final String description;
  final List<String> included;
  final bool requiresVehicle;

  const ServiceOffering({
    required this.serviceTypeId,
    required this.serviceTypeName,
    required this.price,
    required this.description,
    required this.included,
    this.requiresVehicle = false,
  });

  @override
  List<Object?> get props => [
        serviceTypeId,
        serviceTypeName,
        price,
        description,
        included,
        requiresVehicle,
      ];
}

class VehicleInformation extends Equatable {
  final String vehicleType;
  final String make;
  final String model;
  final int year;
  final String licensePlate;
  final int passengerCapacity;
  final List<String> photoUrls;
  final String? insuranceDocumentUrl;
  final bool hasAirConditioning;

  const VehicleInformation({
    required this.vehicleType,
    required this.make,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.passengerCapacity,
    required this.photoUrls,
    this.insuranceDocumentUrl,
    this.hasAirConditioning = false,
  });

  @override
  List<Object?> get props => [
        vehicleType,
        make,
        model,
        year,
        licensePlate,
        passengerCapacity,
        photoUrls,
        insuranceDocumentUrl,
        hasAirConditioning,
      ];
}

class WeeklySchedule extends Equatable {
  final DaySchedule monday;
  final DaySchedule tuesday;
  final DaySchedule wednesday;
  final DaySchedule thursday;
  final DaySchedule friday;
  final DaySchedule saturday;
  final DaySchedule sunday;

  const WeeklySchedule({
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
  });

  DaySchedule getSchedule(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return monday;
      case DateTime.tuesday:
        return tuesday;
      case DateTime.wednesday:
        return wednesday;
      case DateTime.thursday:
        return thursday;
      case DateTime.friday:
        return friday;
      case DateTime.saturday:
        return saturday;
      case DateTime.sunday:
        return sunday;
      default:
        return const DaySchedule(isAvailable: false);
    }
  }

  @override
  List<Object?> get props => [
        monday,
        tuesday,
        wednesday,
        thursday,
        friday,
        saturday,
        sunday,
      ];
}

class DaySchedule extends Equatable {
  final bool isAvailable;
  final String startTime; // e.g., "08:00"
  final String endTime; // e.g., "18:00"

  const DaySchedule({
    this.isAvailable = false,
    this.startTime = "08:00",
    this.endTime = "18:00",
  });

  @override
  List<Object?> get props => [isAvailable, startTime, endTime];
}

class BankAccountInfo extends Equatable {
  final String accountHolderName;
  final String bankName;
  final String accountNumber;
  final String? routingNumber;

  const BankAccountInfo({
    required this.accountHolderName,
    required this.bankName,
    required this.accountNumber,
    this.routingNumber,
  });

  @override
  List<Object?> get props => [
        accountHolderName,
        bankName,
        accountNumber,
        routingNumber,
      ];
}
