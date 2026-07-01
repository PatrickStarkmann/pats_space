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

  SocialFocusRoom? get activeRoom => _activeRoom;
  SocialFocusLobbySnapshot? get lastLobbySnapshot => _lastLobbySnapshot;
  bool get hasActiveRoom => _activeRoom != null;

  Future<SocialFocusLobbySnapshot> loadLobby() async {
    final snapshot = await _repository.loadLobby();
    _lastLobbySnapshot = snapshot;
    notifyListeners();
    return snapshot;
  }

  Future<bool> restoreActiveRoom() async {
    final room = await _repository.restoreActiveRoom();
    if (room == null) {
      return false;
    }

    _activeRoom = room;
    _watchActiveRoom(room.id);
    notifyListeners();
    return true;
  }

  Future<void> createOpenRoom() async {
    _activeRoom = await _repository.createOpenRoom();
    _watchActiveRoom(_activeRoom!.id);
    notifyListeners();
  }

  Future<void> joinRoom(String roomId) async {
    _activeRoom = await _repository.joinRoom(roomId);
    _watchActiveRoom(roomId);
    notifyListeners();
  }

  Future<void> leaveRoom() async {
    final roomId = _activeRoom?.id;
    _activeRoom = null;
    await _activeRoomSubscription?.cancel();
    _activeRoomSubscription = null;
    notifyListeners();

    if (roomId != null) {
      await _repository.leaveRoom(roomId);
    }
  }

  Future<void> updateLocalActivity(SocialFocusActivity activity) async {
    final room = _activeRoom;
    if (room == null) {
      return;
    }

    _activeRoom = await _repository.updateLocalActivity(room.id, activity);
    notifyListeners();
  }

  Future<void> updateLocalStatus(SocialFocusMemberStatus status) async {
    final room = _activeRoom;
    if (room == null) {
      return;
    }

    _activeRoom = await _repository.updateLocalStatus(room.id, status);
    notifyListeners();
  }

  void _watchActiveRoom(String roomId) {
    _activeRoomSubscription?.cancel();
    _activeRoomSubscription = _repository.watchRoom(roomId).listen((room) {
      _activeRoom = room;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _activeRoomSubscription?.cancel();
    super.dispose();
  }
}
