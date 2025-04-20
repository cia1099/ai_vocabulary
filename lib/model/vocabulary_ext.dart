part of 'vocabulary.dart';

extension VocabularyExtension on Vocabulary {
  Iterable<String> get getInflection =>
      definitions
          .map((d) => (d.inflection ?? '').split(', '))
          .reduce((d1, d2) => d1 + d2)
          .expand((d) sync* {
            if (d.isNotEmpty) yield d;
          })
          .toSet();

  Iterable<String> get getMatchingPatterns {
    final selfExplainWord = definitions
        .map((d) => d.explanations)
        .reduce((e1, e2) => e1 + e2)
        .map((e) => e.explain)
        .expand((e) sync* {
          final explainWord = e.split(' ');
          if (explainWord.length == 1) yield explainWord[0];
        });
    return Set.from(getInflection)
      ..add(word)
      ..addAll(selfExplainWord);
  }

  Iterable<String> get getExamples => definitions
      .map((d) => d.explanations)
      .reduce((e1, e2) => e1 + e2)
      .map((e) => e.examples)
      .reduce((e1, e2) => e1 + e2);

  String get getSpeechAndTranslation => definitions
      .map((d) => speechShortcut(d.partOfSpeech) + (d.translate ?? ''))
      .join('/ '); //(String.fromCharCode(0x2227));

  String get getSpeechAndSynonyms => definitions
      .map((d) => speechShortcut(d.partOfSpeech) + (d.synonyms ?? ''))
      .join('/ ');

  int differ(String queryWord) => word.diff(queryWord);

  Iterable<Phonetic> getPhonetics() => definitions.expand((d) sync* {
    final explain = d.explanations.map((e) => e.explain);
    final isExtra = explain.length == 1 && explain.first.split(' ').length == 1;
    if (d.phoneticUs != null && !isExtra)
      yield Phonetic(d.phoneticUs!, d.audioUs);
  });

  MapEntry<String, String> generateClozeEntry([int? seed]) {
    final rng = Random(seed);
    var idx = rng.nextInt(definitions.length);
    var example = '', explain = '';
    final definition = definitions[idx];
    idx = rng.nextInt(definition.explanations.length);
    final explanation = definition.explanations[idx];
    explain = explanation.explain;
    if (explanation.examples.isEmpty) {
      example = explain.split(' ').length > 1 ? word : explain;
    } else {
      idx = rng.nextInt(explanation.examples.length);
      example = explanation.examples[idx];
    }
    return MapEntry(explain, example);
  }
}

class Phonetic {
  final String phonetic;
  final String? audioUrl;

  Phonetic(this.phonetic, this.audioUrl);
}
