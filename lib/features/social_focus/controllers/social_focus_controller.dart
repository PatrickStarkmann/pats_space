import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pats_space/features/social_focus/models/social_focus_models.dart';
import 'package:pats_space/features/social_focus/repositories/social_focus_repository.dart';

class SocialFocusController extends ChangeNotifier {
  SocialFocusController({required SocialFocusRepository repository})
    : _repository = repository;

  final SocialFocusRepository _repository;
  StreamSubscription<SocialFocusRoom?>? _activeRoomSubscription;

  SocialFocusRoom? _activeRoom;
  SocialFocusLobbySnapshot? _lastLobbySnapshot;
  bool _disposed = false;

  SocialFocusRoom? get activeRoom => _activeRoom;
  SocialFocusLobbySnapshot? get lastLobbySnapshot => _lastLobbySnapshot;
  bool get hasActiveRoom => _activeRoom != null;

  Future<SocialFocusLobbySnapshot> loadLobby() async {
    final SocialFocusLobbySnapshot snapshot;
    try {
      snapshot = await _repository.loadLobby();
    } catch (error, stackTrace) {
      debugPrint('Could not load social focus lobby: $error');
      debugPrintStack(stackTrace: stackTrace);
      return _lastLobbySnapshot ??
          const SocialFocusLobbySnapshot(openRooms: [], friends: []);
    }

    if (_disposed) {
      return snapshot;
    }

    _lastLobbySnapshot = snapshot;
    notifyListeners();
    return snapshot;
  }

  Stream<SocialFocusLobbySnapshot> watchLobby() {
    return _repository.watchLobby().map((snapshot) {
      if (_disposed) {
        return snapshot;
      }

      _lastLobbySnapshot = snapshot;
      notifyListeners();
      return snapshot;
    });
  }

  Future<bool> restoreActiveRoom() async {
    final SocialFocusRoom? room;
    try {
      room = await _repository.restoreActiveRoom();
    } catch (error, stackTrace) {
      debugPrint('Could not restore social focus room: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }

    if (_disposed) {
      return false;
    }

    if (room == null) {
      return false;
    }

    _activeRoom = room;
    _watchActiveRoom(room.id);
    notifyListeners();
    return true;
  }

  Future<void> createOpenRoom() async {
    final SocialFocusRoom room;
    try {
      room = await _repository.createOpenRoom();
    } catch (error, stackTrace) {
      debugPrint('Could not create social focus room: $error');
      debugPrintStack(stackTrace: stackTrace);
      return;
    }

    if (_disposed) {
      return;
    }

    _activeRoom = room;
    _watchActiveRoom(room.id);
    notifyListeners();
  }

  Future<void> joinRoom(String roomId) async {
    final SocialFocusRoom room;
    try {
      room = await _repository.joinRoom(roomId);
    } catch (error, stackTrace) {
      debugPrint('Could not join social focus room: $error');
      debugPrintStack(stackTrace: stackTrace);
      return;
    }

    if (_disposed) {
      return;
    }

    _activeRoom = room;
    _watchActiveRoom(roomId);
    notifyListeners();
  }

  Future<void> leaveRoom() async {
    if (_disposed) {
      return;
    }

    final roomId = _activeRoom?.id;
    _activeRoom = null;
    await _activeRoomSubscription?.cancel();
    _activeRoomSubscription = null;
    if (!_disposed) {
      notifyListeners();
    }

    if (roomId != null) {
      try {
        await _repository.leaveRoom(roomId);
      } catch (error, stackTrace) {
        debugPrint('Could not leave social focus room: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }

  void clearActiveRoomLocally() {
    if (_disposed || _activeRoom == null) {
      return;
    }

    _activeRoom = null;
    _activeRoomSubscription?.cancel();
    _activeRoomSubscription = null;
    notifyListeners();
  }

  Future<void> updateLocalActivity(SocialFocusActivity activity) async {
    if (_disposed) {
      return;
    }

    final room = _activeRoom;
    if (room == null) {
      return;
    }

    final SocialFocusRoom updatedRoom;
    try {
      updatedRoom = await _repository.updateLocalActivity(room.id, activity);
    } catch (error, stackTrace) {
      debugPrint('Could not update social focus activity: $error');
      debugPrintStack(stackTrace: stackTrace);
      return;
    }
    if (_disposed) {
      return;
    }

    _activeRoom = updatedRoom;
    notifyListeners();
  }

  Future<void> updateLocalStatus(SocialFocusMemberStatus status) async {
    if (_disposed) {
      return;
    }

    final room = _activeRoom;
    if (room == null) {
      return;
    }

    final SocialFocusRoom updatedRoom;
    try {
      updatedRoom = await _repository.updateLocalStatus(room.id, status);
    } catch (error, stackTrace) {
      debugPrint('Could not update social focus status: $error');
      debugPrintStack(stackTrace: stackTrace);
      return;
    }
    if (_disposed) {
      return;
    }

    _activeRoom = updatedRoom;
    notifyListeners();
  }

  void _watchActiveRoom(String roomId) {
    if (_disposed) {
      return;
    }

    _activeRoomSubscription?.cancel();
    _activeRoomSubscription = _repository.watchRoom(roomId).listen((room) {
      if (_disposed) {
        return;
      }

      _activeRoom = room;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _activeRoomSubscription?.cancel();
    super.dispose();
  }
}
