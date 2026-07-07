import 'package:clanship_mobile_tradesman/core/error/failures.dart';
import 'package:clanship_mobile_tradesman/core/usecases/usecase.dart';
import 'package:clanship_mobile_tradesman/features/home/domain/entities/user_entity.dart';
import 'package:clanship_mobile_tradesman/features/profile/domain/repositories/profile_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetSubscriptionPlansUseCase implements UseCase<List<SubscriptionPlanEntity>, NoParams> {
  final ProfileRepository repository;

  GetSubscriptionPlansUseCase(this.repository);

  @override
  Future<Either<Failure, List<SubscriptionPlanEntity>>> call(NoParams params) async {
    return await repository.getSubscriptionPlans();
  }
}

class SubscribeToPlanUseCase implements UseCase<UserEntity, String> {
  final ProfileRepository repository;

  SubscribeToPlanUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(String planId) async {
    return await repository.subscribeToPlan(planId: planId);
  }
}
