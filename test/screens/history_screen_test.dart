import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sound_meter/blocs/history/history_bloc.dart';
import 'package:sound_meter/blocs/history/history_event.dart';
import 'package:sound_meter/blocs/history/history_state.dart';
import 'package:sound_meter/screens/history_screen.dart';
import 'package:sound_meter/models/recording_model.dart';

class MockHistoryBloc extends MockBloc<HistoryEvent, HistoryState>
    implements HistoryBloc {}

void main() {
  Widget createWidgetUnderTest(MockHistoryBloc mockBloc) {
    return MaterialApp(
      home: BlocProvider<HistoryBloc>.value(
        value: mockBloc,
        child: const HistoryScreen(),
      ),
    );
  }

  group('HistoryScreen Tests', () {
    late MockHistoryBloc mockHistoryBloc;
    final testRecording = SoundRecording(
      id: '123',
      name: 'Office Recording',
      timestamp: DateTime(2025, 1, 1, 10, 30),
      minDb: 30,
      maxDb: 80,
      avgDb: 55,
      duration: const Duration(minutes: 2),
      dbHistory: [40, 50, 60],
      filePath: '/dev/null/test.wav',
    );

    setUp(() {
      mockHistoryBloc = MockHistoryBloc();
    });

    testWidgets('displays empty state when no recordings', (
      WidgetTester tester,
    ) async {
      when(
        () => mockHistoryBloc.state,
      ).thenReturn(HistoryState(recordings: []));

      await tester.pumpWidget(createWidgetUnderTest(mockHistoryBloc));

      expect(find.text('No saved recordings yet'), findsOneWidget);
      expect(find.byIcon(Icons.history_outlined), findsOneWidget);
    });

    testWidgets('displays list of recordings when available', (
      WidgetTester tester,
    ) async {
      when(
        () => mockHistoryBloc.state,
      ).thenReturn(HistoryState(recordings: [testRecording]));

      await tester.pumpWidget(createWidgetUnderTest(mockHistoryBloc));

      expect(find.text('Office Recording'), findsOneWidget);
      expect(find.text('55.0 dB'), findsOneWidget);
      expect(find.textContaining('Jan 01, 2025'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('menu actions open rename dialog', (WidgetTester tester) async {
      when(
        () => mockHistoryBloc.state,
      ).thenReturn(HistoryState(recordings: [testRecording]));

      await tester.pumpWidget(createWidgetUnderTest(mockHistoryBloc));

      // Tap popup menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Tap Rename
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();

      // Expect Rename Dialog
      expect(find.text('Rename Recording'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });
  });
}
