import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:sound_meter/blocs/theme/theme_bloc.dart';
import 'package:sound_meter/blocs/theme/theme_event.dart';
import 'package:sound_meter/blocs/theme/theme_state.dart';

void main() {
  group('ThemeBloc', () {
    late ThemeBloc themeBloc;

    setUp(() {
      themeBloc = ThemeBloc(ThemeMode.dark); // Initial state
    });

    tearDown(() {
      themeBloc.close();
    });

    test('initial state is correct', () {
      expect(themeBloc.state.themeMode, ThemeMode.dark);
    });

    blocTest<ThemeBloc, ThemeState>(
      'emits [ThemeMode.light] when ToggleTheme is added and current is dark',
      build: () => themeBloc,
      act: (bloc) => bloc.add(ToggleTheme()),
      expect: () => [
        isA<ThemeState>().having(
          (state) => state.themeMode,
          'themeMode',
          ThemeMode.light,
        ),
      ],
    );

    blocTest<ThemeBloc, ThemeState>(
      'emits [ThemeMode.dark] when ToggleTheme is added and current is light',
      build: () => ThemeBloc(ThemeMode.light),
      act: (bloc) => bloc.add(ToggleTheme()),
      expect: () => [
        isA<ThemeState>().having(
          (state) => state.themeMode,
          'themeMode',
          ThemeMode.dark,
        ),
      ],
    );

    blocTest<ThemeBloc, ThemeState>(
      'emits system theme when SetThemeMode is added',
      build: () => themeBloc,
      act: (bloc) => bloc.add(SetThemeMode(ThemeMode.system)),
      expect: () => [
        isA<ThemeState>().having(
          (state) => state.themeMode,
          'themeMode',
          ThemeMode.system,
        ),
      ],
    );
  });
}
