enum AccountSignInProvider { apple, google }

sealed class AccountAuthResult {
  const AccountAuthResult();
}

class AccountSecured extends AccountAuthResult {
  const AccountSecured();
}

class ExistingAccountSignedIn extends AccountAuthResult {
  const ExistingAccountSignedIn();
}

class GuestReplacementRequired extends AccountAuthResult {
  const GuestReplacementRequired({
    required this.provider,
    required this.guestUid,
  });

  final AccountSignInProvider provider;
  final String guestUid;
}

abstract class AccountAuthService {
  bool get isAppleSignInAvailable;

  Future<AccountAuthResult> secureWithApple();

  Future<AccountAuthResult> secureWithGoogle();

  Future<AccountAuthResult> replaceGuestWithExistingAccount(
    GuestReplacementRequired replacement,
  );

  Future<void> signOutToGuest();

  Future<void> deleteCurrentAccount();
}
