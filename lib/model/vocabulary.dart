import 'dart:convert';
import 'dart:math';
part 'phonetic.dart';

class Vocabulary {
  final int wordId;
  final String word;
  final List<Definition> definitions;
  final String? asset;

  Vocabulary({
    required this.wordId,
    required this.word,
    required this.definitions,
    this.asset,
  });

  Iterable<String> get getInflection => definitions
          .map((d) => (d.inflection ?? '').split(', '))
          .reduce((d1, d2) => d1 + d2)
          .expand((d) sync* {
        if (d.isNotEmpty) yield d;
      }).toSet();

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

  int differ(String queryWord) => word.diff(queryWord);

  factory Vocabulary.fromRawJson(String str) =>
      Vocabulary.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Vocabulary.fromJson(Map<String, dynamic> json) => Vocabulary(
        wordId: json["word_id"],
        word: json["word"],
        asset: json["asset"],
        definitions: List<Definition>.from(
            json["definitions"].map((x) => Definition.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "word_id": wordId,
        "word": word,
        "asset": asset,
        "definitions": List<dynamic>.from(definitions.map((x) => x.toJson())),
      };
}

class Definition {
  final String partOfSpeech;
  final List<Explanation> explanations;
  final String? inflection;
  final String? phoneticUk;
  final String? phoneticUs;
  final String? audioUk;
  final String? audioUs;
  final String? translate;

  Definition({
    required this.partOfSpeech,
    required this.explanations,
    this.inflection,
    this.phoneticUk,
    this.phoneticUs,
    this.audioUk,
    this.audioUs,
    this.translate,
  });

  String index2Explanation() {
    final explanationStrs = [];
    for (int i = 0; i < explanations.length; i++) {
      explanationStrs.add("${i + 1}. ${explanations[i].explain}");
    }
    return explanationStrs.join('\n');
  }

  factory Definition.fromRawJson(String str) =>
      Definition.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Definition.fromJson(Map<String, dynamic> json) => Definition(
        partOfSpeech: json["part_of_speech"],
        explanations: List<Explanation>.from(
            json["explanations"].map((x) => Explanation.fromJson(x))),
        inflection: json["inflection"],
        phoneticUk: json["phonetic_uk"],
        phoneticUs: json["phonetic_us"],
        audioUk: json["audio_uk"],
        audioUs: json["audio_us"],
        translate: json["translate"],
      );

  Map<String, dynamic> toJson() => {
        "part_of_speech": partOfSpeech,
        "explanations": List<dynamic>.from(explanations.map((x) => x.toJson())),
        "inflection": inflection,
        "phonetic_uk": phoneticUk,
        "phonetic_us": phoneticUs,
        "audio_uk": audioUk,
        "audio_us": audioUs,
        "translate": translate,
      };
}

class Explanation {
  final String explain;
  final String? subscript;
  final List<String> examples;

  Explanation({
    required this.explain,
    this.subscript,
    required this.examples,
  });

  factory Explanation.fromRawJson(String str) =>
      Explanation.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Explanation.fromJson(Map<String, dynamic> json) => Explanation(
        explain: json["explain"],
        subscript: json["subscript"],
        examples: List<String>.from(json["examples"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "explain": explain,
        "subscript": subscript,
        "examples": List<dynamic>.from(examples.map((x) => x)),
      };
}

extension _Differential on String {
  int diff(String other) {
    if (isEmpty || other.isEmpty) return max(length, other.length);
    final dS = substring(1).diff(other.substring(1));
    return dS + (this[0] == other[0] ? 0 : 1);
  }
}
