import 'package:equatable/equatable.dart';

class CompletedJobEntity extends Equatable {
  final String id;
  final String category;
  final String description;
  final String clientName;
  final String date;
  final String time;
  final double amount;
  final bool isUrgent;
  final int? rating;
  final String? reviewComment;

  const CompletedJobEntity({
    required this.id,
    required this.category,
    required this.description,
    required this.clientName,
    required this.date,
    required this.time,
    required this.amount,
    this.isUrgent = false,
    this.rating,
    this.reviewComment,
  });

  @override
  List<Object?> get props => [
        id,
        category,
        description,
        clientName,
        date,
        time,
        amount,
        isUrgent,
        rating,
        reviewComment,
      ];
}
