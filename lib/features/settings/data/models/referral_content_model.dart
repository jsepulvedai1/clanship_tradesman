import 'package:clanship_mobile_tradesman/features/home/domain/entities/user_entity.dart';

class ReferralContentModel extends ReferralContentEntity {
  const ReferralContentModel({
    super.language,
    super.isActive,
    super.heroTitle,
    super.heroDescription,
    super.shareMessage,
    super.howItWorksTitle,
    super.step1,
    super.step2,
    super.step3,
    super.bannerTitle,
    super.bannerSubtitle,
    super.myPlanInviteText,
    super.activeBenefitText,
    super.registrationCodeLabel,
    super.registrationCodeHint,
  });

  factory ReferralContentModel.fromJson(Map<String, dynamic> json) {
    return ReferralContentModel(
      language: json['language']?.toString() ?? 'es',
      isActive: json['isActive'] == true,
      heroTitle: json['heroTitle']?.toString() ?? '',
      heroDescription: json['heroDescription']?.toString() ?? '',
      shareMessage: json['shareMessage']?.toString() ?? '',
      howItWorksTitle: json['howItWorksTitle']?.toString() ?? '',
      step1: json['step1']?.toString() ?? '',
      step2: json['step2']?.toString() ?? '',
      step3: json['step3']?.toString() ?? '',
      bannerTitle: json['bannerTitle']?.toString() ?? '',
      bannerSubtitle: json['bannerSubtitle']?.toString() ?? '',
      myPlanInviteText: json['myPlanInviteText']?.toString() ?? '',
      activeBenefitText: json['activeBenefitText']?.toString() ?? '',
      registrationCodeLabel: json['registrationCodeLabel']?.toString() ?? '',
      registrationCodeHint: json['registrationCodeHint']?.toString() ?? '',
    );
  }
}
