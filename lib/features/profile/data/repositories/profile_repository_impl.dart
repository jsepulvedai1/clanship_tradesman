import 'package:clanship_mobile_tradesman/core/error/failures.dart';
import 'package:clanship_mobile_tradesman/features/home/domain/entities/user_entity.dart';
import 'package:clanship_mobile_tradesman/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:clanship_mobile_tradesman/features/profile/domain/repositories/profile_repository.dart';
import 'package:fpdart/fpdart.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, UserEntity>> getMyProfile() async {
    try {
      final userEntity = await remoteDataSource.getMyProfile();
      return Right(userEntity);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? address,
    double? latitude,
    double? longitude,
    String? avatarBase64,
  }) async {
    try {
      final userEntity = await remoteDataSource.updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
        address: address,
        latitude: latitude,
        longitude: longitude,
        avatarBase64: avatarBase64,
      );
      return Right(userEntity);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateAvailability({
    required bool isAvailable,
    bool? isEmergency,
  }) async {
    try {
      final userEntity = await remoteDataSource.updateAvailability(
        isAvailable: isAvailable,
        isEmergency: isEmergency,
      );
      return Right(userEntity);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfessionalProfile({
    String? bio,
    double? hourlyRate,
    int? serviceRadius,
    String? facebookUrl,
    String? instagramUrl,
    String? tiktokUrl,
    List<String>? tagIds,
    String? specialtyId,
    List<String>? specialtyIds,
    List<String>? subtagIds,
  }) async {
    try {
      final userEntity = await remoteDataSource.updateProfessionalProfile(
        bio: bio,
        hourlyRate: hourlyRate,
        serviceRadius: serviceRadius,
        facebookUrl: facebookUrl,
        instagramUrl: instagramUrl,
        tiktokUrl: tiktokUrl,
        tagIds: tagIds,
        specialtyId: specialtyId,
        specialtyIds: specialtyIds,
        subtagIds: subtagIds,
      );
      return Right(userEntity);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> addPortfolioPhoto({
    required String imageBase64,
  }) async {
    try {
      final userEntity = await remoteDataSource.addPortfolioPhoto(imageBase64: imageBase64);
      return Right(userEntity);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> deletePortfolioPhoto({
    required String photoId,
  }) async {
    try {
      final userEntity = await remoteDataSource.deletePortfolioPhoto(photoId: photoId);
      return Right(userEntity);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getTags() async {
    try {
      final tags = await remoteDataSource.getTags();
      return Right(tags);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> addProfessionalDocument({
    required String name,
    required String fileBase64,
  }) async {
    try {
      final user = await remoteDataSource.addProfessionalDocument(name: name, fileBase64: fileBase64);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> toggleDocumentVisibility({
    required String documentId,
    required bool isVisible,
  }) async {
    try {
      final user = await remoteDataSource.toggleDocumentVisibility(documentId: documentId, isVisible: isVisible);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> deleteProfessionalDocument({
    required String documentId,
  }) async {
    try {
      final user = await remoteDataSource.deleteProfessionalDocument(documentId: documentId);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getSpecialties() async {
    try {
      final specialties = await remoteDataSource.getSpecialties();
      return Right(specialties);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SubscriptionPlanEntity>>> getSubscriptionPlans() async {
    try {
      final plans = await remoteDataSource.getSubscriptionPlans();
      return Right(plans);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> subscribeToPlan({required String planId}) async {
    try {
      final user = await remoteDataSource.subscribeToPlan(planId: planId);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
