import 'package:clanship_mobile_tradesman/features/chat/domain/repositories/chat_repository.dart';

class GetOrCreateChatRoomUseCase {
  final ChatRepository repository;

  GetOrCreateChatRoomUseCase(this.repository);

  Future<String> call(int customerId, {int? jobId}) async {
    return await repository.getOrCreateChatRoomWithCustomer(customerId, jobId: jobId);
  }
}
