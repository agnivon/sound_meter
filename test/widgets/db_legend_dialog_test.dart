import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sound_meter/widgets/db_legend_dialog.dart';
import 'package:sound_meter/utils/sound_utils.dart';

void main() {
  group('SegmentedDbGauge Tests', () {
    testWidgets('renders segments for all dbReferences', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SegmentedDbGauge(
              currentDb: 50.0,
              hasReading: true,
            ),
          ),
        ),
      );

      // Should find a container for each reference
      expect(find.byType(Container), findsNWidgets(dbReferences.length));
    });

    testWidgets('highlights correct number of segments based on currentDb', (WidgetTester tester) async {
      // 55dB should highlight 10, 20, 30, 40, 50 (5 segments)
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SegmentedDbGauge(
              currentDb: 55.0,
              hasReading: true,
            ),
          ),
        ),
      );

      final containers = tester.widgetList<Container>(find.byType(Container));
      int highlightedCount = 0;
      
      for (var container in containers) {
        final color = container.color!;
        // Check if alpha is high (highlighted) or low (dimmed)
        // Note: colors in dbReferences are opaque, dimmed ones have alpha 0.15
        if (color.a > 0.5) {
          highlightedCount++;
        }
      }

      expect(highlightedCount, 5);
    });
  });

  testWidgets('showDbLegendDialog displays db value and references', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => showDbLegendDialog(context, 65.5),
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('65.5 dB'), findsOneWidget);
    expect(find.text('Reference Chart'), findsOneWidget);
    // Check for at least one reference text
    expect(find.text('60dB : Conversation'), findsOneWidget);
  });
}
