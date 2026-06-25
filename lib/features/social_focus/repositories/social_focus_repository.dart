import 'package:pats_space/features/social_focus/models/social_focus_models.dart';

abstract class SocialFocusRepository {
  Future<SocialFocusLobbySnapshot> loadLobby();

  Future<SocialFocusRoom> createOpenRoom();

  Future<SocialFocusRoom> joinRoom(String roomId);

  Future<void> leaveRoom(String roomId);
}
