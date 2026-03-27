import 'dart:convert';

class SoundRecording {
  final String id;
  final String name;
  final DateTime timestamp;
  final double minDb;
  final double maxDb;
  final double avgDb;
  final Duration duration;
  final List<double> dbHistory;
  final String filePath;

  SoundRecording({
    required this.id,
    required this.name,
    required this.timestamp,
    required this.minDb,
    required this.maxDb,
    required this.avgDb,
    required this.duration,
    required this.dbHistory,
    required this.filePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'timestamp': timestamp.toIso8601String(),
      'minDb': minDb,
      'maxDb': maxDb,
      'avgDb': avgDb,
      'durationMs': duration.inMilliseconds,
      'dbHistory': dbHistory,
      'filePath': filePath,
    };
  }

  factory SoundRecording.fromMap(Map<String, dynamic> map) {
    return SoundRecording(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      minDb: (map['minDb'] ?? 0.0).toDouble(),
      maxDb: (map['maxDb'] ?? 0.0).toDouble(),
      avgDb: (map['avgDb'] ?? 0.0).toDouble(),
      duration: Duration(milliseconds: map['durationMs'] ?? 0),
      dbHistory: List<double>.from(map['dbHistory'] ?? []),
      filePath: map['filePath'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory SoundRecording.fromJson(String source) => SoundRecording.fromMap(json.decode(source));

  SoundRecording copyWith({
    String? name,
    String? filePath,
  }) {
    return SoundRecording(
      id: id,
      name: name ?? this.name,
      timestamp: timestamp,
      minDb: minDb,
      maxDb: maxDb,
      avgDb: avgDb,
      duration: duration,
      dbHistory: dbHistory,
      filePath: filePath ?? this.filePath,
    );
  }
}
