abstract class SoundMeterEvent {}

class InitializeSoundMeter extends SoundMeterEvent {}

class UpdateSoundMeterDb extends SoundMeterEvent {
  final double dbValue;

  UpdateSoundMeterDb(this.dbValue);
}

class StopSoundMeter extends SoundMeterEvent {}

class TogglePauseSoundMeter extends SoundMeterEvent {}
