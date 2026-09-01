/// Public Patsspace destinations used throughout the app.
class AppLinks {
  const AppLinks._();

  static final Uri privacyPolicy = Uri.parse(
    'https://anpalabs.com/apps/patsspace/privacy-policy/',
  );

  static final Uri termsOfUse = Uri.parse(
    'https://anpalabs.com/apps/patsspace/terms-of-use/',
  );

  static final Uri supportEmail = Uri(
    scheme: 'mailto',
    path: 'anpalabs@gmail.com',
  );
}
