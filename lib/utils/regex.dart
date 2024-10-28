Iterable<String> splitWords(String text) {
  return text
      .split(RegExp(r'(?=\s+|[,.!?=\[\]\(\)\/])|(?<=\s+|[,.!?=\[\]\(\)\/])'))
      .expand((word) sync* {
    final match = RegExp(r"(\w+)?('s|'re|'d|'ve|'m|'ll)").firstMatch(word);
    if (match != null) {
      for (final m in match.groups([1, 2])) yield m ?? '';
    } else {
      yield word;
    }
  }).where((w) => w.isNotEmpty);
}
