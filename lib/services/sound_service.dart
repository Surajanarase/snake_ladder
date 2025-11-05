import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _dicePlayer = AudioPlayer();
  final AudioPlayer _movePlayer = AudioPlayer();
  
  bool _soundEnabled = true;

  bool get soundEnabled => _soundEnabled;
  
  void toggleSound() {
    _soundEnabled = !_soundEnabled;
  }

  Future<void> playDiceRoll() async {
    if (!_soundEnabled) return;
    try {
      await _dicePlayer.stop();
      await _dicePlayer.play(AssetSource('sounds/dice_roll.mp3'));
    } catch (e) {
      if (kDebugMode) {
        print('Error playing dice sound: $e');
      }
    }
  }

  Future<void> playMoveStep() async {
    if (!_soundEnabled) return;
    try {
      // Use a separate player instance for each step to allow overlap
      final player = AudioPlayer();
      await player.play(AssetSource('sounds/move_step.mp3'));
      // Clean up after playing
      player.onPlayerComplete.listen((_) {
        player.dispose();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error playing move sound: $e');
      }
    }
  }

  void dispose() {
    _dicePlayer.dispose();
    _movePlayer.dispose();
  }
}