import 'package:clanship_mobile_tradesman/core/error/failures.dart';
import 'package:clanship_mobile_tradesman/core/usecases/usecase.dart';
import 'package:clanship_mobile_tradesman/features/auth/domain/repositories/auth_repository.dart';
import 'package:clanship_mobile_tradesman/features/profile/domain/repositories/profile_repository.dart';
import 'package:fpdart/fpdart.dart';

class LogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository authRepository;
  final ProfileRepository profileRepository;

  LogoutUseCase(this.authRepository, this.profileRepository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    // 1. Primero marcamos disponibilidad como false
    await profileRepository.updateAvailability(isAvailable: false, isEmergency: false);

    // 2. Luego cerramos sesión
    return await authRepository.logout();
  }
}
