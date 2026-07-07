import 'package:clanship_mobile_tradesman/core/error/failures.dart';
import 'package:clanship_mobile_tradesman/features/home/domain/entities/user_entity.dart';
import 'package:clanship_mobile_tradesman/features/profile/domain/repositories/profile_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateProfileParams {
  final String firstName;
  final String lastName;
  final String email;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? avatarBase64;

  UpdateProfileParams({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.address,
    this.latitude,
    this.longitude,
    this.avatarBase64,
  });
}

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(
      firstName: params.firstName,
      lastName: params.lastName,
      email: params.email,
      address: params.address,
      latitude: params.latitude,
      longitude: params.longitude,
      avatarBase64: params.avatarBase64,
    );
  }
}
