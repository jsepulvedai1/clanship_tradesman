import 'package:flutter/material.dart';

class SeasonalColors {
  final Color? primary;
  final Color? secondary;
  final Color? accent;
  final Color? headerGradientStart;
  final Color? headerGradientEnd;
  final Color? searchBarBorder;
  final Color? navCenter;
  final Color? statCardsBg;
  final Color? statCardsNumber;
  final Color? statCardsText;
  final Color? statCardsIcon;
  final Color? statCardActiveBg;
  final Color? statCardActiveNumber;
  final Color? statCardActiveText;
  final Color? statCardActiveIcon;
  final Color? statCardCompletedBg;
  final Color? statCardCompletedNumber;
  final Color? statCardCompletedText;
  final Color? statCardCompletedIcon;
  final Color? statCardRejectedBg;
  final Color? statCardRejectedNumber;
  final Color? statCardRejectedText;
  final Color? statCardRejectedIcon;
  final Color? statCardScheduledBg;
  final Color? statCardScheduledNumber;
  final Color? statCardScheduledText;
  final Color? statCardScheduledIcon;

  const SeasonalColors({
    this.primary,
    this.secondary,
    this.accent,
    this.headerGradientStart,
    this.headerGradientEnd,
    this.searchBarBorder,
    this.navCenter,
    this.statCardsBg,
    this.statCardsNumber,
    this.statCardsText,
    this.statCardsIcon,
    this.statCardActiveBg,
    this.statCardActiveNumber,
    this.statCardActiveText,
    this.statCardActiveIcon,
    this.statCardCompletedBg,
    this.statCardCompletedNumber,
    this.statCardCompletedText,
    this.statCardCompletedIcon,
    this.statCardRejectedBg,
    this.statCardRejectedNumber,
    this.statCardRejectedText,
    this.statCardRejectedIcon,
    this.statCardScheduledBg,
    this.statCardScheduledNumber,
    this.statCardScheduledText,
    this.statCardScheduledIcon,
  });

  static Color? parseHex(String? hexString) {
    if (hexString == null || hexString.isEmpty) return null;
    try {
      String cleanHex = hexString.replaceAll('#', '').trim();
      if (cleanHex.length == 6) {
        cleanHex = 'FF$cleanHex';
      }
      return Color(int.parse(cleanHex, radix: 16));
    } catch (_) {
      return null;
    }
  }

  factory SeasonalColors.fromJson(Map<String, dynamic> json) {
    return SeasonalColors(
      primary: parseHex(json['primary']?.toString()),
      secondary: parseHex(json['secondary']?.toString()),
      accent: parseHex(json['accent']?.toString()),
      headerGradientStart: parseHex(json['header_gradient_start']?.toString()),
      headerGradientEnd: parseHex(json['header_gradient_end']?.toString()),
      searchBarBorder: parseHex(json['search_bar_border']?.toString()),
      navCenter: parseHex(json['nav_center']?.toString()),
      statCardsBg: parseHex(json['stat_cards_bg']?.toString()),
      statCardsNumber: parseHex(json['stat_cards_number']?.toString()),
      statCardsText: parseHex(json['stat_cards_text']?.toString()),
      statCardsIcon: parseHex(json['stat_cards_icon']?.toString()),
      statCardActiveBg: parseHex(json['stat_card_active_bg']?.toString()),
      statCardActiveNumber: parseHex(json['stat_card_active_number']?.toString()),
      statCardActiveText: parseHex(json['stat_card_active_text']?.toString()),
      statCardActiveIcon: parseHex(json['stat_card_active_icon']?.toString()),
      statCardCompletedBg: parseHex(json['stat_card_completed_bg']?.toString()),
      statCardCompletedNumber: parseHex(json['stat_card_completed_number']?.toString()),
      statCardCompletedText: parseHex(json['stat_card_completed_text']?.toString()),
      statCardCompletedIcon: parseHex(json['stat_card_completed_icon']?.toString()),
      statCardRejectedBg: parseHex(json['stat_card_rejected_bg']?.toString()),
      statCardRejectedNumber: parseHex(json['stat_card_rejected_number']?.toString()),
      statCardRejectedText: parseHex(json['stat_card_rejected_text']?.toString()),
      statCardRejectedIcon: parseHex(json['stat_card_rejected_icon']?.toString()),
      statCardScheduledBg: parseHex(json['stat_card_scheduled_bg']?.toString()),
      statCardScheduledNumber: parseHex(json['stat_card_scheduled_number']?.toString()),
      statCardScheduledText: parseHex(json['stat_card_scheduled_text']?.toString()),
      statCardScheduledIcon: parseHex(json['stat_card_scheduled_icon']?.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary': primary != null
          ? '#${primary!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'secondary': secondary != null
          ? '#${secondary!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'accent': accent != null
          ? '#${accent!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'header_gradient_start': headerGradientStart != null
          ? '#${headerGradientStart!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'header_gradient_end': headerGradientEnd != null
          ? '#${headerGradientEnd!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'search_bar_border': searchBarBorder != null
          ? '#${searchBarBorder!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'nav_center': navCenter != null
          ? '#${navCenter!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'stat_cards_bg': statCardsBg != null
          ? '#${statCardsBg!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'stat_cards_number': statCardsNumber != null
          ? '#${statCardsNumber!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'stat_cards_text': statCardsText != null
          ? '#${statCardsText!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'stat_cards_icon': statCardsIcon != null
          ? '#${statCardsIcon!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'stat_card_active_bg': statCardActiveBg != null
          ? '#${statCardActiveBg!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'stat_card_active_number': statCardActiveNumber != null
          ? '#${statCardActiveNumber!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'stat_card_active_text': statCardActiveText != null
          ? '#${statCardActiveText!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'stat_card_active_icon': statCardActiveIcon != null
          ? '#${statCardActiveIcon!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'stat_card_completed_bg': statCardCompletedBg != null
          ? '#${statCardCompletedBg!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'stat_card_completed_number': statCardCompletedNumber != null
          ? '#${statCardCompletedNumber!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'stat_card_completed_text': statCardCompletedText != null
          ? '#${statCardCompletedText!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'stat_card_completed_icon': statCardCompletedIcon != null
          ? '#${statCardCompletedIcon!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'stat_card_rejected_bg': statCardRejectedBg != null
          ? '#${statCardRejectedBg!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'stat_card_rejected_number': statCardRejectedNumber != null
          ? '#${statCardRejectedNumber!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'stat_card_rejected_text': statCardRejectedText != null
          ? '#${statCardRejectedText!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'stat_card_rejected_icon': statCardRejectedIcon != null
          ? '#${statCardRejectedIcon!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'stat_card_scheduled_bg': statCardScheduledBg != null
          ? '#${statCardScheduledBg!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'stat_card_scheduled_number': statCardScheduledNumber != null
          ? '#${statCardScheduledNumber!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'stat_card_scheduled_text': statCardScheduledText != null
          ? '#${statCardScheduledText!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      'stat_card_scheduled_icon': statCardScheduledIcon != null
          ? '#${statCardScheduledIcon!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
    };
  }
}

class SeasonalVisuals {
  final String? logoBadgeUrl;
  final String? navCenterIconUrl;
  final String? bannerImageUrl;
  final String? statCardsBgImageUrl;
  final String? statCardActiveBgImageUrl;
  final String? statCardCompletedBgImageUrl;
  final String? statCardRejectedBgImageUrl;
  final String? statCardScheduledBgImageUrl;
  final double? statCardsImageOpacity;
  final double? statCardActiveImageOpacity;
  final double? statCardCompletedImageOpacity;
  final double? statCardRejectedImageOpacity;
  final double? statCardScheduledImageOpacity;
  final bool showTopGarland;
  final String garlandPosition; // BOTH, TOP, BOTTOM
  final bool showGarlandTop;
  final bool showGarlandBottom;
  final String? customGarlandUrl;
  final String particleEffect; // NONE, CONFETTI, SNOW, STARS

  const SeasonalVisuals({
    this.logoBadgeUrl,
    this.navCenterIconUrl,
    this.bannerImageUrl,
    this.statCardsBgImageUrl,
    this.statCardActiveBgImageUrl,
    this.statCardCompletedBgImageUrl,
    this.statCardRejectedBgImageUrl,
    this.statCardScheduledBgImageUrl,
    this.statCardsImageOpacity,
    this.statCardActiveImageOpacity,
    this.statCardCompletedImageOpacity,
    this.statCardRejectedImageOpacity,
    this.statCardScheduledImageOpacity,
    this.showTopGarland = false,
    this.garlandPosition = 'BOTH',
    this.showGarlandTop = false,
    this.showGarlandBottom = false,
    this.customGarlandUrl,
    this.particleEffect = 'NONE',
  });

  static String? _sanitizeUrl(dynamic url) {
    if (url == null) return null;
    String s = url.toString().trim();
    if (s.isEmpty) return null;
    if (s.startsWith('http://api.clanship.cl')) {
      return s.replaceFirst('http://', 'https://');
    }
    return s;
  }

  static double? _parseOpacity(dynamic val) {
    if (val == null) return null;
    final num? n = num.tryParse(val.toString());
    if (n == null) return null;
    return (n.clamp(0, 100) / 100.0).toDouble();
  }

  factory SeasonalVisuals.fromJson(Map<String, dynamic> json) {
    final showTopGarland = json['show_top_garland'] == true;
    final garlandPos = json['garland_position']?.toString() ?? 'BOTH';
    final showTop = json.containsKey('show_garland_top')
        ? json['show_garland_top'] == true
        : (showTopGarland && (garlandPos == 'BOTH' || garlandPos == 'TOP'));
    final showBottom = json.containsKey('show_garland_bottom')
        ? json['show_garland_bottom'] == true
        : (showTopGarland && (garlandPos == 'BOTH' || garlandPos == 'BOTTOM'));

    return SeasonalVisuals(
      logoBadgeUrl: _sanitizeUrl(json['logo_badge_url']),
      navCenterIconUrl: _sanitizeUrl(json['nav_center_icon_url']),
      bannerImageUrl: _sanitizeUrl(json['banner_image_url']),
      statCardsBgImageUrl: _sanitizeUrl(json['stat_cards_bg_image_url']),
      statCardActiveBgImageUrl: _sanitizeUrl(json['stat_card_active_bg_image_url']),
      statCardCompletedBgImageUrl: _sanitizeUrl(json['stat_card_completed_bg_image_url']),
      statCardRejectedBgImageUrl: _sanitizeUrl(json['stat_card_rejected_bg_image_url']),
      statCardScheduledBgImageUrl: _sanitizeUrl(json['stat_card_scheduled_bg_image_url']),
      statCardsImageOpacity: _parseOpacity(json['stat_cards_image_opacity']),
      statCardActiveImageOpacity: _parseOpacity(json['stat_card_active_image_opacity']),
      statCardCompletedImageOpacity: _parseOpacity(json['stat_card_completed_image_opacity']),
      statCardRejectedImageOpacity: _parseOpacity(json['stat_card_rejected_image_opacity']),
      statCardScheduledImageOpacity: _parseOpacity(json['stat_card_scheduled_image_opacity']),
      showTopGarland: showTopGarland,
      garlandPosition: garlandPos,
      showGarlandTop: showTop,
      showGarlandBottom: showBottom,
      customGarlandUrl: _sanitizeUrl(json['custom_garland_url']),
      particleEffect: json['particle_effect']?.toString() ?? 'NONE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logo_badge_url': logoBadgeUrl,
      'nav_center_icon_url': navCenterIconUrl,
      'banner_image_url': bannerImageUrl,
      'stat_cards_bg_image_url': statCardsBgImageUrl,
      'stat_card_active_bg_image_url': statCardActiveBgImageUrl,
      'stat_card_completed_bg_image_url': statCardCompletedBgImageUrl,
      'stat_card_rejected_bg_image_url': statCardRejectedBgImageUrl,
      'stat_card_scheduled_bg_image_url': statCardScheduledBgImageUrl,
      'stat_cards_image_opacity': statCardsImageOpacity != null ? (statCardsImageOpacity! * 100).round() : null,
      'stat_card_active_image_opacity': statCardActiveImageOpacity != null ? (statCardActiveImageOpacity! * 100).round() : null,
      'stat_card_completed_image_opacity': statCardCompletedImageOpacity != null ? (statCardCompletedImageOpacity! * 100).round() : null,
      'stat_card_rejected_image_opacity': statCardRejectedImageOpacity != null ? (statCardRejectedImageOpacity! * 100).round() : null,
      'stat_card_scheduled_image_opacity': statCardScheduledImageOpacity != null ? (statCardScheduledImageOpacity! * 100).round() : null,
      'show_top_garland': showTopGarland,
      'garland_position': garlandPosition,
      'show_garland_top': showGarlandTop,
      'show_garland_bottom': showGarlandBottom,
      'custom_garland_url': customGarlandUrl,
      'particle_effect': particleEffect,
    };
  }
}

class SeasonalCopy {
  final String? greetingPrefix;
  final String? promoBannerTitle;
  final String? promoBannerSubtitle;
  final String? promoBannerCtaText;
  final String promoBannerActionType; // REQUEST_JOB, SEARCH_TAG, DEEP_LINK
  final String? promoBannerActionValue;

  const SeasonalCopy({
    this.greetingPrefix,
    this.promoBannerTitle,
    this.promoBannerSubtitle,
    this.promoBannerCtaText,
    this.promoBannerActionType = 'REQUEST_JOB',
    this.promoBannerActionValue,
  });

  factory SeasonalCopy.fromJson(Map<String, dynamic> json) {
    return SeasonalCopy(
      greetingPrefix: json['greeting_prefix']?.toString(),
      promoBannerTitle: json['promo_banner_title']?.toString(),
      promoBannerSubtitle: json['promo_banner_subtitle']?.toString(),
      promoBannerCtaText: json['promo_banner_cta_text']?.toString(),
      promoBannerActionType: json['promo_banner_action_type']?.toString() ?? 'REQUEST_JOB',
      promoBannerActionValue: json['promo_banner_action_value']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'greeting_prefix': greetingPrefix,
      'promo_banner_title': promoBannerTitle,
      'promo_banner_subtitle': promoBannerSubtitle,
      'promo_banner_cta_text': promoBannerCtaText,
      'promo_banner_action_type': promoBannerActionType,
      'promo_banner_action_value': promoBannerActionValue,
    };
  }
}

class SeasonalFeaturedTag {
  final int id;
  final String name;

  const SeasonalFeaturedTag({
    required this.id,
    required this.name,
  });

  factory SeasonalFeaturedTag.fromJson(Map<String, dynamic> json) {
    return SeasonalFeaturedTag(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class SeasonalCampaignModel {
  final int id;
  final String name;
  final String seasonType;
  final SeasonalColors colors;
  final SeasonalVisuals visuals;
  final SeasonalCopy copy;
  final List<SeasonalFeaturedTag> featuredTags;

  const SeasonalCampaignModel({
    required this.id,
    required this.name,
    required this.seasonType,
    required this.colors,
    required this.visuals,
    required this.copy,
    this.featuredTags = const [],
  });

  factory SeasonalCampaignModel.fromJson(Map<String, dynamic> json) {
    final rawTags = json['featured_tags'];
    List<SeasonalFeaturedTag> tags = [];
    if (rawTags is List) {
      tags = rawTags.map((t) => SeasonalFeaturedTag.fromJson(t as Map<String, dynamic>)).toList();
    }

    return SeasonalCampaignModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      seasonType: json['season_type']?.toString() ?? 'CUSTOM',
      colors: SeasonalColors.fromJson(
        json['colors'] is Map<String, dynamic> ? json['colors'] : {},
      ),
      visuals: SeasonalVisuals.fromJson(
        json['visuals'] is Map<String, dynamic> ? json['visuals'] : {},
      ),
      copy: SeasonalCopy.fromJson(
        json['copy'] is Map<String, dynamic> ? json['copy'] : {},
      ),
      featuredTags: tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'season_type': seasonType,
      'colors': colors.toJson(),
      'visuals': visuals.toJson(),
      'copy': copy.toJson(),
      'featured_tags': featuredTags.map((t) => t.toJson()).toList(),
    };
  }
}
