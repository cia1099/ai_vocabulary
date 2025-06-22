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
  Ava(gender: "Female", name: "Ava"),
  Nova(gender: "Female", name: "Nova"),
  Emma(gender: "Female", name: "Emma"),
  Brandon(gender: "Male", name: "Brandon"),
  Adam(gender: "Male", name: "Adam"),
  Christopher(gender: "Male", name: "Christopher");

  final String gender;
  final String name;
  const AzureVoicer({required this.gender, required this.name});

  // String get apiName => '$lang-${name}MultilingualNeural';
}

enum TranslateLocate {
  none("en-US", "English"),
  zhCN('zh-CN', "简体中文"),
  zhTW('zh-TW', "繁體中文"),
  jaJP('ja-JP', "日本語"),
  koKR('ko-KR', "한국어"),
  viVN('vi-VN', "Tiếng Việt"),
  arSA('ar-SA', "العربية"),
  thTH('th-TH', "ไทย");

  final String lang;
  final String native;
  const TranslateLocate(this.lang, this.native);
}

enum Quiz { cloze, puzzle, arbitrary }

enum TableName {
  acquaintances('acquaintances'),
  collections('collections'),
  collectWords('collect_words'),
  punchDays('punch_days');

  final String name;
  const TableName(this.name);
}
