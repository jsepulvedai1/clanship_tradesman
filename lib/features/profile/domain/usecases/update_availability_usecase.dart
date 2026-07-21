import 'package:clanship_mobile_tradesman/core/error/failures.dart';
import 'package:clanship_mobile_tradesman/core/usecases/usecase.dart';
import 'package:clanship_mobile_tradesman/features/home/domain/entities/user_entity.dart';
import 'package:clanship_mobile_tradesman/features/profile/domain/repositories/profile_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateAvailabilityParams {
  final bool isAvailable;
  final bool? isEmergency;

  UpdateAvailabilityParams({required this.isAvailable, this.isEmergency});
}

class UpdateAvailabilityUseCase implements UseCase<UserEntity, UpdateAvailabilityParams> {
  final ProfileRepository repository;

  UpdateAvailabilityUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(UpdateAvailabilityParams params) async {
    return await repository.updateAvailability(
      isAvailable: params.isAvailable,
      isEmergency: params.isEmergency,
    );
  }
}
