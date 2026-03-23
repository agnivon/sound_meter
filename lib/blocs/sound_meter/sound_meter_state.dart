abstract class SoundMeterState {}

class SoundMeterInitial extends SoundMeterState {}

class SoundMeterRecording extends SoundMeterState {
  final double currentDb;
  final double maxDb;
  final double minDb;
  final double avgDb;
  final Duration duration;
  final bool isPaused;
  final bool hasReading;

  SoundMeterRecording({
    required this.currentDb,
    required this.maxDb,
    required this.minDb,
    required this.avgDb,
    required this.duration,
    this.isPaused = false,
    this.hasReading = false,
  });

  SoundMeterRecording copyWith({
    double? currentDb,
    double? maxDb,
    double? minDb,
    double? avgDb,
    Duration? duration,
    bool? isPaused,
    bool? hasReading,
  }) {
    return SoundMeterRecording(
      currentDb: currentDb ?? this.currentDb,
      maxDb: maxDb ?? this.maxDb,
      minDb: minDb ?? this.minDb,
      avgDb: avgDb ?? this.avgDb,
      duration: duration ?? this.duration,
      isPaused: isPaused ?? this.isPaused,
      hasReading: hasReading ?? this.hasReading,
    );
  }
}

class SoundMeterError extends SoundMeterState {
  final String message;

  SoundMeterError(this.message);
}
