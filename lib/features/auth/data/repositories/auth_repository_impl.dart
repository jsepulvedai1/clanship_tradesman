import 'package:clanship_mobile_tradesman/core/error/failures.dart';
import 'package:clanship_mobile_tradesman/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:clanship_mobile_tradesman/features/auth/data/mappers/user_mapper.dart';
import 'package:clanship_mobile_tradesman/features/auth/domain/entities/user.dart';
import 'package:clanship_mobile_tradesman/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final userModel = await remoteDataSource.login(email, password);
      return Right(UserMapper.toEntity(userModel));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? address,
    String? phoneNumber,
    String? avatarPath,
    String? cedulaFrontPath,
    String? cedulaBackPath,
    List<Map<String, String>>? certificates,
    double? latitude,
    double? longitude,
    List<String>? specialtyIds,
    List<String>? tagIds,
    List<String>? subtagIds,
  }) async {
    try {
      final userModel = await remoteDataSource.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        address: address,
        phoneNumber: phoneNumber,
        avatarPath: avatarPath,
        cedulaFrontPath: cedulaFrontPath,
        cedulaBackPath: cedulaBackPath,
        certificates: certificates,
        latitude: latitude,
        longitude: longitude,
        specialtyIds: specialtyIds,
        tagIds: tagIds,
        subtagIds: subtagIds,
      );
      return Right(UserMapper.toEntity(userModel));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAvailableTags() async {
    try {
      final tags = await remoteDataSource.getAvailableTags();
      return Right(tags);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return Right(UserMapper.toEntity(userModel));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> requestPasswordReset(String email) async {
    try {
      await remoteDataSource.requestPasswordReset(email);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
