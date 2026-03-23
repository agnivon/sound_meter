import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/sound_meter/sound_meter_bloc.dart';
import 'screens/main_screen.dart';

import 'package:flutter_recorder/flutter_recorder.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final status = await Permission.microphone.request();
  if (status == PermissionStatus.granted) {
    if (!Recorder.instance.isDeviceInitialized()) {
      try {
        await Recorder.instance.init(format: PCMFormat.f32le);
      } catch (e) {
        debugPrint('Failed to initialize recorder natively: $e');
      }
    }
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SoundMeterBloc(),
      child: MaterialApp(
        title: 'Sound Meter',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
          useMaterial3: true,
        ),
        home: const MainScreen(),
      ),
    );
  }
}

