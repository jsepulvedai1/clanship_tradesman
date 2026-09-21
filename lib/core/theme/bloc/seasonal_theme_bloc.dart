import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:clanship_mobile_tradesman/core/config/environment_config.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';
import 'package:clanship_mobile_tradesman/core/theme/bloc/seasonal_theme_event.dart';
import 'package:clanship_mobile_tradesman/core/theme/bloc/seasonal_theme_state.dart';
import 'package:clanship_mobile_tradesman/core/theme/models/seasonal_campaign_model.dart';
import 'package:clanship_mobile_tradesman/core/theme/services/seasonal_theme_service.dart';

class SeasonalThemeBloc extends Bloc<SeasonalThemeEvent, SeasonalThemeState> {
  final SeasonalThemeService _service;

  SeasonalThemeBloc(this._service) : super(const SeasonalThemeState()) {
    on<LoadSeasonalTheme>(_onLoadSeasonalTheme);
    on<SeasonalThemeUpdated>((event, emit) {
      if (event.campaign != null) {
        _precacheSeasonalImages(event.campaign!);
      }
      emit(state.copyWith(
        campaign: event.campaign,
        clearCampaign: event.campaign == null,
        isLoaded: true,
      ));
    });
  }

  void _precacheSeasonalImages(SeasonalCampaignModel campaign) {
    final urls = [
      campaign.visuals.logoBadgeUrl,
      campaign.visuals.navCenterIconUrl,
      campaign.visuals.bannerImageUrl,
      campaign.visuals.statCardsBgImageUrl,
      campaign.visuals.statCardActiveBgImageUrl,
      campaign.visuals.statCardCompletedBgImageUrl,
      campaign.visuals.statCardRejectedBgImageUrl,
      campaign.visuals.statCardScheduledBgImageUrl,
    ].whereType<String>().where((u) => u.isNotEmpty);

    for (final url in urls) {
      DefaultCacheManager().downloadFile(url).catchError((_) {
        return FileInfo(null as dynamic, FileSource.Online, DateTime.now(), url);
      });
    }
  }

  Future<void> _onLoadSeasonalTheme(
    LoadSeasonalTheme event,
    Emitter<SeasonalThemeState> emit,
  ) async {
    // 1. Cargar caché inmediatamente para mostrar la festividad sin parpadeos (0ms)
    final cached = await _service.getCachedCampaign();
    if (cached != null) {
      AppColors.setSeasonalOverrides(
        primary: cached.colors.primary,
        secondary: cached.colors.secondary,
        accent: cached.colors.accent,
      );
      _precacheSeasonalImages(cached);
      emit(state.copyWith(campaign: cached, isLoaded: true));
    }

    // 2. Sincronizar en segundo plano la configuración fresca desde el backend
    try {
      final baseUrl = event.baseUrl ?? EnvConfig.instance.baseUrl;
      final fresh = await _service.fetchActiveCampaign(baseUrl: baseUrl, appType: 'TRADESMAN');

      if (fresh != null) {
        AppColors.setSeasonalOverrides(
          primary: fresh.colors.primary,
          secondary: fresh.colors.secondary,
          accent: fresh.colors.accent,
        );
        _precacheSeasonalImages(fresh);
      } else {
        AppColors.resetDefaults();
      }

      emit(state.copyWith(
        campaign: fresh,
        clearCampaign: fresh == null,
        isLoaded: true,
      ));
    } catch (_) {
      // Si falla la red, el estado en caché ya emitido prevalece
    }
  }
}
