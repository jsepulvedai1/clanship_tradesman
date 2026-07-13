import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileData extends ProfileEvent {}

class UploadAvatarEvent extends ProfileEvent {
  final String imagePath;

  const UploadAvatarEvent(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class UpdateProfessionalProfileEvent extends ProfileEvent {
  final String? bio;
  final double? hourlyRate;
  final int? serviceRadius;
  final String? facebookUrl;
  final String? instagramUrl;
  final String? tiktokUrl;
  final List<String>? tagIds;
  final String? specialtyId;
  final List<String>? specialtyIds;

  const UpdateProfessionalProfileEvent({
    this.bio,
    this.hourlyRate,
    this.serviceRadius,
    this.facebookUrl,
    this.instagramUrl,
    this.tiktokUrl,
    this.tagIds,
    this.specialtyId,
    this.specialtyIds,
  });

  @override
  List<Object?> get props => [
        bio,
        hourlyRate,
        serviceRadius,
        facebookUrl,
        instagramUrl,
        tiktokUrl,
        tagIds,
        specialtyId,
        specialtyIds,
      ];
}

class LoadSpecialtiesEvent extends ProfileEvent {}


class AddPortfolioPhotoEvent extends ProfileEvent {
  final String imagePath;

  const AddPortfolioPhotoEvent(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class DeletePortfolioPhotoEvent extends ProfileEvent {
  final String photoId;

  const DeletePortfolioPhotoEvent(this.photoId);

  @override
  List<Object?> get props => [photoId];
}

class LoadTagsEvent extends ProfileEvent {}

class AddProfessionalDocumentEvent extends ProfileEvent {
  final String name;
  final String filePath;

  const AddProfessionalDocumentEvent({required this.name, required this.filePath});

  @override
  List<Object?> get props => [name, filePath];
}

class ToggleDocumentVisibilityEvent extends ProfileEvent {
  final String documentId;
  final bool isVisible;

  const ToggleDocumentVisibilityEvent({required this.documentId, required this.isVisible});

  @override
  List<Object?> get props => [documentId, isVisible];
}

class DeleteProfessionalDocumentEvent extends ProfileEvent {
  final String documentId;

  const DeleteProfessionalDocumentEvent(this.documentId);

  @override
  List<Object?> get props => [documentId];
}

class LoadSubscriptionPlansEvent extends ProfileEvent {}

class SubscribeToPlanEvent extends ProfileEvent {
  final String planId;

  const SubscribeToPlanEvent(this.planId);

  @override
  List<Object?> get props => [planId];
}

class SetAvatarFromUrlEvent extends ProfileEvent {
  final String imageUrl;

  const SetAvatarFromUrlEvent(this.imageUrl);

  @override
  List<Object?> get props => [imageUrl];
}

