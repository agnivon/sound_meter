import 'package:flutter/material.dart';

import '../utils/sound_utils.dart';

void showDbLegendDialog(BuildContext context, double currentDb) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${currentDb.toStringAsFixed(1)} dB',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Reference Chart',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              ...dbReferences.reversed.map((ref) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        color: ref.color,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${ref.db}dB : ${ref.description}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      );
    },
  );
}

class SegmentedDbGauge extends StatelessWidget {
  final double currentDb;
  final bool hasReading;

  const SegmentedDbGauge({
    super.key,
    required this.currentDb,
    required this.hasReading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: dbReferences.map((ref) {
          bool isHighlighted = hasReading && (currentDb >= ref.db);
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.0),
              height: 16,
              color: isHighlighted ? ref.color : ref.color.withValues(alpha: 0.15),
            ),
          );
        }).toList(),
      ),
    );
  }
}
