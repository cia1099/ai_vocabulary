import 'dart:typed_data';

class AudioPlayer {
  final Uint8List bytes;
  final String? mimeType;

  AudioPlayer({required this.bytes, this.mimeType});
}
