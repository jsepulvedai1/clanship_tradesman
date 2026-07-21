import 'package:clanship_mobile_tradesman/features/auth/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class LogoutRequested extends AuthEvent {}

class UserAuthenticated extends AuthEvent {
  final User user;

  const UserAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

/// Event to update the user's profile picture.
class AvatarUpdated extends AuthEvent {
  final String avatarPath;

  const AvatarUpdated(this.avatarPath);

  @override
  List<Object> get props => [avatarPath];
}

class ProfileUpdated extends AuthEvent {
  final User user;

  const ProfileUpdated(this.user);

  @override
  List<Object> get props => [user];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String birthdate;
  final String address;
  final String phoneNumber;
  final double? latitude;
  final double? longitude;
  final String? avatarPath;
  final String? cedulaFrontPath;
  final String? cedulaBackPath;
  final List<Map<String, String>>? certificates;
  final List<String>? specialtyIds;
  final List<String>? tagIds;
  final List<String>? subtagIds;

  const RegisterRequested({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.birthdate,
    required this.address,
    required this.phoneNumber,
    this.avatarPath,
    this.cedulaFrontPath,
    this.cedulaBackPath,
    this.certificates,
    this.latitude,
    this.longitude,
    this.specialtyIds,
    this.tagIds,
    this.subtagIds,
  });

  @override
  List<Object> get props => [
        email,
        password,
        firstName,
        lastName,
        birthdate,
        address,
        phoneNumber,
        avatarPath ?? '',
        cedulaFrontPath ?? '',
        cedulaBackPath ?? '',
        latitude ?? 0.0,
        longitude ?? 0.0,
        specialtyIds ?? [],
        tagIds ?? [],
        subtagIds ?? [],
      ];
}

class PasswordResetRequested extends AuthEvent {
  final String email;

  const PasswordResetRequested(this.email);

  @override
  List<Object> get props => [email];
}

