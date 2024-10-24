void main() {
  // 测试字符串
  String original =
      "Hello, world! 1000 This's a(=shit man)? 去你妈 -1.2 who've +10 you're I'd [hello count]test.";
  print("Original sentence: $original");
  // 使用正则表达式拆分字符串，将标点符号和空格与单词分开
  List<String> wordsList = original
      .split(RegExp(r"(?=\s+|[,.!?=\[\]\(\)\/])|(?<=\s+|[,.!?=\[\]\(\)\/])"))
      .expand((word) sync* {
        final match = RegExp(r"(\w+)?('s|'re|'d|'ve|'m|'ll)").firstMatch(word);
        if (match != null) {
          for (final m in match.groups([1, 2])) yield m ?? '';
        } else {
          yield word;
        }
      })
      .where((e) => e.isNotEmpty)
      .toList();

  print('分割后的单词和标点符号列表: $wordsList');
  final onlyWords = wordsList.expand((e) sync* {
    if (!e.contains(RegExp(r'(?=\s+|[,.!?=\[\]\(\)\/])|(?<=[^\x00-\x7F])')) &&
        !e.contains(RegExp(r"('s|'re|'d|'ve|'m|'ll|^[-|+]?\d+)"))) yield e;
  });
  print('Only words list: ${onlyWords.toList()}');

  // 重新组合为原来的句子
  // String restoredString = wordsList.join('');
  // 去除因为join导致的额外空格
  // restoredString = restoredString.replaceAll(RegExp(r'\s+([,.!?])'), r'\1');

  // print('还原后的字符串: $restoredString');
}
