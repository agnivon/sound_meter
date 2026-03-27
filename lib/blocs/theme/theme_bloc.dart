import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState(ThemeMode.system)) {
    on<ToggleTheme>((event, emit) {
      if (state.themeMode == ThemeMode.system) {
        emit(ThemeState(ThemeMode.light));
      } else if (state.themeMode == ThemeMode.light) {
        emit(ThemeState(ThemeMode.dark));
      } else {
        emit(ThemeState(ThemeMode.system));
      }
    });

    on<SetThemeMode>((event, emit) {
      emit(ThemeState(event.themeMode));
    });
  }
}
