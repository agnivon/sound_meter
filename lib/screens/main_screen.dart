import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/sound_meter/sound_meter_bloc.dart';
import '../blocs/sound_meter/sound_meter_event.dart';
import '../blocs/sound_meter/sound_meter_state.dart';
import '../widgets/db_legend_dialog.dart';
import '../widgets/db_meter.dart';
import '../widgets/charts.dart';

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
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('Real-Time Noise Meter'),
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
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
                            color: const Color(0xFFE85A3F),
                            onPressed: () => setState(
                              () => _activeChart = (_activeChart + 1) % 3,
                            ),
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
                                    ? Colors.grey.shade800
                                    : const Color(
                                        0xFFE85A3F,
                                      ).withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: state.isPaused
                                      ? Colors.grey
                                      : const Color(0xFFE85A3F),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                state.isPaused
                                    ? Icons.play_arrow_rounded
                                    : Icons.pause_rounded,
                                color: state.isPaused
                                    ? Colors.white
                                    : const Color(0xFFE85A3F),
                                size: 48,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            color: Colors.grey,
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

              return const CircularProgressIndicator(color: Colors.redAccent);
            },
          ),
        ),
      ),
    );
  }
}
