abstract interface class AppSoundPlayer {
  Future<void> playAlert(String assetPath);

  Future<void> stopAlert();

  Future<void> startAmbience(String assetPath, {required double volume});

  Future<void> pauseAmbience();

  Future<void> resumeAmbience();

  Future<void> stopAmbience();

  Future<void> setAmbienceVolume(double volume);

  Future<void> dispose();
}
