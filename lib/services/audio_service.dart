import 'package:audioplayers/audioplayers.dart';

class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _boilingPlayer = AudioPlayer();
  final AudioPlayer _alarmPlayer = AudioPlayer();
  final AudioPlayer _uiPlayer = AudioPlayer(); // dedicated for UI blips

  bool _boilingPlaying = false;

  Future<void> playBoiling() async {
    if (_boilingPlaying) return;
    _boilingPlaying = true;
    await _boilingPlayer.setReleaseMode(ReleaseMode.loop);
    await _boilingPlayer.play(AssetSource('audio/boiling.mp3'));
  }

  Future<void> stopBoiling() async {
    _boilingPlaying = false;
    await _boilingPlayer.stop();
  }

  Future<void> playAlarm() async {
    await _alarmPlayer.play(AssetSource('audio/alarm.wav'));
  }

  Future<void> stopAlarm() async {
    await _alarmPlayer.stop();
  }

  Future<void> playClick() async {
    // Overwrite any currently playing UI sound instantly
    await _uiPlayer.play(AssetSource('audio/click.wav'));
  }

  Future<void> playPop() async {
    await _uiPlayer.play(AssetSource('audio/pop.wav'));
  }

  Future<void> dispose() async {
    await _boilingPlayer.dispose();
    await _alarmPlayer.dispose();
    await _uiPlayer.dispose();
  }
}
