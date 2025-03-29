import 'package:text2speech/text2speech.dart' as tts;

enum Accent {
  UK(tts.gTTS.UK, tts.AzureLang.UK, '🇬🇧'),
  IN(tts.gTTS.IN, tts.AzureLang.IN, '🇮🇳'),
  AU(tts.gTTS.AU, tts.AzureLang.AU, '🇦🇺'),
  CA(tts.gTTS.CA, tts.AzureLang.CA, '🇨🇦'),
  US(tts.gTTS.US, tts.AzureLang.US, '🇺🇸');

  final tts.gTTS gTTS;
  final tts.AzureLang azure;
  final String flag;
  const Accent(this.gTTS, this.azure, this.flag);
}

enum AzureVoicer {
  Ava(gender: "Female", name: "Ava", lang: "en-US"),
  Nova(gender: "Female", name: "Nova", lang: "en-US"),
  Emma(gender: "Female", name: "Emma", lang: "en-US"),
  Brandon(gender: "Male", name: "Brandon", lang: "en-US"),
  Adam(gender: "Male", name: "Adam", lang: "en-US"),
  Christopher(gender: "Male", name: "Christopher", lang: "en-US");

  final String gender;
  final String name;
  final String lang;
  const AzureVoicer({
    required this.gender,
    required this.name,
    this.lang = "en-US",
  });

  String get apiName => '$lang-${name}MultilingualNeural';
}
