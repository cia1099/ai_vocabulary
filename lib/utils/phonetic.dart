import 'dart:ui' show VoidCallback;

import 'package:ai_vocabulary/api/dict_api.dart' show getAudioPlayer, soundGTTs;
import 'package:text2speech/text2speech.dart';

VoidCallback playPhonetic(
  String? url, {
  required String word,
  gTTS gTTs = gTTS.US,
}) {
  return url != null
      ? () => soundAudio(
        url,
      ) //immediatelyPlay(url, 'audio/mp3').onError((_, __) => soundAudio(url))
      : () => soundGTTs(word, gTTs);
}

void soundAudio(String audioUrl) async {
  final player = await getAudioPlayer(audioUrl);
  bytesPlay(player.bytes, player.mimeType ?? 'audio/mp3');
}
