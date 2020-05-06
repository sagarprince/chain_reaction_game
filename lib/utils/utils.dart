import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:assets_audio_player/playable.dart';

class ExplodeSound {
  static play() {
    AssetsAudioPlayer.playAndForget(Audio('assets/audio/pop.mp3'));
  }
}
