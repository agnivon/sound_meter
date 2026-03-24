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
  
  final List<double> dbHistory;
  final List<double> waveData;
  final List<double> fftData;
  final double peakFrequency;

  SoundMeterRecording({
    required this.currentDb,
    required this.maxDb,
    required this.minDb,
    required this.avgDb,
    required this.duration,
    this.isPaused = false,
    this.hasReading = false,
    this.dbHistory = const [],
    this.waveData = const [],
    this.fftData = const [],
    this.peakFrequency = 0.0,
  });

  SoundMeterRecording copyWith({
    double? currentDb,
    double? maxDb,
    double? minDb,
    double? avgDb,
    Duration? duration,
    bool? isPaused,
    bool? hasReading,
    List<double>? dbHistory,
    List<double>? waveData,
    List<double>? fftData,
    double? peakFrequency,
  }) {
    return SoundMeterRecording(
      currentDb: currentDb ?? this.currentDb,
      maxDb: maxDb ?? this.maxDb,
      minDb: minDb ?? this.minDb,
      avgDb: avgDb ?? this.avgDb,
      duration: duration ?? this.duration,
      isPaused: isPaused ?? this.isPaused,
      hasReading: hasReading ?? this.hasReading,
      dbHistory: dbHistory ?? this.dbHistory,
      waveData: waveData ?? this.waveData,
      fftData: fftData ?? this.fftData,
      peakFrequency: peakFrequency ?? this.peakFrequency,
    );
  }
}

class SoundMeterError extends SoundMeterState {
  final String message;

  SoundMeterError(this.message);
}
