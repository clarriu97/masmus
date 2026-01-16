import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class AudioGenerator {
  static Future<String> generateDealSound() async {
    return _generateNoise(durationMs: 100, volume: 0.5, name: 'deal.wav');
  }

  static Future<String> generateChipSound() async {
    return _generateNoise(durationMs: 50, volume: 0.8, name: 'chip.wav');
  }

  static Future<String> _generateNoise({
    required int durationMs,
    required double volume,
    required String name,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$name');

    if (file.existsSync()) {
      return file.path;
    }

    const int sampleRate = 44100;
    final int numSamples = (durationMs * sampleRate) ~/ 1000;
    const int byteRate = sampleRate * 1; // 8-bit mono
    const int blockAlign = 1;
    const int bitsPerSample = 8;
    final int dataSize = numSamples * blockAlign;
    final int waveSize = 36 + dataSize;

    final BytesBuilder bytes = BytesBuilder();

    // RIFF header
    bytes.add(_stringToBytes('RIFF'));
    bytes.add(_intToBytes(waveSize, 4));
    bytes.add(_stringToBytes('WAVE'));

    // fmt chunk
    bytes.add(_stringToBytes('fmt '));
    bytes.add(_intToBytes(16, 4)); // Subchunk1Size
    bytes.add(_intToBytes(1, 2)); // AudioFormat (PCM)
    bytes.add(_intToBytes(1, 2)); // NumChannels (Mono)
    bytes.add(_intToBytes(sampleRate, 4)); // SampleRate
    bytes.add(_intToBytes(byteRate, 4)); // ByteRate
    bytes.add(_intToBytes(blockAlign, 2)); // BlockAlign
    bytes.add(_intToBytes(bitsPerSample, 2)); // BitsPerSample

    // data chunk
    bytes.add(_stringToBytes('data'));
    bytes.add(_intToBytes(dataSize, 4));

    // Generate white noise data
    for (int i = 0; i < numSamples; i++) {
      // Simple white noise
      // int sample = (Random().nextDouble() * 255).toInt();

      // Let's try to make it sound slightly more like a card swipe (decaying noise)
      final double t = i / numSamples;
      final double amplitude = (1.0 - t) * volume; // Linear decay
      // Generate random byte centered at 128 (silence for 8-bit)
      // int noise = ((Random().nextDouble() * 2 - 1) * 127 * amplitude).toInt() + 128;

      // Deterministic pseudo-random for reproducibility/simplicity without Random import if desired,
      // but Random is fine. Using a simple LCG or just hardcoded pattern for "swish".
      // A simple "swish" is often filtered noise, but raw noise with envelope is okay for a start.

      // Using a simple sine wave sweep for "chip" might be better?
      // Let's stick to noise for "deal" and short tick for "chip".

      int noise = ((DateTime.now().microsecondsSinceEpoch % 255) * amplitude)
          .toInt();
      // Ensure 8-bit range
      if (noise < 0) {
        noise = 0;
      }
      if (noise > 255) {
        noise = 255;
      }

      bytes.addByte(noise);
    }

    await file.writeAsBytes(bytes.toBytes());
    return file.path;
  }

  static List<int> _stringToBytes(String s) {
    return s.codeUnits;
  }

  static List<int> _intToBytes(int value, int length) {
    final List<int> result = [];
    for (int i = 0; i < length; i++) {
      result.add((value >> (8 * i)) & 0xFF);
    }
    return result;
  }
}
