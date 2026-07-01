import 'package:pats_space/features/social_focus/models/social_focus_models.dart';

abstract class SocialFocusRepository {
  Future<SocialFocusLobbySnapshot> loadLobby();

  Stream<SocialFocusLobbySnapshot> watchLobby();

  Future<SocialFocusRoom?> restoreActiveRoom();

  Stream<SocialFocusRoom?> watchRoom(String roomId);

  Future<SocialFocusRoom> createOpenRoom();

  Future<SocialFocusRoom> joinRoom(String roomId);

  Future<SocialFocusRoom> updateLocalActivity(
    String roomId,
    SocialFocusActivity activity,
  );

  Future<SocialFocusRoom> updateLocalStatus(
    String roomId,
    SocialFocusMemberStatus status,
  );

  Future<void> leaveRoom(String roomId);
}
