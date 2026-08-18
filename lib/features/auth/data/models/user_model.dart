import 'package:clanship_mobile_tradesman/features/auth/domain/entities/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.avatarPath,
    super.firstName,
    super.lastName,
    super.phoneNumber,
    super.address,
    super.latitude,
    super.longitude,
    super.professionalAddress,
    super.professionalLatitude,
    super.professionalLongitude,
    super.isValidated = false,
    super.verificationStatus = 'PENDING',
    super.rejectionReason,
    super.requiresPlanUpgrade = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = Map<String, dynamic>.from(json);
    if (!data.containsKey('name') || data['name'] == null) {
      final firstName = data['firstName'] as String? ?? '';
      final lastName = data['lastName'] as String? ?? '';
      data['name'] = [firstName, lastName].where((e) => e.isNotEmpty).join(' ');
      if ((data['name'] as String).isEmpty) {
        data['name'] = data['username'] ?? data['email'] ?? 'Usuario';
      }
    }
    
    // Map avatarUrl from backend to avatarPath
    if (data.containsKey('avatarUrl') && data['avatarUrl'] != null) {
      data['avatarPath'] = data['avatarUrl'];
    }

    // Convertir latitude y longitude de String a num si vienen como String (Graphene DecimalField)
    if (data['latitude'] is String) {
      data['latitude'] = double.tryParse(data['latitude']);
    }
    if (data['longitude'] is String) {
      data['longitude'] = double.tryParse(data['longitude']);
    }
    
    bool isVal = data['isValidated'] == true || data['isVerified'] == true;
    String vStatus = data['verificationStatus']?.toString() ?? 'PENDING';
    String? rReason = data['rejectionReason']?.toString();

    // Map professionalProfile address and coordinates independently
    if (data['professionalProfile'] != null &&
        data['professionalProfile'] is Map) {
      final prof = data['professionalProfile'] as Map<String, dynamic>;
      data['professionalAddress'] = prof['address']?.toString();
      if (prof['latitude'] != null) {
        data['professionalLatitude'] = double.tryParse(prof['latitude'].toString());
      }
      if (prof['longitude'] != null) {
        data['professionalLongitude'] = double.tryParse(prof['longitude'].toString());
      }
      if (prof['isVerified'] == true) {
        isVal = true;
      }
      if (prof['verificationStatus'] != null) {
        vStatus = prof['verificationStatus'].toString();
      }
      if (prof['rejectionReason'] != null) {
        rReason = prof['rejectionReason'].toString();
      }
      if (prof['requiresPlanUpgrade'] == true || prof['requiresPlanUpgrade'] == 'true') {
        data['requiresPlanUpgrade'] = true;
      }
    }
    
    final user = _$UserModelFromJson(data);
    return user.copyWith(
      isValidated: isVal,
      verificationStatus: vStatus,
      rejectionReason: rReason,
      requiresPlanUpgrade: data['requiresPlanUpgrade'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  @override
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarPath,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? address,
    double? latitude,
    double? longitude,
    String? professionalAddress,
    double? professionalLatitude,
    double? professionalLongitude,
    bool? isValidated,
    String? verificationStatus,
    String? rejectionReason,
    bool? requiresPlanUpgrade,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      professionalAddress: professionalAddress ?? this.professionalAddress,
      professionalLatitude: professionalLatitude ?? this.professionalLatitude,
      professionalLongitude: professionalLongitude ?? this.professionalLongitude,
      isValidated: isValidated ?? this.isValidated,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      requiresPlanUpgrade: requiresPlanUpgrade ?? this.requiresPlanUpgrade,
    );
  }
}

