import 'package:flutter/cupertino.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

void sttRecognizer(SpeechToText stt) async {
  if (stt.isListening) stt.cancel();
  return stt.listen(
      onResult: (result) {
        final text = result.recognizedWords;
        debugPrint(
            'Recognized words: $text with confidence:${result.confidence}');
      },
      onSoundLevelChange: (level) {
        print('monitor sound level = $level');
      },
      localeId: 'en_US');
}

// listener events when stt initialization
void onStatus(String status) {
  if (status == SpeechToText.doneStatus) {
    print('done recognition process and monitor');
  }
  if (status == SpeechToText.listeningStatus) {
    print('start listening microphone');
  }
  if (status == SpeechToText.notListeningStatus) {
    print('stop listening microphone');
  }
}

void onError(SpeechRecognitionError error) {
  debugPrint('Error on Speech Recognition: ${error.errorMsg}');
}

//**
// refs.
// old version but simplest: https://github.com/MarcusNg/flutter_voice
// */
