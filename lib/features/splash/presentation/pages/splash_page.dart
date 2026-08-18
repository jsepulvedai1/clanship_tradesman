import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clanship_mobile_tradesman/features/navigation/presentation/pages/main_shell_page.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/pages/login_page.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_event.dart';
import '../bloc/splash_bloc.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:clanship_mobile_tradesman/core/config/environment_config.dart';
import 'package:clanship_mobile_tradesman/core/network/app_version_checker.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkVersion();
  }

  Future<void> _checkVersion() async {
    String currentVersion = '1.0.0';
    try {
      final info = await PackageInfo.fromPlatform();
      if (info.version.isNotEmpty) {
        currentVersion = info.version;
      }
    } catch (_) {}

    final bool isBlocked = await AppVersionChecker.checkVersion(
      context: context,
      appType: 'TRADESMAN',
      currentVersion: currentVersion,
      baseUrl: EnvConfig.instance.baseUrl,
    );

    if (!isBlocked && mounted) {
      context.read<SplashBloc>().add(AppStarted());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is SplashUnauthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        } else if (state is SplashAuthenticated) {
          context.read<AuthBloc>().add(UserAuthenticated(state.user));
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainShellPage()),
          );
        }
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Placeholder con animación o estilo vibrante
              const Hero(
                tag: 'logo',
                child: SymbolIcon(),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SymbolIcon extends StatelessWidget {
  const SymbolIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Image.asset(
          'assets/icon/app_icon.jpg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
