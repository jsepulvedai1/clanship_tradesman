import 'package:equatable/equatable.dart';

class ActiveRequestDetailEntity extends Equatable {
  final String id;
  final String category;
  final String instruction;
  final String clientName;
  final String clientPhone;
  final String clientAddress;
  final bool isUrgent;
  final int customerId;
  final String status;
  final bool isRead;
  final bool hasUnreadMessages;

  final String? scheduledDate;
  final String? scheduledTime;
  final double? agreedPrice;
  final String? enrichedDetails;
  final String? additionalPhotoUrl;
  final int? notificationLeadMinutes;
  final String? cancellationReason;
  final String? cancelledByUserName;

  const ActiveRequestDetailEntity({
    required this.id,
    required this.category,
    required this.instruction,
    required this.clientName,
    required this.clientPhone,
    required this.clientAddress,
    required this.customerId,
    this.status = 'REQUESTED',
    this.isUrgent = false,
    this.isRead = false,
    this.hasUnreadMessages = false,
    this.scheduledDate,
    this.scheduledTime,
    this.agreedPrice,
    this.enrichedDetails,
    this.additionalPhotoUrl,
    this.notificationLeadMinutes,
    this.cancellationReason,
    this.cancelledByUserName,
  });

  @override
  List<Object?> get props => [
        id,
        category,
        instruction,
        clientName,
        clientPhone,
        clientAddress,
        isUrgent,
        customerId,
        status,
        isRead,
        hasUnreadMessages,
        scheduledDate,
        scheduledTime,
        agreedPrice,
        enrichedDetails,
        additionalPhotoUrl,
        notificationLeadMinutes,
        cancellationReason,
        cancelledByUserName,
      ];
}
