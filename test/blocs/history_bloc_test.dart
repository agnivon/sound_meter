import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sound_meter/blocs/history/history_bloc.dart';
import 'package:sound_meter/blocs/history/history_event.dart';
import 'package:sound_meter/blocs/history/history_state.dart';
import 'package:sound_meter/models/recording_model.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  late Storage storage;

  setUp(() {
    storage = MockStorage();
    when(() => storage.read(any())).thenReturn(<String, dynamic>{});
    when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
    HydratedBloc.storage = storage;
  });

  group('HistoryBloc', () {
    late HistoryBloc historyBloc;
    final testRecording = SoundRecording(
      id: 'test_id',
      name: 'Test File',
      timestamp: DateTime(2025, 1, 1),
      minDb: 30,
      maxDb: 80,
      avgDb: 50,
      duration: const Duration(seconds: 10),
      dbHistory: [50, 60, 70],
      filePath: '/dev/null/test.wav',
    );

    setUp(() {
      historyBloc = HistoryBloc();
    });

    tearDown(() {
      historyBloc.close();
    });

    test('initial state is correct', () {
      expect(historyBloc.state.recordings, isEmpty);
    });

    blocTest<HistoryBloc, HistoryState>(
      'emits correct state when AddRecording is added',
      build: () => historyBloc,
      act: (bloc) => bloc.add(AddRecording(testRecording)),
      expect: () => [
        isA<HistoryState>().having(
          (state) => state.recordings,
          'recordings',
          contains(testRecording),
        ),
      ],
    );

    blocTest<HistoryBloc, HistoryState>(
      'emits correct state when RenameRecording is added',
      build: () => historyBloc,
      seed: () => HistoryState(recordings: [testRecording]),
      act: (bloc) => bloc.add(RenameRecording('test_id', 'New Name')),
      expect: () => [
        isA<HistoryState>().having(
          (state) => state.recordings.first.name,
          'name',
          'New Name',
        ),
      ],
    );

    // Testing DeleteRecording logic that interacts with File System requires more mocking 
    // but the state update part can be tested by passing a dummy file path.
    blocTest<HistoryBloc, HistoryState>(
      'emits correct state when DeleteRecording is added',
      build: () => historyBloc,
      seed: () => HistoryState(recordings: [testRecording]),
      act: (bloc) => bloc.add(DeleteRecording('test_id')),
      expect: () => [
        isA<HistoryState>().having(
          (state) => state.recordings,
          'recordings',
          isEmpty,
        ),
      ],
    );
  });
}
