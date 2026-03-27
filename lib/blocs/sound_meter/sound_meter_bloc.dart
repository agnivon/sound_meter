import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_recorder/flutter_recorder.dart';
import 'package:permission_handler/permission_handler.dart';

import 'sound_meter_event.dart';
import 'sound_meter_state.dart';

/// The [SoundMeterBloc] manages the application's core audio recording state,
/// processing native device microphone input to extract decibel levels, waveform buffers,
/// and Fast Fourier Transform (FFT) data dynamically in real-time.
///
/// It utilizes `flutter_recorder` to interface natively with the system microphone,
/// polling at a high frame rate to provide instantaneous updates for responsive UI charting.
class SoundMeterBloc extends Bloc<SoundMeterEvent, SoundMeterState> {
  /// Internal timer responsible for polling the hardware buffer continuously.
  Timer? _timer;

  /// Tracks the peak decibel reading recorded across the active session.
  double _maxDb = 0;

  /// Tracks the lowest decibel reading recorded across the active session.
  /// Initialized to 120 (maximum standard environmental noise) so the first reading natively drops it.
  double _minDb = 120;

  /// Maintains a rolling exponential moving average (EMA) of historical decibel levels.
  double _avgDb = 0;

  /// Tracks the active duration of the current recording sequence.
  Duration _duration = Duration.zero;

  /// The internal polling rate determining how frequently the UI buffers are updated.
  /// Set to 33ms to natively simulate roughly ~30 frames per second (FPS) mapping.
  final int _tickMs = 33;

  /// Flags whether the bloc is processing the very first valid audible hardware reading,
  /// allowing it to skip initial digital zero-state warm-up limits.
  bool _isFirstReading = true;

  /// The calibration offset in dB applied to all incoming hardware readings.
  double _dbOffset = 0.0;

  /// Maintains a rolling sliding window of historical dB values.
  /// Used predominantly to render the continuous red timeline graph mapping backwards over ~24 seconds.
  final List<double> _dbHistory = [];

  SoundMeterBloc() : super(SoundMeterInitial()) {
    on<InitializeSoundMeter>(_onInitialize);
    on<UpdateSoundMeterDb>(_onUpdate);
    on<TogglePauseSoundMeter>(_onTogglePause);
    on<StopSoundMeter>(_onStop);
    on<ResetSoundMeter>(_onReset);
    on<UpdateDbOffset>(_onUpdateDbOffset);
  }

  /// Handles the calibration offset update logic.
  void _onUpdateDbOffset(UpdateDbOffset event, Emitter<SoundMeterState> emit) {
    _dbOffset = event.offset;
    if (state is SoundMeterRecording) {
      final s = state as SoundMeterRecording;
      emit(s.copyWith(dbOffset: _dbOffset));
    }
  }

  /// Initiates the continuous background hardware polling loop.
  ///
  /// Triggers automatically every 33 milliseconds to pull synchronous live snapshots from the Native audio thread.
  /// Calculates internal peak decibels, extracts raw waves, executes FFT mapping,
  /// and discovers the prevailing peak frequency pitch before dispatching an internal update event.
  void _startTimer() {
    // Ensure any previously stray timer is safely killed before allocating a new loop constraint.
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: _tickMs), (_) {
      // 1. Fetch the raw amplitude in dBFS (decibels relative to full scale) which naturally ranges from -120 to 0.
      double volumeDbFs = Recorder.instance.getVolumeDb();
      volumeDbFs = volumeDbFs.clamp(-120.0, 0.0);

      // Convert mapping from negative DBFS space into absolute positive environmental decibel (0 to 120 bounds).
      double currentDb = (volumeDbFs + 100);
      if (currentDb < 0) currentDb = 0.0;

      // 2. Extract the synchronous raw audio physical membrane array output (ranging from -1.0 to 1.0).
      final waveData = Recorder.instance.getWave();

      // 3. Extract the computed Fast Fourier Transform frequency bins recursively.
      final fftData = Recorder.instance.getFft();

      // Loop over the FFT array to mathematically isolate the highest magnitude frequency bin.
      double peakVal = 0.0;
      int peakIndex = 0;
      for (int i = 0; i < fftData.length; i++) {
        if (fftData[i] > peakVal) {
          peakVal = fftData[i];
          peakIndex = i;
        }
      }
      // Calculate actual structural Hz frequency using the native 44.1kHz sampling rate mapping across standard 256 frame divisors.
      double peakFrequency = peakIndex * (44100.0 / 2 / 256);

      // Dispatch the payload safely back up directly to the Bloc event queue so UI safely redraws bounds.
      add(UpdateSoundMeterDb(currentDb, waveData, fftData, peakFrequency));
    });
  }

  /// Initializes the Sound Meter recording session asynchronously.
  /// Requests microphone hardware permissions and invokes native device bindings dynamically.
  Future<void> _onInitialize(
    InitializeSoundMeter event,
    Emitter<SoundMeterState> emit,
  ) async {
    // Validate runtime microphone security limits strictly
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      emit(SoundMeterError('Microphone permission not granted'));
      return;
    }

    try {
      // Initialize internal native recording bindings (PCM 32-bit floats provide maximum resolution).
      if (!Recorder.instance.isDeviceInitialized()) {
        await Recorder.instance.init(format: PCMFormat.f32le);
      }
      // Spin up the listener daemon safely.
      Recorder.instance.start();

      // Clear structural limits internally so tracking is cleanly formatted from a blank boundary wall.
      _maxDb = 0;
      _minDb = 0;
      _avgDb = 0;
      _duration = Duration.zero;
      _isFirstReading = true;

      // Start the UI polling dispatcher internally.
      _startTimer();

      // Emit a cleanly bounded baseline payload so the system knows tracking is fully live.
      emit(
        SoundMeterRecording(
          currentDb: 0,
          maxDb: 0,
          minDb: 0,
          avgDb: 0,
          duration: Duration.zero,
          dbOffset: _dbOffset,
        ),
      );
    } catch (e) {
      // In the case where audio engine bindings inherently crash the hardware bus, emit error gracefully.
      emit(SoundMeterError('Failed to initialize recorder: $e'));
    }
  }

  /// Toggles the hardware buffer native reading loop on or off efficiently,
  /// managing permission bounds implicitly when un-pausing.
  Future<void> _onTogglePause(
    TogglePauseSoundMeter event,
    Emitter<SoundMeterState> emit,
  ) async {
    if (state is! SoundMeterRecording) return;
    final currentState = state as SoundMeterRecording;

    if (currentState.isPaused) {
      // === Resume Logic ===
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        // We gracefully abort resumption without destroying the user's historical state natively.
        return;
      }

      try {
        Recorder.instance.start();
      } catch (_) {}

      _startTimer();
      emit(currentState.copyWith(isPaused: false));
    } else {
      // === Pause Logic ===
      // Halt the rapid dispatch timing loop implicitly conserving absolute system battery life correctly.
      _timer?.cancel();
      try {
        Recorder.instance.stop();
      } catch (_) {}

      // Keep tracking structural layout, just notify the UI that active reading parameters froze safely.
      emit(currentState.copyWith(isPaused: true));
    }
  }

  /// Processes the rapid event dispatches arriving internally from the native timer loop.
  /// Aggregates mapping arrays securely, rolling calculations logically, and emits structural copies seamlessly.
  void _onUpdate(UpdateSoundMeterDb event, Emitter<SoundMeterState> emit) {
    if (state is! SoundMeterRecording && state is! SoundMeterInitial) return;
    if (state is SoundMeterRecording &&
        (state as SoundMeterRecording).isPaused) {
      return;
    }

    final rawDb = event.dbValue;
    // Apply calibration offset
    final db = rawDb + _dbOffset;

    // Manage a strictly shifting sliding window for Timeline rendering dynamically.
    _dbHistory.add(db);
    // Hard cap mapping queue size safely to prevent memory leak structural crashes globally. (~24 seconds limit natively).
    if (_dbHistory.length > 800) {
      _dbHistory.removeAt(0);
    }

    // Filter physical warm-up glitches. Native audio buses often dispatch explicit absolute 0.0 values briefly when locking bindings.
    if (_isFirstReading) {
      if (rawDb > 0.0) {
        _minDb = db;
        _maxDb = db;
        _avgDb = db;
        _isFirstReading = false;
      }
    } else {
      // Standard mathematical calculation layout bindings dynamically checking absolute limits.
      _maxDb = db > _maxDb ? db : _maxDb;
      _minDb = db < _minDb ? db : _minDb;
      // Exponential Moving Average (EMA) logically suppressing noise variance cleanly.
      _avgDb = (_avgDb * 0.95) + (db * 0.05);
    }

    _duration += Duration(milliseconds: _tickMs);

    emit(
      SoundMeterRecording(
        currentDb: db,
        rawDb: rawDb,
        maxDb: _maxDb,
        minDb: _minDb,
        avgDb: _avgDb,
        duration: _duration,
        hasReading: !_isFirstReading,
        dbOffset: _dbOffset,
        dbHistory: List.of(_dbHistory),
        waveData: event.waveData,
        fftData: event.fftData,
        peakFrequency: event.peakFrequency,
      ),
    );
  }

  /// Triggers a total application system native bounds stop, dropping bindings to the original initial state structurally.
  void _onStop(StopSoundMeter event, Emitter<SoundMeterState> emit) {
    _timer?.cancel();
    _timer = null;
    try {
      Recorder.instance.stop();
    } catch (_) {}
    emit(SoundMeterInitial());
  }

  /// Wipes all memory bindings, zeroing historical layout arrays structurally, but
  /// keeps the UI firmly rendered on screen natively safely waiting for the user to resume playing dynamically.
  void _onReset(ResetSoundMeter event, Emitter<SoundMeterState> emit) {
    _timer?.cancel();
    try {
      Recorder.instance.stop();
    } catch (_) {}

    _maxDb = 0;
    _minDb = 120;
    _avgDb = 0;
    _duration = Duration.zero;
    _isFirstReading = true;
    _dbHistory.clear();

    emit(
      SoundMeterRecording(
        currentDb: 0,
        maxDb: 0,
        minDb: 0,
        avgDb: 0,
        duration: Duration.zero,
        isPaused: true,
        hasReading: false,
        dbOffset: _dbOffset,
        dbHistory: const [],
        waveData: const [],
        fftData: const [],
        peakFrequency: 0.0,
      ),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    try {
      Recorder.instance.stop();
    } catch (_) {}
    return super.close();
  }
}
