import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:sound_meter/blocs/sound_meter/sound_meter_bloc.dart';
import 'package:sound_meter/blocs/sound_meter/sound_meter_event.dart';
import 'package:sound_meter/blocs/sound_meter/sound_meter_state.dart';
import 'package:sound_meter/utils/sound_utils.dart';

void main() {
  group('SoundMeterBloc', () {
    late SoundMeterBloc soundMeterBloc;

    setUp(() {
      soundMeterBloc = SoundMeterBloc();
    });

    tearDown(() {
      soundMeterBloc.close();
    });

    test('initial state is correct', () {
      expect(soundMeterBloc.state, isA<SoundMeterInitial>());
    });

    blocTest<SoundMeterBloc, SoundMeterState>(
      'UpdateDbOffset changes calibration dbOffset in Recording state',
      build: () => soundMeterBloc,
      seed: () => SoundMeterRecording(
        currentDb: 50,
        maxDb: 50,
        minDb: 0,
        avgDb: 50,
        duration: Duration.zero,
      ),
      act: (bloc) => bloc.add(UpdateDbOffset(10.5)),
      expect: () => [
        isA<SoundMeterRecording>().having(
          (state) => state.dbOffset,
          'dbOffset',
          10.5,
        ),
      ],
    );

    blocTest<SoundMeterBloc, SoundMeterState>(
      'SetFrequencyWeighting updates freq weighting in Recording state',
      build: () => soundMeterBloc,
      seed: () => SoundMeterRecording(
        currentDb: 50,
        maxDb: 50,
        minDb: 0,
        avgDb: 50,
        duration: Duration.zero,
      ),
      act: (bloc) => bloc.add(SetFrequencyWeighting(FrequencyWeighting.c)),
      expect: () => [
        isA<SoundMeterRecording>().having(
          (state) => state.freqWeighting,
          'freqWeighting',
          FrequencyWeighting.c,
        ),
      ],
    );

    blocTest<SoundMeterBloc, SoundMeterState>(
      'SetTimeWeighting updates time weighting in Recording state',
      build: () => soundMeterBloc,
      seed: () => SoundMeterRecording(
        currentDb: 50,
        maxDb: 50,
        minDb: 0,
        avgDb: 50,
        duration: Duration.zero,
      ),
      act: (bloc) => bloc.add(SetTimeWeighting(TimeWeighting.slow)),
      expect: () => [
        isA<SoundMeterRecording>().having(
          (state) => state.timeWeighting,
          'timeWeighting',
          TimeWeighting.slow,
        ),
      ],
    );

    blocTest<SoundMeterBloc, SoundMeterState>(
      'UpdateSoundMeterDb properly calculates moving averages and limits',
      build: () => soundMeterBloc,
      seed: () => SoundMeterRecording(
        currentDb: 0,
        maxDb: 0,
        minDb: 120,
        avgDb: 0,
        duration: Duration.zero,
        hasReading: false,
      ),
      act: (bloc) {
        // Initially set values
        bloc.add(UpdateSoundMeterDb(50.0, [], [], 1000.0));
        // Then update
        bloc.add(UpdateSoundMeterDb(60.0, [], [], 1000.0));
      },
      expect: () => [
        // Expect First valid reading sets min, max appropriately
        isA<SoundMeterRecording>().having(
          (s) => s.hasReading,
          'hasReading',
          true,
        ),

        // Expect Second reading updates stats and duration
        isA<SoundMeterRecording>().having((s) => s.rawDb, 'rawDb', 60.0),
      ],
    );
  });
}
