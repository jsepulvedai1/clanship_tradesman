// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  avatarPath: json['avatarPath'] as String?,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  address: json['address'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  professionalAddress: json['professionalAddress'] as String?,
  professionalLatitude: (json['professionalLatitude'] as num?)?.toDouble(),
  professionalLongitude: (json['professionalLongitude'] as num?)?.toDouble(),
  isValidated: json['isValidated'] as bool? ?? false,
  verificationStatus: json['verificationStatus'] as String? ?? 'PENDING',
  rejectionReason: json['rejectionReason'] as String?,
  requiresPlanUpgrade: json['requiresPlanUpgrade'] as bool? ?? false,
  referralCode: json['referralCode'] as String?,
  referralsTotalCount: (json['referralsTotalCount'] as num?)?.toInt() ?? 0,
  referralsPendingCount: (json['referralsPendingCount'] as num?)?.toInt() ?? 0,
  referralsTargetCount: (json['referralsTargetCount'] as num?)?.toInt() ?? 5,
  referralRewardPlanName:
      json['referralRewardPlanName'] as String? ?? 'Plan Profesional',
  referralRewardDays: (json['referralRewardDays'] as num?)?.toInt() ?? 30,
  planExpiresAt: json['planExpiresAt'] == null
      ? null
      : DateTime.parse(json['planExpiresAt'] as String),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'avatarPath': instance.avatarPath,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'phoneNumber': instance.phoneNumber,
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'professionalAddress': instance.professionalAddress,
  'professionalLatitude': instance.professionalLatitude,
  'professionalLongitude': instance.professionalLongitude,
  'isValidated': instance.isValidated,
  'verificationStatus': instance.verificationStatus,
  'rejectionReason': instance.rejectionReason,
  'requiresPlanUpgrade': instance.requiresPlanUpgrade,
  'referralCode': instance.referralCode,
  'referralsTotalCount': instance.referralsTotalCount,
  'referralsPendingCount': instance.referralsPendingCount,
  'referralsTargetCount': instance.referralsTargetCount,
  'referralRewardPlanName': instance.referralRewardPlanName,
  'referralRewardDays': instance.referralRewardDays,
  'planExpiresAt': instance.planExpiresAt?.toIso8601String(),
};
