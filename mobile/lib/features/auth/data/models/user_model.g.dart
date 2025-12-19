// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  userType: json['user_type'] as String,
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  profilePhoto: json['profile_photo'] as String?,
  languagePreference: json['language_preference'] as String,
  isActive: json['is_active'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'phone': instance.phone,
  'user_type': instance.userType,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'profile_photo': instance.profilePhoto,
  'language_preference': instance.languagePreference,
  'is_active': instance.isActive,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
