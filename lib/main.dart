import 'package:flutter/material.dart';
// import 'main_dev.dart' as dev;
import 'main_prod.dart' as dev;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:clanship_mobile_tradesman/core/di/injection.dart' as di;
import 'package:clanship_mobile_tradesman/core/theme/app_theme.dart';
import 'package:clanship_mobile_tradesman/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:clanship_mobile_tradesman/features/splash/presentation/pages/splash_page.dart';
import 'package:clanship_mobile_tradesman/features/navigation/presentation/bloc/navigation_bloc.dart';
import 'package:clanship_mobile_tradesman/core/theme/bloc/theme_bloc.dart';
import 'package:clanship_mobile_tradesman/core/theme/bloc/language_bloc.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_mobile_tradesman/features/requests/presentation/bloc/requests_bloc.dart';

import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';

class AntiGravityApp extends StatelessWidget {
  const AntiGravityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<SplashBloc>()..add(AppStarted())),
        BlocProvider(create: (_) => di.sl<NavigationBloc>()),
        BlocProvider(create: (_) => di.sl<ThemeBloc>()..add(LoadTheme())),
        BlocProvider(create: (_) => di.sl<LanguageBloc>()..add(LoadLanguage())),
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<RequestsBloc>()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LanguageBloc, LanguageState>(
            builder: (context, langState) {
              return MaterialApp(
                title: 'Anti Gravity Tradesman',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: ThemeMode.light, // Locked to light mode for now
                locale: langState.locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: AppLocalizations.supportedLocales,
                home: const SplashPage(),
              );
            },
          );
        },
      ),
    );
  }
}

// Default entry point for Xcode and flutter run without arguments
void main() {
  dev.main();
}
