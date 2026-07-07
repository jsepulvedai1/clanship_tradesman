import 'package:equatable/equatable.dart';

abstract class ChatRoomState extends Equatable {
  const ChatRoomState();

  @override
  List<Object?> get props => [];
}

class ChatRoomInitial extends ChatRoomState {}

class ChatRoomLoading extends ChatRoomState {}

class ChatRoomSuccess extends ChatRoomState {
  final String roomId;

  const ChatRoomSuccess(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

class ChatRoomError extends ChatRoomState {
  final String message;

  const ChatRoomError(this.message);

  @override
  List<Object?> get props => [message];
}
