import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/sound_meter/sound_meter_bloc.dart';
import '../blocs/sound_meter/sound_meter_event.dart';
import '../blocs/sound_meter/sound_meter_state.dart';

void showCalibrationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return const CalibrationDialog();
    },
  );
}

class CalibrationDialog extends StatefulWidget {
  const CalibrationDialog({super.key});

  @override
  State<CalibrationDialog> createState() => _CalibrationDialogState();
}

class _CalibrationDialogState extends State<CalibrationDialog> {
  double _currentOffset = 0.0;

  @override
  void initState() {
    super.initState();
    final state = context.read<SoundMeterBloc>().state;
    if (state is SoundMeterRecording) {
      _currentOffset = state.dbOffset;
    }
  }

  void _updateOffset(double delta) {
    setState(() {
      _currentOffset += delta;
    });
    context.read<SoundMeterBloc>().add(UpdateDbOffset(_currentOffset));
  }

  void _resetOffset() {
    setState(() {
      _currentOffset = 0.0;
    });
    context.read<SoundMeterBloc>().add(UpdateDbOffset(0.0));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onSurface = colorScheme.onSurface;

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: BlocBuilder<SoundMeterBloc, SoundMeterState>(
        builder: (context, state) {
          double rawDb = 0.0;
          double calibratedDb = 0.0;
          if (state is SoundMeterRecording) {
            rawDb = state.rawDb;
            calibratedDb = state.currentDb;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Calibration',
                  style: TextStyle(
                    color: onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Our app measures environmental sound levels in dB, reflecting human ear sensitivity. However, your device's microphones are not designed for precise measurements, and the maximum value depends on your microphone's capabilities.\n\nFor serious measurements, custom calibration is recommended. Use a professional sound meter or a calibrated device, and adjust the app's readings to match.",
                  style: TextStyle(
                    color: onSurface.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        '${rawDb.toStringAsFixed(1)}${_currentOffset >= 0 ? '+' : ''}${_currentOffset.toInt()}=${calibratedDb.toStringAsFixed(1)}dB',
                        style: TextStyle(
                          color: onSurface,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      children: [
                        _buildAdjustButton(Icons.add, () => _updateOffset(1.0)),
                        const SizedBox(height: 8),
                        _buildAdjustButton(
                          Icons.remove,
                          () => _updateOffset(-1.0),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // const Divider(height: 1),
                // const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _resetOffset,
                        child: Text(
                          'RESET',
                          style: TextStyle(
                            color: onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                      child: VerticalDivider(width: 1),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'DONE',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdjustButton(IconData icon, VoidCallback onPressed) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 50,
          height: 40,
          alignment: Alignment.center,
          child: Icon(icon, color: colorScheme.onSurface, size: 20),
        ),
      ),
    );
  }
}
