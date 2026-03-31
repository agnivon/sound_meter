import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sound_meter/widgets/charts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  group('Chart Widgets Tests', () {
    testWidgets('TimelineChartWidget renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TimelineChartWidget(history: [40, 50, 60]),
          ),
        ),
      );

      expect(find.byType(SfCartesianChart), findsOneWidget);
    });

    testWidgets('WaveChartWidget renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WaveChartWidget(waveData: [0.1, -0.1, 0.2]),
          ),
        ),
      );

      expect(find.byType(SfCartesianChart), findsOneWidget);
    });

    testWidgets('FftChartWidget renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FftChartWidget(
              fftData: [0.5, 0.8, 0.3],
              peakFrequency: 1000.0,
            ),
          ),
        ),
      );

      expect(find.byType(SfCartesianChart), findsOneWidget);
      expect(find.text('1000.0 Hz'), findsOneWidget);
    });
  });
}
