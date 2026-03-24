import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_recorder/flutter_recorder.dart';
import 'package:permission_handler/permission_handler.dart';

import 'sound_meter_event.dart';
import 'sound_meter_state.dart';

class SoundMeterBloc extends Bloc<SoundMeterEvent, SoundMeterState> {
  Timer? _timer;
  double _maxDb = 0;
  double _minDb = 120;
  double _avgDb = 0;
  Duration _duration = Duration.zero;
  final int _tickMs = 33;

  bool _isFirstReading = true;
  final List<double> _dbHistory = [];

  SoundMeterBloc() : super(SoundMeterInitial()) {
    on<InitializeSoundMeter>(_onInitialize);
    on<UpdateSoundMeterDb>(_onUpdate);
    on<TogglePauseSoundMeter>(_onTogglePause);
    on<StopSoundMeter>(_onStop);
    on<ResetSoundMeter>(_onReset);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: _tickMs), (_) {
      double volumeDbFs = Recorder.instance.getVolumeDb();
      volumeDbFs = volumeDbFs.clamp(-120.0, 0.0);
      double currentDb = (volumeDbFs + 100);
      if (currentDb < 0) currentDb = 0.0;
      
      final waveData = Recorder.instance.getWave();
      final fftData = Recorder.instance.getFft();
      
      double peakVal = 0.0;
      int peakIndex = 0;
      for (int i = 0; i < fftData.length; i++) {
        if (fftData[i] > peakVal) {
          peakVal = fftData[i];
          peakIndex = i;
        }
      }
      double peakFrequency = peakIndex * (44100.0 / 2 / 256);

      add(UpdateSoundMeterDb(currentDb, waveData, fftData, peakFrequency));
    });
  }

  Future<void> _onInitialize(
    InitializeSoundMeter event,
    Emitter<SoundMeterState> emit,
  ) async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      emit(SoundMeterError('Microphone permission not granted'));
      return;
    }

    try {
      if (!Recorder.instance.isDeviceInitialized()) {
        await Recorder.instance.init(format: PCMFormat.f32le);
      }
      Recorder.instance.start();

      _maxDb = 0;
      _minDb = 0;
      _avgDb = 0;
      _duration = Duration.zero;
      _isFirstReading = true;

      _startTimer();

      emit(
        SoundMeterRecording(
          currentDb: 0,
          maxDb: 0,
          minDb: 0,
          avgDb: 0,
          duration: Duration.zero,
        ),
      );
    } catch (e) {
      emit(SoundMeterError('Failed to initialize recorder: $e'));
    }
  }

  Future<void> _onTogglePause(
    TogglePauseSoundMeter event,
    Emitter<SoundMeterState> emit,
  ) async {
    if (state is! SoundMeterRecording) return;
    final currentState = state as SoundMeterRecording;

    if (currentState.isPaused) {
      // Resume
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        // Technically an error, but let's just abort resumption or emit error
        // Because of architecture, we won't swap to an error state losing data,
        // we'll just quietly ignore or we could swap to error state.
        // Emitting an error state reset would lose their current gauge data, but we can do it if required.
        return;
      }

      try {
        Recorder.instance.start();
      } catch (_) {}

      _startTimer();
      emit(currentState.copyWith(isPaused: false));
    } else {
      // Pause
      _timer?.cancel();
      try {
        Recorder.instance.stop();
      } catch (_) {}

      emit(currentState.copyWith(isPaused: true));
    }
  }

  void _onUpdate(UpdateSoundMeterDb event, Emitter<SoundMeterState> emit) {
    if (state is! SoundMeterRecording && state is! SoundMeterInitial) return;
    if (state is SoundMeterRecording && (state as SoundMeterRecording).isPaused) {
      return;
    }

    final db = event.dbValue;
    
    _dbHistory.add(db);
    // keep max 24 seconds (33ms * 730 = 24s. Let's cap at 800)
    if (_dbHistory.length > 800) {
      _dbHistory.removeAt(0);
    }
    
    if (_isFirstReading) {
      // Ignore absolute 0.0 which miniaudio returns while buffers warm up initially
      if (db > 0.0) {
        _minDb = db;
        _maxDb = db;
        _avgDb = db;
        _isFirstReading = false;
      }
    } else {
      _maxDb = db > _maxDb ? db : _maxDb;
      _minDb = db < _minDb ? db : _minDb;
      _avgDb = (_avgDb * 0.95) + (db * 0.05); // Rolling average
    }

    _duration += Duration(milliseconds: _tickMs);

    emit(
      SoundMeterRecording(
        currentDb: db,
        maxDb: _maxDb,
        minDb: _minDb,
        avgDb: _avgDb,
        duration: _duration,
        hasReading: !_isFirstReading,
        dbHistory: List.of(_dbHistory),
        waveData: event.waveData,
        fftData: event.fftData,
        peakFrequency: event.peakFrequency,
      ),
    );
  }

  void _onStop(StopSoundMeter event, Emitter<SoundMeterState> emit) {
    _timer?.cancel();
    _timer = null;
    try {
      Recorder.instance.stop();
    } catch (_) {}
    emit(SoundMeterInitial());
  }

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
