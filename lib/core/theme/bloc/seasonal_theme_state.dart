import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';
import 'package:clanship_mobile_tradesman/core/theme/models/seasonal_campaign_model.dart';

class SeasonalThemeState extends Equatable {
  final SeasonalCampaignModel? campaign;
  final bool isLoaded;

  const SeasonalThemeState({
    this.campaign,
    this.isLoaded = false,
  });

  bool get hasActiveCampaign => campaign != null;

  Color get primaryColor => campaign?.colors.primary ?? AppColors.primaryAzure;
  Color get secondaryColor => campaign?.colors.secondary ?? AppColors.primaryBlue;
  Color get accentColor => campaign?.colors.accent ?? AppColors.accentCyan;

  Color get searchBarBorderColor =>
      campaign?.colors.searchBarBorder ?? accentColor;

  Color get navCenterColor =>
      campaign?.colors.navCenter ?? primaryColor;

  String? get navCenterIconUrl =>
      campaign?.visuals.navCenterIconUrl;

  bool get showTopGarland =>
      campaign?.visuals.showTopGarland ?? false;

  String get garlandPosition =>
      campaign?.visuals.garlandPosition ?? 'BOTH';

  bool get showGarlandTop =>
      campaign?.visuals.showGarlandTop ?? false;

  bool get showGarlandBottom =>
      campaign?.visuals.showGarlandBottom ?? false;

  String? get customGarlandUrl =>
      campaign?.visuals.customGarlandUrl;

  Color? get statCardsBgColor =>
      campaign?.colors.statCardsBg;

  Color? get statCardActiveBgColor =>
      campaign?.colors.statCardActiveBg ?? statCardsBgColor;

  Color? get statCardCompletedBgColor =>
      campaign?.colors.statCardCompletedBg ?? statCardsBgColor;

  Color? get statCardRejectedBgColor =>
      campaign?.colors.statCardRejectedBg ?? statCardsBgColor;

  Color? get statCardScheduledBgColor =>
      campaign?.colors.statCardScheduledBg ?? statCardsBgColor;

  String? get statCardsBgImageUrl =>
      campaign?.visuals.statCardsBgImageUrl;

  String? get statCardActiveBgImageUrl =>
      campaign?.visuals.statCardActiveBgImageUrl ?? statCardsBgImageUrl;

  String? get statCardCompletedBgImageUrl =>
      campaign?.visuals.statCardCompletedBgImageUrl ?? statCardsBgImageUrl;

  String? get statCardRejectedBgImageUrl =>
      campaign?.visuals.statCardRejectedBgImageUrl ?? statCardsBgImageUrl;

  String? get statCardScheduledBgImageUrl =>
      campaign?.visuals.statCardScheduledBgImageUrl ?? statCardsBgImageUrl;

  // Opacidad de imagen en tarjetas (0.0 a 1.0)
  double get statCardsImageOpacity =>
      campaign?.visuals.statCardsImageOpacity ?? 0.25;
  double get statCardActiveImageOpacity =>
      campaign?.visuals.statCardActiveImageOpacity ?? statCardsImageOpacity;
  double get statCardCompletedImageOpacity =>
      campaign?.visuals.statCardCompletedImageOpacity ?? statCardsImageOpacity;
  double get statCardRejectedImageOpacity =>
      campaign?.visuals.statCardRejectedImageOpacity ?? statCardsImageOpacity;
  double get statCardScheduledImageOpacity =>
      campaign?.visuals.statCardScheduledImageOpacity ?? statCardsImageOpacity;

  // Color de números (valores)
  Color? get statCardsNumberColor =>
      campaign?.colors.statCardsNumber;
  Color? get statCardActiveNumberColor =>
      campaign?.colors.statCardActiveNumber ?? statCardsNumberColor;
  Color? get statCardCompletedNumberColor =>
      campaign?.colors.statCardCompletedNumber ?? statCardsNumberColor;
  Color? get statCardRejectedNumberColor =>
      campaign?.colors.statCardRejectedNumber ?? statCardsNumberColor;
  Color? get statCardScheduledNumberColor =>
      campaign?.colors.statCardScheduledNumber ?? statCardsNumberColor;

  // Color de textos (etiquetas)
  Color? get statCardsTextColor =>
      campaign?.colors.statCardsText;
  Color? get statCardActiveTextColor =>
      campaign?.colors.statCardActiveText ?? statCardsTextColor;
  Color? get statCardCompletedTextColor =>
      campaign?.colors.statCardCompletedText ?? statCardsTextColor;
  Color? get statCardRejectedTextColor =>
      campaign?.colors.statCardRejectedText ?? statCardsTextColor;
  Color? get statCardScheduledTextColor =>
      campaign?.colors.statCardScheduledText ?? statCardsTextColor;

  // Color de iconos
  Color? get statCardsIconColor =>
      campaign?.colors.statCardsIcon;
  Color? get statCardActiveIconColor =>
      campaign?.colors.statCardActiveIcon ?? statCardsIconColor;
  Color? get statCardCompletedIconColor =>
      campaign?.colors.statCardCompletedIcon ?? statCardsIconColor;
  Color? get statCardRejectedIconColor =>
      campaign?.colors.statCardRejectedIcon ?? statCardsIconColor;
  Color? get statCardScheduledIconColor =>
      campaign?.colors.statCardScheduledIcon ?? statCardsIconColor;

  List<Color> get headerGradient {
    final start = campaign?.colors.headerGradientStart ?? AppColors.primaryBlue;
    final end = campaign?.colors.headerGradientEnd ?? const Color(0xFF163E63);
    return [start, end];
  }

  SeasonalThemeState copyWith({
    SeasonalCampaignModel? campaign,
    bool? isLoaded,
    bool clearCampaign = false,
  }) {
    return SeasonalThemeState(
      campaign: clearCampaign ? null : (campaign ?? this.campaign),
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  @override
  List<Object?> get props => [campaign, isLoaded];
}
