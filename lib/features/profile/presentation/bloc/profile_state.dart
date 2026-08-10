import 'package:equatable/equatable.dart';
import 'package:clanship_mobile_tradesman/features/home/domain/entities/user_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserEntity user;
  final bool isAvatarUploading;
  final bool isPhotoUploading;
  final bool isPhotoDeleting;
  final bool isDocumentUploading;
  final bool isDocumentDeleting;
  final bool isUpdating;
  final bool isSubscribing;
  final bool isLoadingPlans;
  final List<Map<String, dynamic>> availableTags;
  final List<Map<String, dynamic>> availableSpecialties;
  final List<SubscriptionPlanEntity> availablePlans;
  final String? errorMessage;

  const ProfileLoaded({
    required this.user,
    this.isAvatarUploading = false,
    this.isPhotoUploading = false,
    this.isPhotoDeleting = false,
    this.isDocumentUploading = false,
    this.isDocumentDeleting = false,
    this.isUpdating = false,
    this.isSubscribing = false,
    this.isLoadingPlans = false,
    this.availableTags = const [],
    this.availableSpecialties = const [],
    this.availablePlans = const [],
    this.errorMessage,
  });

  ProfileLoaded copyWith({
    UserEntity? user,
    bool? isAvatarUploading,
    bool? isPhotoUploading,
    bool? isPhotoDeleting,
    bool? isDocumentUploading,
    bool? isDocumentDeleting,
    bool? isUpdating,
    bool? isSubscribing,
    bool? isLoadingPlans,
    List<Map<String, dynamic>>? availableTags,
    List<Map<String, dynamic>>? availableSpecialties,
    List<SubscriptionPlanEntity>? availablePlans,
    String? errorMessage,
  }) {
    return ProfileLoaded(
      user: user ?? this.user,
      isAvatarUploading: isAvatarUploading ?? this.isAvatarUploading,
      isPhotoUploading: isPhotoUploading ?? this.isPhotoUploading,
      isPhotoDeleting: isPhotoDeleting ?? this.isPhotoDeleting,
      isDocumentUploading: isDocumentUploading ?? this.isDocumentUploading,
      isDocumentDeleting: isDocumentDeleting ?? this.isDocumentDeleting,
      isUpdating: isUpdating ?? this.isUpdating,
      isSubscribing: isSubscribing ?? this.isSubscribing,
      isLoadingPlans: isLoadingPlans ?? this.isLoadingPlans,
      availableTags: availableTags ?? this.availableTags,
      availableSpecialties: availableSpecialties ?? this.availableSpecialties,
      availablePlans: availablePlans ?? this.availablePlans,
      errorMessage: errorMessage, // We don't default to this.errorMessage to allow clearing it
    );
  }

  @override
  List<Object?> get props => [
        user,
        isAvatarUploading,
        isPhotoUploading,
        isPhotoDeleting,
        isDocumentUploading,
        isDocumentDeleting,
        isUpdating,
        isSubscribing,
        isLoadingPlans,
        availableTags,
        availableSpecialties,
        availablePlans,
        errorMessage,
      ];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
