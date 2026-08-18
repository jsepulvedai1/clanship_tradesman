import 'dart:io';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'profile_event.dart';
import 'profile_state.dart';

import 'package:clanship_mobile_tradesman/features/profile/domain/repositories/profile_repository.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;

  ProfileBloc(this.profileRepository) : super(ProfileInitial()) {
    on<LoadProfileData>(_onLoadProfileData);
    on<UploadAvatarEvent>(_onUploadAvatar);
    on<UpdateProfessionalProfileEvent>(_onUpdateProfessionalProfile);
    on<AddPortfolioPhotoEvent>(_onAddPortfolioPhoto);
    on<DeletePortfolioPhotoEvent>(_onDeletePortfolioPhoto);
    on<LoadTagsEvent>(_onLoadTags);
    on<AddProfessionalDocumentEvent>(_onAddProfessionalDocument);
    on<ToggleDocumentVisibilityEvent>(_onToggleDocumentVisibility);
    on<DeleteProfessionalDocumentEvent>(_onDeleteProfessionalDocument);
    on<LoadSpecialtiesEvent>(_onLoadSpecialties);
    on<LoadSubscriptionPlansEvent>(_onLoadSubscriptionPlans);
    on<SubscribeToPlanEvent>(_onSubscribeToPlan);
    on<SetAvatarFromUrlEvent>(_onSetAvatarFromUrl);
  }

  void _onLoadProfileData(LoadProfileData event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    
    final result = await profileRepository.getMyProfile();

    if (isClosed) return;

    result.fold(
      (failure) {
        if (!isClosed) emit(ProfileError(failure.message));
      },
      (user) {
        if (!isClosed) {
          emit(ProfileLoaded(user: user));
          add(LoadTagsEvent());
          add(LoadSpecialtiesEvent());
          add(LoadSubscriptionPlansEvent());
        }
      },
    );
  }

  Future<void> _onUploadAvatar(UploadAvatarEvent event, Emitter<ProfileState> emit) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(currentState.copyWith(isAvatarUploading: true));

      try {
        final file = File(event.imagePath);
        final bytes = await file.readAsBytes();
        final base64Image = base64Encode(bytes);

        final result = await profileRepository.updateProfile(
          firstName: currentState.user.firstName,
          lastName: currentState.user.lastName,
          email: currentState.user.email,
          avatarBase64: base64Image,
        );

        result.fold(
          (failure) => emit(currentState.copyWith(isAvatarUploading: false)),
          (updatedUser) => emit(currentState.copyWith(
            user: updatedUser,
            isAvatarUploading: false,
          )),
        );
      } catch (e) {
        emit(currentState.copyWith(isAvatarUploading: false));
      }
    }
  }

  Future<void> _onUpdateProfessionalProfile(UpdateProfessionalProfileEvent event, Emitter<ProfileState> emit) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(currentState.copyWith(isUpdating: true));

      final result = await profileRepository.updateProfessionalProfile(
        bio: event.bio,
        hourlyRate: event.hourlyRate,
        serviceRadius: event.serviceRadius,
        facebookUrl: event.facebookUrl,
        instagramUrl: event.instagramUrl,
        tiktokUrl: event.tiktokUrl,
        address: event.address,
        latitude: event.latitude,
        longitude: event.longitude,
        tagIds: event.tagIds,
        specialtyId: event.specialtyId,
        specialtyIds: event.specialtyIds,
        subtagIds: event.subtagIds,
      );

      result.fold(
        (failure) => emit(currentState.copyWith(isUpdating: false)),
        (updatedUser) => emit(currentState.copyWith(
          user: updatedUser,
          isUpdating: false,
        )),
      );
    }
  }

  Future<void> _onAddPortfolioPhoto(AddPortfolioPhotoEvent event, Emitter<ProfileState> emit) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(currentState.copyWith(isPhotoUploading: true));

      try {
        final file = File(event.imagePath);
        final bytes = await file.readAsBytes();
        final base64Image = base64Encode(bytes);

        final result = await profileRepository.addPortfolioPhoto(
          imageBase64: base64Image,
        );

        result.fold(
          (failure) => emit(currentState.copyWith(isPhotoUploading: false)),
          (updatedUser) => emit(currentState.copyWith(
            user: updatedUser,
            isPhotoUploading: false,
          )),
        );
      } catch (e) {
        emit(currentState.copyWith(isPhotoUploading: false));
      }
    }
  }

  Future<void> _onDeletePortfolioPhoto(DeletePortfolioPhotoEvent event, Emitter<ProfileState> emit) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(currentState.copyWith(isPhotoDeleting: true));

      final result = await profileRepository.deletePortfolioPhoto(
        photoId: event.photoId,
      );

      result.fold(
        (failure) => emit(currentState.copyWith(isPhotoDeleting: false)),
        (updatedUser) => emit(currentState.copyWith(
          user: updatedUser,
          isPhotoDeleting: false,
        )),
      );
    }
  }

  Future<void> _onLoadTags(LoadTagsEvent event, Emitter<ProfileState> emit) async {
    if (state is ProfileLoaded) {
      final result = await profileRepository.getTags();
      result.fold(
        (failure) => null, // ignore error
        (tags) {
          final current = state;
          if (current is ProfileLoaded) {
            emit(current.copyWith(availableTags: tags));
          }
        },
      );
    }
  }

  Future<void> _onAddProfessionalDocument(AddProfessionalDocumentEvent event, Emitter<ProfileState> emit) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(currentState.copyWith(isDocumentUploading: true));

      try {
        final file = File(event.filePath);
        final bytes = await file.readAsBytes();
        final base64File = base64Encode(bytes);

        final result = await profileRepository.addProfessionalDocument(
          name: event.name,
          fileBase64: base64File,
        );

        result.fold(
          (failure) => emit(currentState.copyWith(isDocumentUploading: false)),
          (updatedUser) => emit(currentState.copyWith(
            user: updatedUser,
            isDocumentUploading: false,
          )),
        );
      } catch (e) {
        emit(currentState.copyWith(isDocumentUploading: false));
      }
    }
  }

  Future<void> _onToggleDocumentVisibility(ToggleDocumentVisibilityEvent event, Emitter<ProfileState> emit) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(currentState.copyWith(isUpdating: true));

      final result = await profileRepository.toggleDocumentVisibility(
        documentId: event.documentId,
        isVisible: event.isVisible,
      );

      result.fold(
        (failure) => emit(currentState.copyWith(isUpdating: false)),
        (updatedUser) => emit(currentState.copyWith(
          user: updatedUser,
          isUpdating: false,
        )),
      );
    }
  }

  Future<void> _onDeleteProfessionalDocument(DeleteProfessionalDocumentEvent event, Emitter<ProfileState> emit) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(currentState.copyWith(isDocumentDeleting: true));

      final result = await profileRepository.deleteProfessionalDocument(
        documentId: event.documentId,
      );

      result.fold(
        (failure) => emit(currentState.copyWith(isDocumentDeleting: false)),
        (updatedUser) => emit(currentState.copyWith(
          user: updatedUser,
          isDocumentDeleting: false,
        )),
      );
    }
  }

  Future<void> _onLoadSpecialties(LoadSpecialtiesEvent event, Emitter<ProfileState> emit) async {
    if (state is ProfileLoaded) {
      final result = await profileRepository.getSpecialties();
      result.fold(
        (failure) => null, // ignore error
        (specialties) {
          final current = state;
          if (current is ProfileLoaded) {
            emit(current.copyWith(availableSpecialties: specialties));
          }
        },
      );
    }
  }

  Future<void> _onLoadSubscriptionPlans(LoadSubscriptionPlansEvent event, Emitter<ProfileState> emit) async {
    if (state is ProfileLoaded) {
      emit((state as ProfileLoaded).copyWith(isLoadingPlans: true));
      final result = await profileRepository.getSubscriptionPlans();
      result.fold(
        (failure) {
          final current = state;
          if (current is ProfileLoaded) {
            emit(current.copyWith(isLoadingPlans: false, errorMessage: failure.message));
          }
        },
        (plans) {
          final current = state;
          if (current is ProfileLoaded) {
            emit(current.copyWith(availablePlans: plans, isLoadingPlans: false, errorMessage: ''));
          }
        },
      );
    }
  }

  Future<void> _onSubscribeToPlan(SubscribeToPlanEvent event, Emitter<ProfileState> emit) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(currentState.copyWith(isSubscribing: true));

      final result = await profileRepository.subscribeToPlan(planId: event.planId);

      result.fold(
        (failure) {
          emit(currentState.copyWith(
            isSubscribing: false,
            errorMessage: failure.message,
          ));
        },
        (updatedUser) => emit(currentState.copyWith(
          user: updatedUser,
          isSubscribing: false,
        )),
      );
    }
  }

  Future<void> _onSetAvatarFromUrl(SetAvatarFromUrlEvent event, Emitter<ProfileState> emit) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(currentState.copyWith(isAvatarUploading: true));

      try {
        final response = await http.get(Uri.parse(event.imageUrl));
        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          final base64Image = base64Encode(bytes);

          final result = await profileRepository.updateProfile(
            firstName: currentState.user.firstName,
            lastName: currentState.user.lastName,
            email: currentState.user.email,
            avatarBase64: base64Image,
          );

          result.fold(
            (failure) {
              if (!isClosed) emit(currentState.copyWith(isAvatarUploading: false));
            },
            (user) {
              if (!isClosed) {
                emit(ProfileLoaded(user: user));
                add(LoadTagsEvent());
                add(LoadSpecialtiesEvent());
              }
            },
          );
        } else {
          if (!isClosed) emit(currentState.copyWith(isAvatarUploading: false));
        }
      } catch (e) {
        if (!isClosed) emit(currentState.copyWith(isAvatarUploading: false));
      }
    }
  }
}
