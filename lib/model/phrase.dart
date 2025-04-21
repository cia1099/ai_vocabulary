import 'dart:convert' show json;
import 'vocabulary.dart' show Definition;

class Phrase {
  final String phrase;
  final double? frequency;
  final List<Definition> definitions;

  Phrase({required this.phrase, required this.definitions, this.frequency});
  factory Phrase.fromRawJson(String str) => Phrase.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Phrase.fromJson(Map<String, dynamic> json) => Phrase(
    phrase: json["phrase"],
    frequency: json["frequency"],
    definitions: List<Definition>.from(
      json["definitions"].map((x) => Definition.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "phrase": phrase,
    "frequency": frequency,
    "definitions": List<dynamic>.from(definitions.map((x) => x.toJson())),
  };

  Iterable<String> getMatchingPatterns() =>
      definitions
          .map((d) => (d.inflection ?? '').split(', '))
          .reduce((d1, d2) => d1 + d2)
          .where((d) => d.isNotEmpty)
          .toSet()
        ..addAll(Set.from(phrase.split(' ')));
}
