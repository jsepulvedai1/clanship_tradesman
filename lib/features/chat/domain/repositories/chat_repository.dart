import 'package:clanship_mobile_tradesman/features/chat/domain/entities/chat_message.dart';

abstract class ChatRepository {
  Future<String> getOrCreateChatRoomWithCustomer(int customerId, {int? jobId});
  Future<List<ChatMessage>> getMessagesHistory(String roomId, int currentUserId);
  Stream<ChatMessage> getMessagesStream(String roomId, int currentUserId);
  Stream<Map<String, dynamic>> getJobStatusStream(String roomId);
  Future<void> sendMessage(
    String roomId, 
    String text, {
    String? fileBase64, 
    String? fileName, 
    String? messageType,
  });
  void closeChat();
}
