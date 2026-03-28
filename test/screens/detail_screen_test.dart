import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sound_meter/screens/detail_screen.dart';
import 'package:sound_meter/models/recording_model.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocking the flutter_soloud platform channel to prevent MissingPluginException
  // Note: flutter_soloud might use FFI depending on platform, but we set up a 
  // basic channel mock just in case it uses standard MethodChannels for init.
  const MethodChannel channel = MethodChannel('flutter_soloud');
  
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return null;
    });
  });

  Widget createWidgetUnderTest(SoundRecording recording) {
    return MaterialApp(
      home: DetailScreen(recording: recording),
    );
  }

  group('DetailScreen Tests', () {
    final testRecording = SoundRecording(
      id: '123',
      name: 'Concert Recording',
      timestamp: DateTime(2025, 1, 1, 20, 0),
      minDb: 70,
      maxDb: 110,
      avgDb: 95,
      duration: const Duration(minutes: 5, seconds: 30),
      dbHistory: List.generate(100, (index) => 90.0),
      filePath: '/dev/null/concert.wav',
    );

    testWidgets('displays recording details correctly', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createWidgetUnderTest(testRecording));
        await tester.pump();
      });

      // Check title and timestamps
      expect(find.text('Concert Recording'), findsOneWidget);
      expect(find.text('Recording Details'), findsOneWidget);

      // Check stats card values
      expect(find.text('70.0 dB'), findsOneWidget); // Min
      expect(find.text('95.0 dB'), findsOneWidget); // Avg
      expect(find.text('110.0 dB'), findsOneWidget); // Max

      // Check charts section
      expect(find.text('Noise Level History'), findsOneWidget);
      
      // Check play button
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
    });
  });
}
