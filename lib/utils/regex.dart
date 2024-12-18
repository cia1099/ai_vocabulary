Iterable<String> splitWords(String text) {
  return text
      .split(RegExp(r'(?=\s+|[,.!?"=\[\]\(\)\/])|(?<=\s+|[,.!?"=\[\]\(\)\/])'))
      .expand((word) sync* {
    final match = RegExp(r"(\w+)?('s|'re|'d|'ve|'m|'ll)").firstMatch(word);
    if (match != null) {
      for (final m in match.groups([1, 2])) yield m ?? '';
    } else {
      yield word;
    }
  }).where((w) => w.isNotEmpty);
}

extension SlidingWindow on String {
  int matchFirstIndex(String pattern) {
    if (pattern.isEmpty || length < pattern.length) return -1;
    var i = 0;
    for (; i < length - pattern.length + 1; i++) {
      if (this[i] == pattern[0]) {
        var ii = i + 1;
        for (int j = 1; j < pattern.length; j++) {
          if (this[ii] == pattern[ii - i])
            ii++;
          else
            break;
        }
        if (ii - i == pattern.length)
          return i;
        else
          i = ii + 1;
      }
    }
    return -1;
  }
}
