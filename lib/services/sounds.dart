import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

/// The sounds of the table: recordings from Kenney's Casino Audio (CC0,
/// `assets/sounds/LICENSE.txt`).
enum Sound { shuffle, deal, envite, ordago }

/// Plays the table's sounds. The app plays them through `audioplayers`;
/// tests use [RecordedSounds].
abstract interface class Sounds {
  factory Sounds() = _PlayedSounds;

  void play(Sound sound);
}

/// Mixed with whatever else is playing, never stopping the player's music,
/// and silent when the phone is.
final class _PlayedSounds implements Sounds {
  _PlayedSounds() {
    unawaited(
      AudioPlayer.global.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
          android: const AudioContextAndroid(
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.none,
          ),
        ),
      ),
    );
  }

  final _players = <Sound, AudioPlayer>{};

  @override
  void play(Sound sound) {
    final player = _players[sound] ??= AudioPlayer()..positionUpdater = null;
    unawaited(
      player.play(
        AssetSource('sounds/${sound.name}.m4a'),
        mode: PlayerMode.lowLatency,
      ),
    );
  }
}

/// Keeps what would have been played, in order.
final class RecordedSounds implements Sounds {
  final played = <Sound>[];

  @override
  void play(Sound sound) => played.add(sound);
}
