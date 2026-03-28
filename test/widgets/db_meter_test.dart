import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sound_meter/widgets/db_meter.dart';

void main() {
  Widget createWidgetUnderTest({
    double currentDb = 50.0,
    double minDb = 30.0,
    double maxDb = 80.0,
    double avgDb = 55.0,
    Duration duration = const Duration(minutes: 1, seconds: 30),
    bool hasReading = true,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: DbMeter(
          currentDb: currentDb,
          minDb: minDb,
          maxDb: maxDb,
          avgDb: avgDb,
          duration: duration,
          hasReading: hasReading,
          description: 'Quiet Office',
          unit: 'dB',
        ),
      ),
    );
  }

  group('DbMeter Widget Tests', () {
    testWidgets('displays correctly with readings', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Check text existence
      expect(find.text('50.0'), findsOneWidget); // current
      expect(find.text('30'), findsOneWidget); // min
      expect(find.text('80'), findsOneWidget); // max
      expect(find.text('55.0'), findsOneWidget); // avg
      expect(find.text('Quiet Office'), findsOneWidget);
      expect(find.text('dB'), findsOneWidget);
    });

    testWidgets('displays placeholders when no reading', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(hasReading: false));

      expect(find.text('-.-'), findsOneWidget); // current placeholder
      expect(find.text('-'), findsNWidgets(2)); // min and max placeholder
      expect(find.text('--'), findsNWidgets(2)); // avg placeholder and something else matching
    });

    testWidgets('formats duration correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(duration: const Duration(minutes: 5, seconds: 9)));

      expect(find.text('05:09'), findsOneWidget);
    });
  });
}
