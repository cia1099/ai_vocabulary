part of 'vocabulary.dart';

class Phonetic {
  final String phonetic;
  final String? audioUrl;

  Phonetic(this.phonetic, this.audioUrl);
}

extension Phonetics on Vocabulary {
  Iterable<Phonetic> getPhonetics() => definitions.expand((d) sync* {
        if (d.phoneticUs != null && d.translate != null)
          yield Phonetic(d.phoneticUs!, d.audioUs);
      });
}
