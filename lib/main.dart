import 'dart:async';
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
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_event.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/pages/login_page.dart';
import 'package:clanship_mobile_tradesman/features/requests/presentation/bloc/requests_bloc.dart';
import 'package:clanship_mobile_tradesman/features/home/presentation/bloc/home_bloc.dart';
import 'package:clanship_mobile_tradesman/core/network/session_service.dart';

import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';

/// Clave global de navegación para poder navegar desde fuera del widget tree
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AntiGravityApp extends StatefulWidget {
  const AntiGravityApp({super.key});

  @override
  State<AntiGravityApp> createState() => _AntiGravityAppState();
}

class _AntiGravityAppState extends State<AntiGravityApp> {
  StreamSubscription<String>? _sessionSub;

  @override
  void dispose() {
    _sessionSub?.cancel();
    super.dispose();
  }

  void _listenSessionInvalidation(BuildContext context) {
    _sessionSub?.cancel();
    _sessionSub = SessionService.instance.onSessionInvalidated.listen((reason) {
      // Forzar logout en el AuthBloc
      if (context.mounted) {
        context.read<AuthBloc>().add(LogoutRequested());
      }

      // Navegar a LoginPage limpiando toda la pila de navegación
      final navigator = navigatorKey.currentState;
      if (navigator != null) {
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );

        // Mostrar mensaje al usuario
        ScaffoldMessenger.of(navigator.context).showSnackBar(
          SnackBar(
            content: Text(reason),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<SplashBloc>()),
        BlocProvider(create: (_) => di.sl<NavigationBloc>()),
        BlocProvider(create: (_) => di.sl<ThemeBloc>()..add(LoadTheme())),
        BlocProvider(create: (_) => di.sl<LanguageBloc>()..add(LoadLanguage())),
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<RequestsBloc>()),
        BlocProvider(create: (_) => di.sl<HomeBloc>()),
      ],
      child: Builder(
        builder: (context) {
          _listenSessionInvalidation(context);

          return BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              return BlocBuilder<LanguageBloc, LanguageState>(
                builder: (context, langState) {
                  return MaterialApp(
                    title: 'Anti Gravity Tradesman',
                    navigatorKey: navigatorKey,
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
