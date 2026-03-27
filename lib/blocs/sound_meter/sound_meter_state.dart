import '../../utils/sound_utils.dart';

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
  final double dbOffset;
  final double rawDb;

  final FrequencyWeighting freqWeighting;
  final TimeWeighting timeWeighting;

  SoundMeterRecording({
    required this.currentDb,
    this.rawDb = 0.0,
    required this.maxDb,
    required this.minDb,
    required this.avgDb,
    required this.duration,
    this.isPaused = false,
    this.hasReading = true,
    this.dbOffset = 0.0,
    this.dbHistory = const [],
    this.waveData = const [],
    this.fftData = const [],
    this.peakFrequency = 0.0,
    this.freqWeighting = FrequencyWeighting.a,
    this.timeWeighting = TimeWeighting.fast,
  });

  SoundMeterRecording copyWith({
    double? currentDb,
    double? rawDb,
    double? maxDb,
    double? minDb,
    double? avgDb,
    Duration? duration,
    bool? isPaused,
    bool? hasReading,
    double? dbOffset,
    List<double>? dbHistory,
    List<double>? waveData,
    List<double>? fftData,
    double? peakFrequency,
    FrequencyWeighting? freqWeighting,
    TimeWeighting? timeWeighting,
  }) {
    return SoundMeterRecording(
      currentDb: currentDb ?? this.currentDb,
      rawDb: rawDb ?? this.rawDb,
      maxDb: maxDb ?? this.maxDb,
      minDb: minDb ?? this.minDb,
      avgDb: avgDb ?? this.avgDb,
      duration: duration ?? this.duration,
      isPaused: isPaused ?? this.isPaused,
      hasReading: hasReading ?? this.hasReading,
      dbOffset: dbOffset ?? this.dbOffset,
      dbHistory: dbHistory ?? this.dbHistory,
      waveData: waveData ?? this.waveData,
      fftData: fftData ?? this.fftData,
      peakFrequency: peakFrequency ?? this.peakFrequency,
      freqWeighting: freqWeighting ?? this.freqWeighting,
      timeWeighting: timeWeighting ?? this.timeWeighting,
    );
  }
}

class SoundMeterError extends SoundMeterState {
  final String message;

  SoundMeterError(this.message);
}
