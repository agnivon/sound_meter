import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/sound_meter/sound_meter_bloc.dart';
import '../blocs/sound_meter/sound_meter_event.dart';
import '../blocs/sound_meter/sound_meter_state.dart';
import '../utils/sound_utils.dart';

void showWeightingDialog(BuildContext context) {
  showDialog(context: context, builder: (context) => const WeightingDialog());
}

class WeightingDialog extends StatelessWidget {
  const WeightingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SoundMeterBloc, SoundMeterState>(
      builder: (context, state) {
        if (state is! SoundMeterRecording) return const SizedBox.shrink();

        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.tune_outlined),
              SizedBox(width: 12),
              Text('Weighting'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, 'Frequency Weighting (Pitch)'),
                const SizedBox(height: 8),
                ...FrequencyWeighting.values.map(
                  (f) => _buildFrequencyOption(context, f, state.freqWeighting),
                ),
                const SizedBox(height: 24),
                _buildHeader(context, 'Time Weighting (Speed)'),
                const SizedBox(height: 8),
                ...TimeWeighting.values.map(
                  (t) => _buildTimeOption(context, t, state.timeWeighting),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildFrequencyOption(
    BuildContext context,
    FrequencyWeighting weighting,
    FrequencyWeighting current,
  ) {
    final isSelected = weighting == current;
    return InkWell(
      onTap: () {
        context.read<SoundMeterBloc>().add(SetFrequencyWeighting(weighting));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  weighting.label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  weighting.unit,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              weighting.description,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeOption(
    BuildContext context,
    TimeWeighting weighting,
    TimeWeighting current,
  ) {
    final isSelected = weighting == current;
    return InkWell(
      onTap: () {
        context.read<SoundMeterBloc>().add(SetTimeWeighting(weighting));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              weighting.label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              weighting.description,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
