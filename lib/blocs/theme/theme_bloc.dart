import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc(ThemeMode initialMode) : super(ThemeState(initialMode)) {
    on<ToggleTheme>((event, emit) {
      if (state.themeMode == ThemeMode.dark) {
        emit(ThemeState(ThemeMode.light));
      } else {
        emit(ThemeState(ThemeMode.dark));
      }
    });

    on<SetThemeMode>((event, emit) {
      emit(ThemeState(event.themeMode));
    });
  }
}
