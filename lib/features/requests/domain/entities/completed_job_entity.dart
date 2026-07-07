import 'package:equatable/equatable.dart';

class CompletedJobEntity extends Equatable {
  final String id;
  final String category;
  final String description;
  final String date;
  final String time;
  final double amount;
  final bool isUrgent;

  const CompletedJobEntity({
    required this.id,
    required this.category,
    required this.description,
    required this.date,
    required this.time,
    required this.amount,
    this.isUrgent = false,
  });

  @override
  List<Object?> get props => [
        id,
        category,
        description,
        date,
        time,
        amount,
        isUrgent,
      ];
}
