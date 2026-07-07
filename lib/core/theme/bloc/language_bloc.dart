import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class LanguageEvent extends Equatable {
  const LanguageEvent();
  @override
  List<Object> get props => [];
}

class LanguageChanged extends LanguageEvent {
  final Locale locale;
  const LanguageChanged(this.locale);
  @override
  List<Object> get props => [locale];
}

class LoadLanguage extends LanguageEvent {}

// States
class LanguageState extends Equatable {
  final Locale locale;
  const LanguageState(this.locale);
  @override
  List<Object> get props => [locale];
}

// BLoC
class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  static const String _localeKey = 'locale_language_code';

  LanguageBloc() : super(const LanguageState(Locale('es'))) {
    on<LanguageChanged>(_onLanguageChanged);
    on<LoadLanguage>(_onLoadLanguage);
  }

  Future<void> _onLanguageChanged(LanguageChanged event, Emitter<LanguageState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, event.locale.languageCode);
    emit(LanguageState(event.locale));
  }

  Future<void> _onLoadLanguage(LoadLanguage event, Emitter<LanguageState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(_localeKey);
    
    if (langCode != null) {
      emit(LanguageState(Locale(langCode)));
    } else {
      emit(const LanguageState(Locale('es'))); // Default to Spanish
    }
  }
}
