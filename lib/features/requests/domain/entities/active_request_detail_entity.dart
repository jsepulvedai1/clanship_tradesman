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

  final String? scheduledDate;
  final String? scheduledTime;
  final double? agreedPrice;
  final String? enrichedDetails;
  final String? additionalPhotoUrl;
  final int? notificationLeadMinutes;

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
    this.scheduledDate,
    this.scheduledTime,
    this.agreedPrice,
    this.enrichedDetails,
    this.additionalPhotoUrl,
    this.notificationLeadMinutes,
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
        scheduledDate,
        scheduledTime,
        agreedPrice,
        enrichedDetails,
        additionalPhotoUrl,
        notificationLeadMinutes,
      ];
}
