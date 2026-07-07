import 'package:clanship_mobile_tradesman/core/error/failures.dart';
import 'package:clanship_mobile_tradesman/core/usecases/usecase.dart';
import 'package:clanship_mobile_tradesman/features/auth/domain/entities/user.dart';
import 'package:clanship_mobile_tradesman/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetCurrentUserUseCase implements UseCase<User, NoParams> {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}
