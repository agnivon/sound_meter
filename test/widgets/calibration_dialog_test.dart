import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sound_meter/blocs/sound_meter/sound_meter_bloc.dart';
import 'package:sound_meter/blocs/sound_meter/sound_meter_event.dart';
import 'package:sound_meter/blocs/sound_meter/sound_meter_state.dart';
import 'package:sound_meter/widgets/calibration_dialog.dart';

class MockSoundMeterBloc extends MockBloc<SoundMeterEvent, SoundMeterState>
    implements SoundMeterBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(UpdateDbOffset(0));
  });

  Widget createWidgetUnderTest(MockSoundMeterBloc mockBloc) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<SoundMeterBloc>.value(
          value: mockBloc,
          child: const CalibrationDialog(),
        ),
      ),
    );
  }

  group('CalibrationDialog Tests', () {
    late MockSoundMeterBloc mockSoundMeterBloc;

    setUp(() {
      mockSoundMeterBloc = MockSoundMeterBloc();
    });

    testWidgets('displays correct initial offset and handles tap events', (
      WidgetTester tester,
    ) async {
      when(() => mockSoundMeterBloc.state).thenReturn(
        SoundMeterRecording(
          currentDb: 50,
          rawDb: 48,
          dbOffset: 2.0,
          maxDb: 50,
          minDb: 0,
          avgDb: 50,
          duration: Duration.zero,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(mockSoundMeterBloc));

      expect(find.text('Calibration'), findsOneWidget);
      expect(find.text('48.0+2=50.0dB'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      verify(
        () => mockSoundMeterBloc.add(any(that: isA<UpdateDbOffset>())),
      ).called(1);
    });

    testWidgets('reset button resets offset', (WidgetTester tester) async {
      when(() => mockSoundMeterBloc.state).thenReturn(
        SoundMeterRecording(
          currentDb: 50,
          rawDb: 45,
          dbOffset: 5.0,
          maxDb: 50,
          minDb: 0,
          avgDb: 50,
          duration: Duration.zero,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(mockSoundMeterBloc));

      await tester.tap(find.text('RESET'));
      await tester.pump();

      verify(
        () => mockSoundMeterBloc.add(any(that: isA<UpdateDbOffset>())),
      ).called(1);
    });
  });
}
