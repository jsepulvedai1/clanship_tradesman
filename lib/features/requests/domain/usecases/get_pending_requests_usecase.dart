import 'package:clanship_mobile_tradesman/features/requests/domain/entities/active_request_detail_entity.dart';
import 'package:clanship_mobile_tradesman/features/requests/domain/repositories/requests_repository.dart';

class GetPendingRequestsUseCase {
  final RequestsRepository repository;

  GetPendingRequestsUseCase(this.repository);

  Future<List<ActiveRequestDetailEntity>> call() async {
    return await repository.getPendingRequests();
  }
}
