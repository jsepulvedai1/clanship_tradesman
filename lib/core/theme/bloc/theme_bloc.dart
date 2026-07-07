import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Eventos
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
  @override
  List<Object> get props => [];
}

class ThemeChanged extends ThemeEvent {
  final ThemeMode themeMode;
  const ThemeChanged(this.themeMode);
  @override
  List<Object> get props => [themeMode];
}

class LoadTheme extends ThemeEvent {}

// Estados
class ThemeState extends Equatable {
  final ThemeMode themeMode;
  const ThemeState(this.themeMode);
  @override
  List<Object> get props => [themeMode];
}

// BLoC
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'theme_mode';

  ThemeBloc() : super(const ThemeState(ThemeMode.dark)) {
    on<ThemeChanged>(_onThemeChanged);
    on<LoadTheme>(_onLoadTheme);
  }

  Future<void> _onThemeChanged(ThemeChanged event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, event.themeMode.index);
    emit(ThemeState(event.themeMode));
  }

  Future<void> _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);
    
    if (themeIndex != null) {
      emit(ThemeState(ThemeMode.values[themeIndex]));
    } else {
      emit(const ThemeState(ThemeMode.dark)); // Default
    }
  }
}
