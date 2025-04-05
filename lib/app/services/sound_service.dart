import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SoundService extends GetxService {
  static const String prefSoundEnabled = 'soundEnabled';
  
  final _storage = GetStorage();
  final _audioPlayer = AudioPlayer();
  final _isSoundEnabled = true.obs;

  bool get isSoundEnabled => _isSoundEnabled.value;

  Future<SoundService> init() async {
    _isSoundEnabled.value = _storage.read(prefSoundEnabled) ?? true;
    return this;
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }

  void toggleSound() {
    _isSoundEnabled.value = !_isSoundEnabled.value;
    _storage.write(prefSoundEnabled, _isSoundEnabled.value);
  }

  Future<void> playButtonClick() async {
    if (!_isSoundEnabled.value) return;
    await _playSound('button_click.mp3');
  }

  Future<void> playNumberReveal() async {
    if (!_isSoundEnabled.value) return;
    await _playSound('number_reveal.mp3');
  }

  Future<void> playWin() async {
    if (!_isSoundEnabled.value) return;
    await _playSound('win.mp3');
  }

  Future<void> playLose() async {
    if (!_isSoundEnabled.value) return;
    await _playSound('lose.mp3');
  }

  Future<void> playOut() async {
    if (!_isSoundEnabled.value) return;
    await _playSound('out.mp3');
  }

  Future<void> playScoreIncrease() async {
    if (!_isSoundEnabled.value) return;
    await _playSound('score_increase.mp3');
  }

  Future<void> _playSound(String fileName) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/$fileName'));
    } catch (e) {
      print('Error playing sound: $e');
    }
  }
} 