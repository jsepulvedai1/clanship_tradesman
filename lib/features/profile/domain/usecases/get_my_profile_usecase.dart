import 'package:clanship_mobile_tradesman/core/error/failures.dart';
import 'package:clanship_mobile_tradesman/core/usecases/usecase.dart';
import 'package:clanship_mobile_tradesman/features/home/domain/entities/user_entity.dart';
import 'package:clanship_mobile_tradesman/features/profile/domain/repositories/profile_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetMyProfileUseCase implements UseCase<UserEntity, NoParams> {
  final ProfileRepository repository;

  GetMyProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) async {
    return await repository.getMyProfile();
  }
}
