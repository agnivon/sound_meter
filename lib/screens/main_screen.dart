import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/theme/theme_bloc.dart';
import '../blocs/theme/theme_event.dart';
import '../blocs/theme/theme_state.dart';
import '../blocs/sound_meter/sound_meter_bloc.dart';
import '../blocs/sound_meter/sound_meter_event.dart';
import '../blocs/sound_meter/sound_meter_state.dart';
import '../widgets/db_legend_dialog.dart';
import '../widgets/db_meter.dart';
import '../widgets/charts.dart';
import '../widgets/calibration_dialog.dart';
import '../utils/sound_utils.dart';
import 'history_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _activeChart = 0;

  @override
  void initState() {
    super.initState();
    context.read<SoundMeterBloc>().add(InitializeSoundMeter());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sound Meter'),
        actions: [
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              IconData themeIcon = themeState.themeMode == ThemeMode.light
                  ? Icons.light_mode
                  : Icons.dark_mode;
              return IconButton(
                icon: Icon(themeIcon),
                onPressed: () {
                  context.read<ThemeBloc>().add(ToggleTheme());
                },
              );
            },
          ),
          BlocBuilder<SoundMeterBloc, SoundMeterState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {
                  double currentAvg = 0;
                  if (state is SoundMeterRecording) {
                    currentAvg = state.avgDb;
                  }
                  showDbLegendDialog(context, currentAvg);
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: BlocBuilder<SoundMeterBloc, SoundMeterState>(
            builder: (context, state) {
              if (state is SoundMeterError) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          context.read<SoundMeterBloc>().add(
                            InitializeSoundMeter(),
                          );
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is SoundMeterRecording) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DbMeter(
                        currentDb: state.currentDb,
                        minDb: state.minDb,
                        maxDb: state.maxDb,
                        avgDb: state.avgDb,
                        duration: state.duration,
                        hasReading: state.hasReading,
                        description: getEnvironmentDescription(state.avgDb),
                      ),
                      const SizedBox(height: 10),
                      SegmentedDbGauge(
                        currentDb: state.currentDb,
                        hasReading: state.hasReading,
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _activeChart == 0
                            ? TimelineChartWidget(history: state.dbHistory)
                            : _activeChart == 1
                            ? WaveChartWidget(waveData: state.waveData)
                            : FftChartWidget(
                                fftData: state.fftData,
                                peakFrequency: state.peakFrequency,
                              ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(
                              _activeChart == 0
                                  ? Icons.show_chart
                                  : _activeChart == 1
                                  ? Icons.waves
                                  : Icons.graphic_eq,
                            ),
                            color: Theme.of(context).colorScheme.primary,
                            onPressed: () => setState(
                              () => _activeChart = (_activeChart + 1) % 3,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.track_changes),
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                            onPressed: () => showCalibrationDialog(context),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.read<SoundMeterBloc>().add(
                                TogglePauseSoundMeter(),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: state.isPaused
                                    ? Theme.of(context).colorScheme.surfaceContainerHighest
                                    : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: state.isPaused
                                      ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)
                                      : Theme.of(context).colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                state.isPaused
                                    ? Icons.play_arrow_rounded
                                    : Icons.pause_rounded,
                                color: state.isPaused
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context).colorScheme.primary,
                                size: 48,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.save_outlined),
                            color: state.hasReading 
                                ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)
                                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                            onPressed: state.hasReading ? () => _showSaveDialog(context, state) : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                            onPressed: () {
                              context.read<SoundMeterBloc>().add(
                                ResetSoundMeter(),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }

              return CircularProgressIndicator(color: Theme.of(context).colorScheme.primary);
            },
          ),
        ),
      ),
    );
  }

  void _showSaveDialog(BuildContext context, SoundMeterRecording state) {
    final controller = TextEditingController(
      text: 'Recording ${DateFormat('HH:mm').format(DateTime.now())}',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Recording'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter recording name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                context.read<SoundMeterBloc>().add(SaveSoundMeter(name));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Recording saved!')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
