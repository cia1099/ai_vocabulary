import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

Future<void> immediatelyPlay(String url,
    [String? mimeType = 'audio/mp3']) async {
  // url = redirectUrl(url);
  final player = AudioPlayer();
  final subscript = player.onPlayerComplete.listen(
    null,
    onDone: player.dispose,
  );
  if (url.contains('http')) {
    await player.play(UrlSource(url, mimeType: mimeType));
  } else if (url.contains('assets/')) {
    await player.play(AssetSource(url, mimeType: mimeType));
  } else {
    await player.play(DeviceFileSource(url, mimeType: mimeType));
  }
  subscript.cancel();
}

Future<void> bytesPlay(Uint8List bytes, [String mimeType = 'audio/mp3']) async {
  final player = AudioPlayer();
  final subscript = player.onPlayerComplete.listen(
    null,
    onDone: player.dispose,
  );
  await player.play(BytesSource(bytes, mimeType: mimeType));
  subscript.cancel();
}

enum gTTS implements Comparable<gTTS> {
  US(lang: 'en-US'),
  UK(lang: 'en-co.uk'),
  CA(lang: 'en-CA'), //Canada
  AU(lang: 'en-com.au'), //Australia
  IN(lang: 'en-co.in'), //India
  IE(lang: 'en-IE'), //Ireland
  ZA(lang: 'en-za'), //South Africa
  CN(lang: 'zh-CN'),
  TW(lang: 'zh-TW');

  final String _lang;
  String get lang => _lang;
  const gTTS({required String lang}) : _lang = lang;

  @override
  int compareTo(gTTS other) => lang.compareTo(other.lang);
}

Uri redirectUrl(Uri oldUrl) {
  final newUri =
      Uri.https(oldUrl.authority, (['dict'] + oldUrl.pathSegments).join('/'));
  return newUri;
}
