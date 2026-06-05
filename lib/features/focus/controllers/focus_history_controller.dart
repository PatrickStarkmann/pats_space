import 'package:flutter/foundation.dart';
import 'package:pats_space/features/focus/models/focus_session_record.dart';

class FocusHistoryController extends ChangeNotifier {
  final List<FocusSessionRecord> _records = [];

  List<FocusSessionRecord> get records => List.unmodifiable(_records);

  Duration get totalFocusDuration {
    return _records.fold(Duration.zero, (total, record) {
      return total + record.focusDuration;
    });
  }

  Map<String, Duration> get durationByTag {
    final totals = <String, Duration>{};
    for (final record in _records) {
      totals.update(
        record.tag.name,
        (duration) => duration + record.focusDuration,
        ifAbsent: () => record.focusDuration,
      );
    }
    return totals;
  }

  void addRecord(FocusSessionRecord record) {
    _records.insert(0, record);
    notifyListeners();
  }

  void clear() {
    if (_records.isEmpty) {
      return;
    }

    _records.clear();
    notifyListeners();
  }
}
