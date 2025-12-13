import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  final String? phone;
  @JsonKey(name: 'user_type')
  final String userType;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'profile_photo')
  final String? profilePhoto;
  @JsonKey(name: 'language_preference')
  final String languagePreference;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      phone: phone,
      userType: _parseUserType(userType),
      firstName: firstName,
      lastName: lastName,
      profilePhoto: profilePhoto,
      languagePreference: languagePreference,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      phone: entity.phone,
      userType: entity.userType.name,
      firstName: entity.firstName,
      lastName: entity.lastName,
      profilePhoto: entity.profilePhoto,
      languagePreference: entity.languagePreference,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static UserType _parseUserType(String type) {
    switch (type.toLowerCase()) {
      case 'visitor':
        return UserType.visitor;
      case 'guide':
        return UserType.guide;
      case 'admin':
        return UserType.admin;
      default:
        return UserType.visitor;
    }
  }
}
