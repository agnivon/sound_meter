import 'package:flutter/material.dart';

class DbReference {
  final int db;
  final String description;
  final Color color;

  const DbReference(this.db, this.description, this.color);
}

const List<DbReference> dbReferences = [
  DbReference(10, 'Breathing', Color(0xFF1E88E5)),
  DbReference(20, 'Clock Ticking', Color(0xFF039BE5)),
  DbReference(30, 'Whisper', Color(0xFF00ACC1)),
  DbReference(40, 'Quiet Library', Color(0xFF00897B)),
  DbReference(50, 'Quiet Office', Color(0xFF43A047)),
  DbReference(60, 'Conversation', Color(0xFFFDD835)),
  DbReference(70, 'Restaurant', Color(0xFFFB8C00)),
  DbReference(80, 'Busy Traffic', Color(0xFF6D4C41)),
  DbReference(90, 'Motorcycle', Color(0xFF5D4037)),
  DbReference(100, 'Subway Train', Color(0xFF4E342E)),
  DbReference(110, 'Concerts', Color(0xFF3E2723)),
  DbReference(120, 'Thunder', Color(0xFFE53935)),
  DbReference(130, 'Ambulance', Color(0xFFD32F2F)),
  DbReference(140, 'Gun Shots', Color(0xFFB71C1C)),
];

String getEnvironmentDescription(double db) {
  if (db < 10) return '0dB : Silence';
  for (var i = dbReferences.length - 1; i >= 0; i--) {
    if (db >= dbReferences[i].db) {
      return '${dbReferences[i].db}dB : ${dbReferences[i].description}';
    }
  }
  return '0dB : Silence';
}

void showDbLegendDialog(BuildContext context, double currentDb) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: const Color(0xFF2C2C2C),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Reference Chart',
                style: TextStyle(
                  color: Colors.white70,
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
                        style: const TextStyle(
                          color: Colors.white,
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
