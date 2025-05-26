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

  Future<String> requireSpeechAndTranslation(TranslateLocate locate) async {
    if (locate == TranslateLocate.none) return getSpeechAndSynonyms;
    final futures = definitions.map(
      (d) => definitionTranslation(
        d.id,
        locate,
      ).then((translate) => speechShortcut(d.partOfSpeech) + translate),
    );
    try {
      final fd = await Future.wait(futures);
      return fd.join('/ ');
    } on ApiException catch (_) {
      return getSpeechAndSynonyms;
    }
  }

  int differ(String queryWord) => word.diff(queryWord);

  Iterable<Phonetic> getPhonetics([Accent accent = Accent.US]) =>
      definitions.expand((d) sync* {
        final explain = d.explanations.map((e) => e.explain);
        final isExtra =
            explain.length == 1 && explain.first.split(' ').length == 1;
        if (accent == Accent.US && d.phoneticUs != null && !isExtra) {
          yield Phonetic(d.phoneticUs!, d.audioUs);
        } else if (d.phoneticUk != null && !isExtra) {
          yield Phonetic(d.phoneticUk!, d.audioUs);
        }
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

extension DefinitionExtension on Definition {
  bool hasExample() => explanations.any((e) => e.examples.isNotEmpty);

  String index2Explanation() {
    final explanationStrs = [];
    for (int i = 0; i < explanations.length; i++) {
      explanationStrs.add("${i + 1}. ${explanations[i].explain}");
    }
    return explanationStrs.join('\n');
  }
}

class Phonetic {
  final String phonetic;
  final String? audioUrl;

  Phonetic(this.phonetic, this.audioUrl);
}

class Syllable {
  final String grapheme;
  final double score;

  Syllable(this.grapheme, this.score);
  factory Syllable.fromRawJson(String json) =>
      Syllable.fromJson(jsonDecode(json));
  String toRawJson() => jsonEncode(toJson());

  factory Syllable.fromJson(Map<String, dynamic> json) {
    return Syllable(json['grapheme'], json['score']);
  }
  Map<String, dynamic> toJson() => {'grapheme': grapheme, 'score': score};
}
