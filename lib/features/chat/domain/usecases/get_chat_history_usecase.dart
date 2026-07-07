import 'package:clanship_mobile_tradesman/features/chat/domain/entities/chat_message.dart';
import 'package:clanship_mobile_tradesman/features/chat/domain/repositories/chat_repository.dart';

class GetChatHistoryUseCase {
  final ChatRepository repository;

  GetChatHistoryUseCase(this.repository);

  Future<List<ChatMessage>> call(String roomId, int currentUserId) async {
    return await repository.getMessagesHistory(roomId, currentUserId);
  }
}
