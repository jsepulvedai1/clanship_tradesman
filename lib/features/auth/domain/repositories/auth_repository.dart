import 'package:fpdart/fpdart.dart';
import 'package:clanship_mobile_tradesman/core/error/failures.dart';
import 'package:clanship_mobile_tradesman/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
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
    List<String>? tagIds,
  });
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, void>> requestPasswordReset(String email);
  Future<Either<Failure, List<Map<String, dynamic>>>> getAvailableTags();
}
