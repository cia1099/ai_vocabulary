import 'package:flutter/painting.dart';

Iterable<String> splitWords(String text) {
  return text
      .split(
        RegExp(r'(?=\s+|[,.!?、"=\[\]\(\)\/])|(?<=\s+|[,.!?、"=\[\]\(\)\/])'),
      )
      .expand((word) sync* {
        final match = RegExp(r"(\w+)?('s|'re|'d|'ve|'m|'ll)").firstMatch(word);
        if (match != null) {
          for (final m in match.groups([1, 2])) yield m ?? '';
        } else {
          yield word;
        }
      })
      .where((w) => w.isNotEmpty);
}

String replacePlaceholders(String query, List<dynamic> values) {
  int index = 0;
  return query.replaceAllMapped(RegExp(r'\?'), (match) {
    final value = values[index++];
    if (value is String) {
      return "'${value.replaceAll("'", "''")}'";
    } else {
      return value.toString();
    }
  });
}

extension SlidingWindow on String {
  Iterable<int> matchIndexes(String pattern) {
    final indexes = <int>[];
    var idx = 0;
    while (idx < length - pattern.length + 1 && idx > -1) {
      final i = substring(idx)._matchFirstIndex(pattern);
      if (i > -1) {
        indexes.addAll(Iterable.generate(pattern.length, (j) => idx + j + i));
        idx += pattern.length + i;
      } else {
        idx = i;
      }
    }
    return indexes;
  }

  int _matchFirstIndex(String pattern) {
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

extension BinarySearch on TextPainter {
  int overflowIndex(double maxWidth) {
    layout(maxWidth: maxWidth);
    if (!didExceedMaxLines) return -1;
    final span = text as TextSpan;
    final str = span.text!;
    int start = 0, end = str.length;
    while (start < end) {
      final mid = (start + end) >> 1;
      text = TextSpan(text: str.substring(0, mid), style: span.style);
      layout(maxWidth: maxWidth);
      if (didExceedMaxLines) {
        end = mid;
      } else {
        start = mid + 1;
      }
    }
    return start - 1;
  }
}
