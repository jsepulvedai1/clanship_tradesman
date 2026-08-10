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

  ActiveRequestDetailEntity copyWith({
    String? id,
    String? category,
    String? instruction,
    String? clientName,
    String? clientPhone,
    String? clientAddress,
    bool? isUrgent,
    int? customerId,
    String? status,
    bool? isRead,
    bool? hasUnreadMessages,
    String? scheduledDate,
    String? scheduledTime,
    double? agreedPrice,
    String? enrichedDetails,
    String? additionalPhotoUrl,
    int? notificationLeadMinutes,
    String? cancellationReason,
    String? cancelledByUserName,
  }) {
    return ActiveRequestDetailEntity(
      id: id ?? this.id,
      category: category ?? this.category,
      instruction: instruction ?? this.instruction,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      clientAddress: clientAddress ?? this.clientAddress,
      customerId: customerId ?? this.customerId,
      status: status ?? this.status,
      isUrgent: isUrgent ?? this.isUrgent,
      isRead: isRead ?? this.isRead,
      hasUnreadMessages: hasUnreadMessages ?? this.hasUnreadMessages,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      agreedPrice: agreedPrice ?? this.agreedPrice,
      enrichedDetails: enrichedDetails ?? this.enrichedDetails,
      additionalPhotoUrl: additionalPhotoUrl ?? this.additionalPhotoUrl,
      notificationLeadMinutes: notificationLeadMinutes ?? this.notificationLeadMinutes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledByUserName: cancelledByUserName ?? this.cancelledByUserName,
    );
  }

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
