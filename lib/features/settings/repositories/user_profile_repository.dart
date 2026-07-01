import 'package:pats_space/features/settings/models/user_profile.dart';

abstract class UserProfileRepository {
  Future<UserProfile> loadProfile();

  Future<UserProfile> saveDisplayName(String displayName);

  Future<List<UserFriend>> loadFriends();

  Future<List<FriendRequest>> loadIncomingFriendRequests();

  Future<List<FriendRequest>> loadSentFriendRequests();

  Future<UserProfile> sendFriendRequestByCode(String friendCode);

  Future<void> acceptFriendRequest(FriendRequest request);

  Future<void> cancelFriendRequest(FriendRequest request);

  Future<void> deleteFriend(UserFriend friend);
}
