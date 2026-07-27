import 'package:clanship_mobile_tradesman/core/error/failures.dart';
import 'package:clanship_mobile_tradesman/core/usecases/usecase.dart';
import 'package:clanship_mobile_tradesman/features/auth/domain/entities/user.dart';
import 'package:clanship_mobile_tradesman/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class RegisterUseCase implements UseCase<User, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterParams params) async {
    return await repository.register(
      email: params.email,
      password: params.password,
      firstName: params.firstName,
      lastName: params.lastName,
      address: params.address,
      phoneNumber: params.phoneNumber,
      avatarPath: params.avatarPath,
      cedulaFrontPath: params.cedulaFrontPath,
      cedulaBackPath: params.cedulaBackPath,
      certificates: params.certificates,
      latitude: params.latitude,
      longitude: params.longitude,
      specialtyIds: params.specialtyIds,
      tagIds: params.tagIds,
      subtagIds: params.subtagIds,
      bio: params.bio,
      workPhotoPaths: params.workPhotoPaths,
    );
  }
}

class RegisterParams {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? address;
  final String? phoneNumber;
  final String? avatarPath;
  final String? cedulaFrontPath;
  final String? cedulaBackPath;
  final List<Map<String, String>>? certificates;
  final double? latitude;
  final double? longitude;
  final List<String>? specialtyIds;
  final List<String>? tagIds;
  final List<String>? subtagIds;
  final String? bio;
  final List<String>? workPhotoPaths;

  RegisterParams({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.address,
    this.phoneNumber,
    this.avatarPath,
    this.cedulaFrontPath,
    this.cedulaBackPath,
    this.certificates,
    this.latitude,
    this.longitude,
    this.specialtyIds,
    this.tagIds,
    this.subtagIds,
    this.bio,
    this.workPhotoPaths,
  });
}
