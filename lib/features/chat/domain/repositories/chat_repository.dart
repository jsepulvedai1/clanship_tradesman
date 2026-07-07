import 'package:clanship_mobile_tradesman/features/chat/domain/entities/chat_message.dart';

abstract class ChatRepository {
  Future<String> getOrCreateChatRoomWithCustomer(int customerId, {int? jobId});
  Future<List<ChatMessage>> getMessagesHistory(String roomId, int currentUserId);
  Stream<ChatMessage> getMessagesStream(String roomId, int currentUserId);
  Future<void> sendMessage(String roomId, String text);
  void closeChat();
}
