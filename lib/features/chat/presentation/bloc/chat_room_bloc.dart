import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clanship_mobile_tradesman/features/chat/domain/usecases/get_or_create_chat_room_usecase.dart';
import 'package:clanship_mobile_tradesman/features/chat/presentation/bloc/chat_room_event.dart';
import 'package:clanship_mobile_tradesman/features/chat/presentation/bloc/chat_room_state.dart';

class ChatRoomBloc extends Bloc<ChatRoomEvent, ChatRoomState> {
  final GetOrCreateChatRoomUseCase getOrCreateChatRoom;

  ChatRoomBloc({required this.getOrCreateChatRoom}) : super(ChatRoomInitial()) {
    on<GetRoomForCustomer>(_onGetRoomForCustomer);
  }

  Future<void> _onGetRoomForCustomer(
    GetRoomForCustomer event,
    Emitter<ChatRoomState> emit,
  ) async {
    emit(ChatRoomLoading());
    try {
      final roomId = await getOrCreateChatRoom(event.customerId, jobId: event.jobId);
      emit(ChatRoomSuccess(roomId));
    } catch (e) {
      emit(ChatRoomError(e.toString()));
    }
  }
}
