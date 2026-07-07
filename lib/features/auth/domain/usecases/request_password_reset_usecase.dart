import 'package:fpdart/fpdart.dart';
import 'package:clanship_mobile_tradesman/core/error/failures.dart';
import 'package:clanship_mobile_tradesman/core/usecases/usecase.dart';
import 'package:clanship_mobile_tradesman/features/auth/domain/repositories/auth_repository.dart';

class RequestPasswordResetUseCase implements UseCase<void, String> {
  final AuthRepository repository;

  RequestPasswordResetUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String email) async {
    return await repository.requestPasswordReset(email);
  }
}
