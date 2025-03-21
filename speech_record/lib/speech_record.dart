library speech_record;

export 'src/record_speech_button.dart';
export 'src/phonetic_button.dart';
export 'src/utils.dart';

//**
//repository definition: https://github.com/llfbandit/record/issues/51
//experimental: https://www.youtube.com/watch?v=2oBlBxpX_0M&t=406s
//Average current = -45.0
//better usage than official stream: https://github.com/llfbandit/record/issues/71
// */
const kMinAmplitude = -45.0; //-160.0;
const kMaxAmplitude = .0;

// https://learn.microsoft.com/en-us/azure/ai-services/speech-service/rest-speech-to-text-short#audio-formats
const kAzureSampleRate = 16000;
const kAzureBitRate = 256000;
