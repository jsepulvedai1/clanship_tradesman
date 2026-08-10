import 'package:clanship_mobile_tradesman/features/auth/data/models/user_model.dart';
import 'package:clanship_mobile_tradesman/features/auth/domain/entities/user.dart';

class UserMapper {
  static User toEntity(UserModel model) {
    return User(
      id: model.id,
      email: model.email,
      name: model.name,
      avatarPath: model.avatarPath,
      firstName: model.firstName,
      lastName: model.lastName,
      phoneNumber: model.phoneNumber,
      address: model.address,
      latitude: model.latitude,
      longitude: model.longitude,
      professionalAddress: model.professionalAddress,
      professionalLatitude: model.professionalLatitude,
      professionalLongitude: model.professionalLongitude,
      isValidated: model.isValidated,
      requiresPlanUpgrade: model.requiresPlanUpgrade,
    );
  }

  static UserModel fromEntity(User entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      avatarPath: entity.avatarPath,
      firstName: entity.firstName,
      lastName: entity.lastName,
      phoneNumber: entity.phoneNumber,
      address: entity.address,
      latitude: entity.latitude,
      longitude: entity.longitude,
      professionalAddress: entity.professionalAddress,
      professionalLatitude: entity.professionalLatitude,
      professionalLongitude: entity.professionalLongitude,
      isValidated: entity.isValidated,
      requiresPlanUpgrade: entity.requiresPlanUpgrade,
    );
  }
}
