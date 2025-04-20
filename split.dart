void main() {
  // 测试字符串
  String original = "alcohol、inebriant、intoxicant、liquor、moonshine、spirits";
  print("Original sentence: $original");
  // 使用正则表达式拆分字符串，将标点符号和空格与单词分开
  // List<String> wordsList =
  //     original
  //         .split(
  //           RegExp(r"(?=\s+|[,.!?=\[\]\(\)\/])|(?<=\s+|[,.!?=\[\]\(\)\/])"),
  //         )
  //         .expand((word) sync* {
  //           final match = RegExp(
  //             r"(\w+)?('s|'re|'d|'ve|'m|'ll)",
  //           ).firstMatch(word);
  //           if (match != null) {
  //             for (final m in match.groups([1, 2])) yield m ?? '';
  //           } else {
  //             yield word;
  //           }
  //         })
  //         .where((e) => e.isNotEmpty)
  //         .toList();
  final wordsList = splitWords(original);

  print('分割后的单词和标点符号列表: $wordsList');
  final onlyWords = wordsList.expand((e) sync* {
    if (!e.contains(RegExp(r'(?=\s+|[,.!?=\[\]\(\)\/])|(?<=[^\x00-\x7F])')) &&
        !e.contains(RegExp(r"('s|'re|'d|'ve|'m|'ll|^[-|+]?\d+)")))
      yield e;
  });
  print('Only words list: ${onlyWords.toList()}');
}

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
