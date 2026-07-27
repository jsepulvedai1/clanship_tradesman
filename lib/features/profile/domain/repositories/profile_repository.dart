import 'package:clanship_mobile_tradesman/core/error/failures.dart';
import 'package:clanship_mobile_tradesman/features/home/domain/entities/user_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserEntity>> getMyProfile();
  Future<Either<Failure, UserEntity>> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? address,
    double? latitude,
    double? longitude,
    String? avatarBase64,
  });
  Future<Either<Failure, UserEntity>> updateAvailability({
    required bool isAvailable,
    bool? isEmergency,
  });

  Future<Either<Failure, UserEntity>> updateProfessionalProfile({
    String? bio,
    double? hourlyRate,
    int? serviceRadius,
    String? facebookUrl,
    String? instagramUrl,
    String? tiktokUrl,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? tagIds,
    String? specialtyId,
    List<String>? specialtyIds,
    List<String>? subtagIds,
  });
  Future<Either<Failure, List<Map<String, dynamic>>>> getSpecialties();
  Future<Either<Failure, UserEntity>> addPortfolioPhoto({
    required String imageBase64,
  });
  Future<Either<Failure, UserEntity>> deletePortfolioPhoto({
    required String photoId,
  });
  Future<Either<Failure, List<Map<String, dynamic>>>> getTags();
  Future<Either<Failure, UserEntity>> addProfessionalDocument({
    required String name,
    required String fileBase64,
  });
  Future<Either<Failure, UserEntity>> toggleDocumentVisibility({
    required String documentId,
    required bool isVisible,
  });
  Future<Either<Failure, UserEntity>> deleteProfessionalDocument({
    required String documentId,
  });
  Future<Either<Failure, List<SubscriptionPlanEntity>>> getSubscriptionPlans();
  Future<Either<Failure, UserEntity>> subscribeToPlan({required String planId});
}
