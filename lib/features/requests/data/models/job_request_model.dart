import 'package:equatable/equatable.dart';

class CustomerModel extends Equatable {
  final int id;
  final String firstName;
  final String email;
  final String phoneNumber;

  const CustomerModel({
    required this.id,
    required this.firstName,
    required this.email,
    required this.phoneNumber,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      firstName: json['firstName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, firstName, email, phoneNumber];
}

class JobRequestModel extends Equatable {
  final String id;
  final String description;
  final String? scheduledDate;
  final String? scheduledTime;
  final double? agreedPrice;
  final String address;
  final String status;
  final CustomerModel? customer;
  final DateTime? createdAt;
  final bool isRead;
  final String? enrichedDetails;
  final String? additionalPhotoUrl;
  final int? notificationLeadMinutes;
  final bool hasUnreadMessages;
  final String? cancellationReason;
  final String? cancelledByUserName;

  const JobRequestModel({
    required this.id,
    required this.description,
    this.scheduledDate,
    this.scheduledTime,
    this.agreedPrice,
    required this.address,
    required this.status,
    this.customer,
    this.createdAt,
    required this.isRead,
    this.enrichedDetails,
    this.additionalPhotoUrl,
    this.notificationLeadMinutes,
    this.hasUnreadMessages = false,
    this.cancellationReason,
    this.cancelledByUserName,
  });

  factory JobRequestModel.fromJson(Map<String, dynamic> json) {
    return JobRequestModel(
      id: json['id']?.toString() ?? '',
      description: json['description'] ?? '',
      scheduledDate: json['scheduledDate'],
      scheduledTime: json['scheduledTime'],
      agreedPrice: json['agreedPrice'] != null ? double.tryParse(json['agreedPrice'].toString()) : null,
      address: json['address'] ?? '',
      status: json['status'] ?? '',
      customer: json['customer'] != null ? CustomerModel.fromJson(json['customer']) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      isRead: json['isRead'] ?? false,
      hasUnreadMessages: json['hasUnreadMessages'] ?? false,
      enrichedDetails: json['enrichedDetails'],
      additionalPhotoUrl: json['additionalPhotoUrl'],
      notificationLeadMinutes: json['notificationLeadMinutes'] != null
          ? int.tryParse(json['notificationLeadMinutes'].toString())
          : null,
      cancellationReason: json['cancellationReason']?.toString(),
      cancelledByUserName: json['cancelledByUserName']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        description,
        scheduledDate,
        scheduledTime,
        agreedPrice,
        address,
        status,
        customer,
        createdAt,
        isRead,
        hasUnreadMessages,
        enrichedDetails,
        additionalPhotoUrl,
        notificationLeadMinutes,
        cancellationReason,
        cancelledByUserName,
      ];
}
