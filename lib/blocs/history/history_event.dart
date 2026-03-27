import '../../models/recording_model.dart';

abstract class HistoryEvent {}

class LoadHistory extends HistoryEvent {}

class AddRecording extends HistoryEvent {
  final SoundRecording recording;
  AddRecording(this.recording);
}

class DeleteRecording extends HistoryEvent {
  final String id;
  DeleteRecording(this.id);
}

class RenameRecording extends HistoryEvent {
  final String id;
  final String newName;
  RenameRecording(this.id, this.newName);
}
