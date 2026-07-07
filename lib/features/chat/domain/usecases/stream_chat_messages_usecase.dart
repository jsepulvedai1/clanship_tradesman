import 'package:clanship_mobile_tradesman/features/chat/domain/entities/chat_message.dart';
import 'package:clanship_mobile_tradesman/features/chat/domain/repositories/chat_repository.dart';

class StreamChatMessagesUseCase {
  final ChatRepository repository;

  StreamChatMessagesUseCase(this.repository);

  Stream<ChatMessage> call(String roomId, int currentUserId) {
    return repository.getMessagesStream(roomId, currentUserId);
  }
}
