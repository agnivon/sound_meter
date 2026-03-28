import '../../utils/sound_utils.dart';

abstract class SoundMeterEvent {}

class InitializeSoundMeter extends SoundMeterEvent {}

class UpdateSoundMeterDb extends SoundMeterEvent {
  final double dbValue;
  final List<double> waveData;
  final List<double> fftData;
  final double peakFrequency;

  UpdateSoundMeterDb(this.dbValue, this.waveData, this.fftData, this.peakFrequency);
}

class StopSoundMeter extends SoundMeterEvent {}

class TogglePauseSoundMeter extends SoundMeterEvent {}

class ResetSoundMeter extends SoundMeterEvent {}

class SetFrequencyWeighting extends SoundMeterEvent {
  final FrequencyWeighting weighting;
  SetFrequencyWeighting(this.weighting);
}

class SetTimeWeighting extends SoundMeterEvent {
  final TimeWeighting weighting;
  SetTimeWeighting(this.weighting);
}

class UpdateDbOffset extends SoundMeterEvent {
  final double offset;
  UpdateDbOffset(this.offset);
}

class SaveSoundMeter extends SoundMeterEvent {
  final String name;
  SaveSoundMeter(this.name);
}
