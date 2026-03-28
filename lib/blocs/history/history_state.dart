import '../../models/recording_model.dart';

class HistoryState {
  final List<SoundRecording> recordings;

  HistoryState({this.recordings = const []});

  HistoryState copyWith({List<SoundRecording>? recordings}) {
    return HistoryState(
      recordings: recordings ?? this.recordings,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recordings': recordings.map((x) => x.toMap()).toList(),
    };
  }

  factory HistoryState.fromMap(Map<String, dynamic> map) {
    return HistoryState(
      recordings: List<SoundRecording>.from(
        (map['recordings'] as List?)?.map((x) => SoundRecording.fromMap(x)) ?? [],
      ),
    );
  }
}
