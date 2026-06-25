import 'package:flutter/foundation.dart';
import 'package:pats_space/features/social_focus/models/social_focus_models.dart';
import 'package:pats_space/features/social_focus/repositories/social_focus_repository.dart';

class SocialFocusController extends ChangeNotifier {
  SocialFocusController({required SocialFocusRepository repository})
    : _repository = repository;

  final SocialFocusRepository _repository;

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

  Future<void> createOpenRoom() async {
    _activeRoom = await _repository.createOpenRoom();
    notifyListeners();
  }

  Future<void> joinRoom(String roomId) async {
    _activeRoom = await _repository.joinRoom(roomId);
    notifyListeners();
  }

  Future<void> leaveRoom() async {
    final roomId = _activeRoom?.id;
    if (roomId != null) {
      await _repository.leaveRoom(roomId);
    }

    _activeRoom = null;
    notifyListeners();
  }
}
