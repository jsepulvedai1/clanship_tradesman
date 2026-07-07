import 'package:equatable/equatable.dart';

abstract class ChatRoomEvent extends Equatable {
  const ChatRoomEvent();

  @override
  List<Object?> get props => [];
}

class GetRoomForCustomer extends ChatRoomEvent {
  final int customerId;
  final int? jobId;

  const GetRoomForCustomer(this.customerId, {this.jobId});

  @override
  List<Object?> get props => [customerId, jobId];
}
