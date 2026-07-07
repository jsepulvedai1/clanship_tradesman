import 'package:equatable/equatable.dart';

class JobRequestEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final String status;
  final bool isRead;

  const JobRequestEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.status = 'pending',
    this.isRead = false,
  });

  @override
  List<Object?> get props => [id, title, description, createdAt, status, isRead];
}
