import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sound_meter/blocs/sound_meter/sound_meter_bloc.dart';
import 'package:sound_meter/blocs/sound_meter/sound_meter_event.dart';
import 'package:sound_meter/blocs/sound_meter/sound_meter_state.dart';
import 'package:sound_meter/blocs/theme/theme_bloc.dart';
import 'package:sound_meter/blocs/theme/theme_event.dart';
import 'package:sound_meter/blocs/theme/theme_state.dart';
import 'package:sound_meter/blocs/history/history_bloc.dart';
import 'package:sound_meter/blocs/history/history_event.dart';
import 'package:sound_meter/blocs/history/history_state.dart';
import 'package:sound_meter/screens/main_screen.dart';
import 'package:sound_meter/widgets/db_meter.dart';
import 'package:sound_meter/widgets/charts.dart';
import 'package:sound_meter/utils/sound_utils.dart';

class MockSoundMeterBloc extends MockBloc<SoundMeterEvent, SoundMeterState> implements SoundMeterBloc {}
class MockThemeBloc extends MockBloc<ThemeEvent, ThemeState> implements ThemeBloc {}
class MockHistoryBloc extends MockBloc<HistoryEvent, HistoryState> implements HistoryBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(InitializeSoundMeter());
    registerFallbackValue(ToggleTheme());
  });

  Widget createWidgetUnderTest({
    required MockSoundMeterBloc soundMeterBloc,
    required MockThemeBloc themeBloc,
    required MockHistoryBloc historyBloc,
  }) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<SoundMeterBloc>.value(value: soundMeterBloc),
          BlocProvider<ThemeBloc>.value(value: themeBloc),
          BlocProvider<HistoryBloc>.value(value: historyBloc),
        ],
        child: const MainScreen(),
      ),
    );
  }

  group('MainScreen Tests', () {
    late MockSoundMeterBloc mockSoundMeterBloc;
    late MockThemeBloc mockThemeBloc;
    late MockHistoryBloc mockHistoryBloc;

    setUp(() {
      mockSoundMeterBloc = MockSoundMeterBloc();
      mockThemeBloc = MockThemeBloc();
      mockHistoryBloc = MockHistoryBloc();

      when(() => mockThemeBloc.state).thenReturn(ThemeState(ThemeMode.dark));
    });

    testWidgets('renders loading state when initial', (WidgetTester tester) async {
      when(() => mockSoundMeterBloc.state).thenReturn(SoundMeterInitial());

      await tester.pumpWidget(
        createWidgetUnderTest(
          soundMeterBloc: mockSoundMeterBloc,
          themeBloc: mockThemeBloc,
          historyBloc: mockHistoryBloc,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders recording state with DbMeter and charts', (WidgetTester tester) async {
      when(() => mockSoundMeterBloc.state).thenReturn(
        SoundMeterRecording(
          currentDb: 55,
          maxDb: 80,
          minDb: 30,
          avgDb: 50,
          duration: const Duration(seconds: 10),
          hasReading: true,
          freqWeighting: FrequencyWeighting.a,
          timeWeighting: TimeWeighting.fast,
          dbHistory: [30, 40, 50],
          waveData: [0, 0, 0],
          fftData: [0, 0, 0],
          peakFrequency: 1000,
        ),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          soundMeterBloc: mockSoundMeterBloc,
          themeBloc: mockThemeBloc,
          historyBloc: mockHistoryBloc,
        ),
      );

      expect(find.byType(DbMeter), findsOneWidget);
      expect(find.byType(TimelineChartWidget), findsOneWidget); // Default chart
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget); // Playing state
    });

    testWidgets('renders error state', (WidgetTester tester) async {
      when(() => mockSoundMeterBloc.state).thenReturn(SoundMeterError('Mic Permission Denied'));

      await tester.pumpWidget(
        createWidgetUnderTest(
          soundMeterBloc: mockSoundMeterBloc,
          themeBloc: mockThemeBloc,
          historyBloc: mockHistoryBloc,
        ),
      );

      expect(find.text('Mic Permission Denied'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
