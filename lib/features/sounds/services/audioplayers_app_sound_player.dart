import 'package:audioplayers/audioplayers.dart';
import 'package:pats_space/features/sounds/services/app_sound_player.dart';

class AudioplayersAppSoundPlayer implements AppSoundPlayer {
  AudioplayersAppSoundPlayer({
    AudioPlayer? alertPlayer,
    AudioPlayer? ambiencePlayer,
  }) : _alertPlayer = alertPlayer ?? AudioPlayer(),
       _ambiencePlayer = ambiencePlayer ?? AudioPlayer();

  final AudioPlayer _alertPlayer;
  final AudioPlayer _ambiencePlayer;

  @override
  Future<void> playAlert(String assetPath) async {
    await _alertPlayer.stop();
    await _alertPlayer.setReleaseMode(ReleaseMode.stop);
    await _alertPlayer.play(AssetSource(_relativeAssetPath(assetPath)));
  }

  @override
  Future<void> stopAlert() => _alertPlayer.stop();

  @override
  Future<void> startAmbience(String assetPath, {required double volume}) async {
    await _ambiencePlayer.stop();
    await _ambiencePlayer.setReleaseMode(ReleaseMode.loop);
    await _ambiencePlayer.setVolume(volume);
    await _ambiencePlayer.play(AssetSource(_relativeAssetPath(assetPath)));
  }

  @override
  Future<void> pauseAmbience() => _ambiencePlayer.pause();

  @override
  Future<void> resumeAmbience() => _ambiencePlayer.resume();

  @override
  Future<void> stopAmbience() => _ambiencePlayer.stop();

  @override
  Future<void> setAmbienceVolume(double volume) {
    return _ambiencePlayer.setVolume(volume);
  }

  @override
  Future<void> dispose() async {
    await Future.wait([_alertPlayer.dispose(), _ambiencePlayer.dispose()]);
  }

  String _relativeAssetPath(String assetPath) {
    const assetPrefix = 'assets/';
    return assetPath.startsWith(assetPrefix)
        ? assetPath.substring(assetPrefix.length)
        : assetPath;
  }
}
