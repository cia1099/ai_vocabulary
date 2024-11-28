part of 'vocabulary.dart';

class Phonetic {
  final String phonetic;
  final String? audioUrl;

  Phonetic(this.phonetic, this.audioUrl);
}

extension Phonetics on Vocabulary {
  Iterable<Phonetic> getPhonetics() => definitions.expand((d) sync* {
        final explain = d.explanations.map((e) => e.explain);
        final isExtra =
            explain.length == 1 && explain.first.split(' ').length == 1;
        if (d.phoneticUs != null && !isExtra)
          yield Phonetic(d.phoneticUs!, d.audioUs);
      });
}
