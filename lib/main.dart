import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'blocs/history/history_bloc.dart';

import 'blocs/theme/theme_bloc.dart';
import 'blocs/theme/theme_state.dart';
import 'blocs/sound_meter/sound_meter_bloc.dart';
import 'screens/main_screen.dart';

import 'package:flutter_recorder/flutter_recorder.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final directory = await getApplicationDocumentsDirectory();
  final storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(directory.path),
  );
  HydratedBloc.storage = storage;

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
    final Brightness systemBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final ThemeMode initialMode = systemBrightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => HistoryBloc()),
        BlocProvider(
          create: (context) => SoundMeterBloc(
            historyBloc: context.read<HistoryBloc>(),
          ),
        ),
        BlocProvider(create: (context) => ThemeBloc(initialMode)),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'Sound Meter',
            debugShowCheckedModeBanner: false,
            themeMode: themeState.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFE85A3F),
                brightness: Brightness.light,
                primary: const Color(0xFFE85A3F),
                surface: const Color(0xFFFAFAFA),
                onSurface: const Color(0xFF2C2C2C),
                secondary: const Color(0xFFF18A76),
              ),
              scaffoldBackgroundColor: const Color(0xFFF5F5F5),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFFFFFFFF),
                foregroundColor: Color(0xFF2C2C2C),
                elevation: 0,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFE85A3F),
                brightness: Brightness.dark,
                primary: const Color(0xFFE85A3F),
                surface: const Color(0xFF1A1A1A),
                onSurface: const Color(0xFFE0E0E0),
                secondary: const Color(0xFFF18A76),
                shadow: const Color(0x66000000),
              ),
              scaffoldBackgroundColor: const Color(0xFF0F0F0F),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1A1A1A),
                foregroundColor: Color(0xFFE0E0E0),
                elevation: 0,
              ),
            ),
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}

