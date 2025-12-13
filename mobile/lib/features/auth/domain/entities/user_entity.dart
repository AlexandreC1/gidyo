import 'package:equatable/equatable.dart';

enum UserType { visitor, guide, admin }

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? phone;
  final UserType userType;
  final String firstName;
  final String lastName;
  final String? profilePhoto;
  final String languagePreference;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    required this.email,
    this.phone,
    required this.userType,
    required this.firstName,
    required this.lastName,
    this.profilePhoto,
    required this.languagePreference,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        id,
        email,
        phone,
        userType,
        firstName,
        lastName,
        profilePhoto,
        languagePreference,
        isActive,
        createdAt,
        updatedAt,
      ];
}
