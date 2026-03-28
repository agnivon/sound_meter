import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sound_meter/blocs/sound_meter/sound_meter_bloc.dart';
import 'package:sound_meter/blocs/sound_meter/sound_meter_event.dart';
import 'package:sound_meter/blocs/sound_meter/sound_meter_state.dart';
import 'package:sound_meter/widgets/weighting_dialog.dart';
import 'package:sound_meter/utils/sound_utils.dart';

class MockSoundMeterBloc extends MockBloc<SoundMeterEvent, SoundMeterState> implements SoundMeterBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(SetFrequencyWeighting(FrequencyWeighting.a));
    registerFallbackValue(SetTimeWeighting(TimeWeighting.fast));
  });

  Widget createWidgetUnderTest(MockSoundMeterBloc mockBloc) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<SoundMeterBloc>.value(
          value: mockBloc,
          child: const WeightingDialog(),
        ),
      ),
    );
  }

  group('WeightingDialog Tests', () {
    late MockSoundMeterBloc mockSoundMeterBloc;

    setUp(() {
      mockSoundMeterBloc = MockSoundMeterBloc();
    });

    testWidgets('renders when state is SoundMeterRecording', (WidgetTester tester) async {
      when(() => mockSoundMeterBloc.state).thenReturn(
        SoundMeterRecording(
          currentDb: 50,
          maxDb: 50,
          minDb: 0,
          avgDb: 50,
          duration: Duration.zero,
          freqWeighting: FrequencyWeighting.a,
          timeWeighting: TimeWeighting.fast,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(mockSoundMeterBloc));

      expect(find.text('Weighting'), findsOneWidget);
      expect(find.text('Frequency Weighting (Pitch)'), findsOneWidget);
      expect(find.text('Time Weighting (Speed)'), findsOneWidget);

      expect(find.text('A-Weighting'), findsOneWidget);
      expect(find.text('C-Weighting'), findsOneWidget);
      expect(find.text('Z-Weighting'), findsOneWidget);

      expect(find.text('Fast'), findsOneWidget);
      expect(find.text('Slow'), findsOneWidget);
      expect(find.text('Impulse'), findsOneWidget);
    });

    testWidgets('adds events on tapping options', (WidgetTester tester) async {
      when(() => mockSoundMeterBloc.state).thenReturn(
        SoundMeterRecording(
          currentDb: 50,
          maxDb: 50,
          minDb: 0,
          avgDb: 50,
          duration: Duration.zero,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(mockSoundMeterBloc));

      // Tap on C-Weighting
      await tester.tap(find.text('C-Weighting'));
      await tester.pump();
      verify(() => mockSoundMeterBloc.add(any(that: isA<SetFrequencyWeighting>()))).called(1);

      // Tap on Slow
      await tester.ensureVisible(find.text('Slow'));
      await tester.tap(find.text('Slow'));
      await tester.pump();
      verify(() => mockSoundMeterBloc.add(any(that: isA<SetTimeWeighting>()))).called(1);
    });

    testWidgets('closes on Close button tap', (WidgetTester tester) async {
      when(() => mockSoundMeterBloc.state).thenReturn(
        SoundMeterRecording(
           currentDb: 50,
          maxDb: 50,
          minDb: 0,
          avgDb: 50,
          duration: Duration.zero,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(mockSoundMeterBloc));
      
      expect(find.byType(AlertDialog), findsOneWidget);
      
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
