import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../models/recording_model.dart';
import 'history_event.dart';
import 'history_state.dart';
import 'dart:io';

class HistoryBloc extends HydratedBloc<HistoryEvent, HistoryState> {
  HistoryBloc() : super(HistoryState()) {
    on<AddRecording>((event, emit) {
      final List<SoundRecording> updatedList = List.from(state.recordings)..insert(0, event.recording);
      emit(state.copyWith(recordings: updatedList));
    });

    on<DeleteRecording>((event, emit) async {
      final recording = state.recordings.firstWhere((r) => r.id == event.id);
      
      // Delete audio file
      final file = File(recording.filePath);
      if (await file.exists()) {
        await file.delete();
      }

      final List<SoundRecording> updatedList = state.recordings.where((r) => r.id != event.id).toList();
      emit(state.copyWith(recordings: updatedList));
    });

    on<RenameRecording>((event, emit) {
      final List<SoundRecording> updatedList = state.recordings.map((r) {
        if (r.id == event.id) {
          return r.copyWith(name: event.newName);
        }
        return r;
      }).toList();
      emit(state.copyWith(recordings: updatedList));
    });
  }

  @override
  HistoryState? fromJson(Map<String, dynamic> json) {
    return HistoryState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(HistoryState state) {
    return state.toMap();
  }
}
