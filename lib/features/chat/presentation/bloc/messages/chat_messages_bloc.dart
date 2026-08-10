import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clanship_mobile_tradesman/core/utils/error_parser.dart';
import 'package:clanship_mobile_tradesman/features/chat/domain/entities/chat_message.dart';
import 'package:clanship_mobile_tradesman/features/chat/domain/usecases/get_chat_history_usecase.dart';
import 'package:clanship_mobile_tradesman/features/chat/domain/usecases/stream_chat_messages_usecase.dart';
import 'package:clanship_mobile_tradesman/features/chat/domain/usecases/send_chat_message_usecase.dart';
import 'package:clanship_mobile_tradesman/features/chat/domain/repositories/chat_repository.dart';
import 'package:clanship_mobile_tradesman/features/chat/presentation/bloc/messages/chat_messages_event.dart';
import 'package:clanship_mobile_tradesman/features/chat/presentation/bloc/messages/chat_messages_state.dart';

class ChatMessagesBloc extends Bloc<ChatMessagesEvent, ChatMessagesState> {
  final GetChatHistoryUseCase getChatHistory;
  final StreamChatMessagesUseCase streamChatMessages;
  final SendChatMessageUseCase sendChatMessage;
  final ChatRepository repository;

  StreamSubscription? _messagesSubscription;
  StreamSubscription? _jobStatusSubscription;

  ChatMessagesBloc({
    required this.getChatHistory,
    required this.streamChatMessages,
    required this.sendChatMessage,
    required this.repository,
  }) : super(ChatMessagesInitial()) {
    on<LoadChatMessages>(_onLoadChatMessages);
    on<MessageReceived>(_onMessageReceived);
    on<JobStatusUpdatedEvent>(_onJobStatusUpdated);
    on<SendMessage>(_onSendMessage);
    on<CloseChatConnection>(_onCloseChatConnection);
  }

  Future<void> _onLoadChatMessages(
    LoadChatMessages event,
    Emitter<ChatMessagesState> emit,
  ) async {
    emit(ChatMessagesLoading());
    try {
      // 1. Fetch History
      final history = await getChatHistory(event.roomId, event.currentUserId);
      
      // Sort history to show older messages first
      history.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      emit(ChatMessagesLoaded(history));

      // 2. Subscribe to WebSocket Stream for messages
      _messagesSubscription?.cancel();
      _messagesSubscription = streamChatMessages(event.roomId, event.currentUserId)
          .listen(
        (message) {
          add(MessageReceived(message));
        },
        onError: (error) {},
      );

      // 3. Subscribe to Job Status events
      _jobStatusSubscription?.cancel();
      _jobStatusSubscription = repository.getJobStatusStream(event.roomId).listen(
        (eventData) {
          final newStatus = eventData['new_status']?.toString();
          final cancellationReason = eventData['cancellation_reason']?.toString();
          if (newStatus != null && newStatus.isNotEmpty) {
            add(JobStatusUpdatedEvent(
              newStatus: newStatus,
              cancellationReason: cancellationReason,
            ));
          }
        },
        onError: (_) {},
      );
    } catch (e) {
      emit(ChatMessagesError(sanitizeErrorForUser(e)));
    }
  }

  void _onMessageReceived(
    MessageReceived event,
    Emitter<ChatMessagesState> emit,
  ) {
    if (state is ChatMessagesLoaded) {
      final currentState = state as ChatMessagesLoaded;
      
      if (!currentState.messages.any((m) => m.id == event.message.id)) {
        final updatedMessages = List.of(currentState.messages)..add(event.message);

        String? newStatus = currentState.jobStatus;
        if (event.message.text.contains('aceptada por el cliente')) {
          newStatus = 'AGREED';
        } else if (event.message.text.contains('rechazada por el cliente') ||
                   event.message.text.contains('cancelada por el cliente')) {
          newStatus = 'CANCELLED';
        } else if (event.message.type == ChatMessageType.appointment && newStatus == null) {
          newStatus = 'SCHEDULED';
        }

        emit(ChatMessagesLoaded(
          updatedMessages,
          jobStatus: newStatus,
          cancellationReason: currentState.cancellationReason,
        ));
      }
    }
  }

  void _onJobStatusUpdated(
    JobStatusUpdatedEvent event,
    Emitter<ChatMessagesState> emit,
  ) {
    if (state is ChatMessagesLoaded) {
      final currentState = state as ChatMessagesLoaded;
      emit(ChatMessagesLoaded(
        currentState.messages,
        jobStatus: event.newStatus,
        cancellationReason: event.cancellationReason,
      ));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatMessagesState> emit,
  ) async {
    try {
      await sendChatMessage(
        event.roomId,
        event.text,
        fileBase64: event.fileBase64,
        fileName: event.fileName,
        messageType: event.messageType,
      );
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  void _onCloseChatConnection(
    CloseChatConnection event,
    Emitter<ChatMessagesState> emit,
  ) {
    _messagesSubscription?.cancel();
    _jobStatusSubscription?.cancel();
    repository.closeChat();
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    _jobStatusSubscription?.cancel();
    repository.closeChat();
    return super.close();
  }
}
