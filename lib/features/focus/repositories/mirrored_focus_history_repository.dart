import 'package:flutter/foundation.dart';
import 'package:pats_space/features/focus/models/focus_session_record.dart';
import 'package:pats_space/features/focus/repositories/focus_history_repository.dart';

class MirroredFocusHistoryRepository implements FocusHistoryRepository {
  const MirroredFocusHistoryRepository({
    required this.localRepository,
    required this.remoteRepository,
  });

  final FocusHistoryRepository localRepository;
  final FocusHistoryRepository remoteRepository;

  @override
  Future<List<FocusSessionRecord>> loadRecords() {
    return localRepository.loadRecords();
  }

  @override
  Future<void> saveRecords(List<FocusSessionRecord> records) async {
    await localRepository.saveRecords(records);
    try {
      await remoteRepository.saveRecords(records);
    } catch (error, stackTrace) {
      debugPrint('Could not sync focus history: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Future<void> clearRecords() async {
    await localRepository.clearRecords();
    try {
      await remoteRepository.clearRecords();
    } catch (error, stackTrace) {
      debugPrint('Could not clear remote focus history: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
