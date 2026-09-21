import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? avatarPath;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? professionalAddress;
  final double? professionalLatitude;
  final double? professionalLongitude;
  final bool isValidated;
  final String verificationStatus;
  final String? rejectionReason;
  final bool requiresPlanUpgrade;
  final String? referralCode;
  final int referralsTotalCount;
  final int referralsPendingCount;
  final int referralsTargetCount;
  final String? referralRewardPlanName;
  final int referralRewardDays;
  final DateTime? planExpiresAt;
  final int referralsRewardsEarnedCount;
  final int referralMaxRewardsPerUser;
  final bool referralHasReachedMaxRewards;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.avatarPath,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.address,
    this.latitude,
    this.longitude,
    this.professionalAddress,
    this.professionalLatitude,
    this.professionalLongitude,
    this.isValidated = false,
    this.verificationStatus = 'PENDING',
    this.rejectionReason,
    this.requiresPlanUpgrade = false,
    this.referralCode,
    this.referralsTotalCount = 0,
    this.referralsPendingCount = 0,
    this.referralsTargetCount = 5,
    this.referralRewardPlanName = 'Plan Profesional',
    this.referralRewardDays = 30,
    this.planExpiresAt,
    this.referralsRewardsEarnedCount = 0,
    this.referralMaxRewardsPerUser = 1,
    this.referralHasReachedMaxRewards = false,
  });

  bool get isRejected {
    if (isValidated) return false;
    return verificationStatus.toUpperCase() == 'REJECTED' || (rejectionReason != null && rejectionReason!.trim().isNotEmpty);
  }

  String get effectiveRejectionReason {
    if (rejectionReason != null && rejectionReason!.trim().isNotEmpty) {
      return rejectionReason!;
    }
    return 'Tus antecedentes o documentos fueron observados por el equipo de administración. Por favor vuelve a adjuntar fotos legibles.';
  }

  /// Creates a copy of this User with the given fields replaced by the new values.
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarPath,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? address,
    double? latitude,
    double? longitude,
    String? professionalAddress,
    double? professionalLatitude,
    double? professionalLongitude,
    bool? isValidated,
    String? verificationStatus,
    String? rejectionReason,
    bool? requiresPlanUpgrade,
    String? referralCode,
    int? referralsTotalCount,
    int? referralsPendingCount,
    int? referralsTargetCount,
    String? referralRewardPlanName,
    int? referralRewardDays,
    DateTime? planExpiresAt,
    int? referralsRewardsEarnedCount,
    int? referralMaxRewardsPerUser,
    bool? referralHasReachedMaxRewards,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      professionalAddress: professionalAddress ?? this.professionalAddress,
      professionalLatitude: professionalLatitude ?? this.professionalLatitude,
      professionalLongitude: professionalLongitude ?? this.professionalLongitude,
      isValidated: isValidated ?? this.isValidated,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      requiresPlanUpgrade: requiresPlanUpgrade ?? this.requiresPlanUpgrade,
      referralCode: referralCode ?? this.referralCode,
      referralsTotalCount: referralsTotalCount ?? this.referralsTotalCount,
      referralsPendingCount: referralsPendingCount ?? this.referralsPendingCount,
      referralsTargetCount: referralsTargetCount ?? this.referralsTargetCount,
      referralRewardPlanName: referralRewardPlanName ?? this.referralRewardPlanName,
      referralRewardDays: referralRewardDays ?? this.referralRewardDays,
      planExpiresAt: planExpiresAt ?? this.planExpiresAt,
      referralsRewardsEarnedCount: referralsRewardsEarnedCount ?? this.referralsRewardsEarnedCount,
      referralMaxRewardsPerUser: referralMaxRewardsPerUser ?? this.referralMaxRewardsPerUser,
      referralHasReachedMaxRewards: referralHasReachedMaxRewards ?? this.referralHasReachedMaxRewards,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        avatarPath,
        firstName,
        lastName,
        phoneNumber,
        address,
        latitude,
        longitude,
        professionalAddress,
        professionalLatitude,
        professionalLongitude,
        isValidated,
        verificationStatus,
        rejectionReason,
        requiresPlanUpgrade,
        referralCode,
        referralsTotalCount,
        referralsPendingCount,
        referralsTargetCount,
        referralRewardPlanName,
        referralRewardDays,
        planExpiresAt,
        referralsRewardsEarnedCount,
        referralMaxRewardsPerUser,
        referralHasReachedMaxRewards,
      ];
}

