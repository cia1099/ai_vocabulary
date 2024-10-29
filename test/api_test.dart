import 'dart:convert';

import 'package:ai_vocabulary/api/dict_api.dart';
import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // group("Dictionary API test in client", () {
  test('Get Maximum Id of word', () async {
    final res = await getMaxId();
    expect(res.status, 200);
    final maxId = int.tryParse(res.content);
    expect(maxId, greaterThanOrEqualTo(16852));
  });
  test('retrieval word API', () async {
    final res = await retrievalWord('apple');
    expect(res.status, 200);
    final words = List<Vocabulary>.from(
        json.decode(res.content).map((json) => Vocabulary.fromJson(json)));
    expect(words.first.word, 'apple');
  });
  test('Get words by Ids', () async {
    final res = await getWords([830, 30]);
    expect(res.status, 200);
    final words = List<Vocabulary>.from(
        json.decode(res.content).map((json) => Vocabulary.fromJson(json)));
    expect(words.length, greaterThan(1));
  });
  test('Get words by a Id', () async {
    const wordId = 830;
    final res = await getWordById(wordId);
    expect(res.status, 200);
    final word = Vocabulary.fromRawJson(res.content);
    expect(word.wordId, wordId);
  });
  test('Test failure case by Id', () async {
    var res = await getMaxId();
    final maxId = int.tryParse(res.content);
    expect(maxId, isNotNull, reason: 'Guarantee max Id exist');
    res = await getWords([maxId! + 1]);
    expect(res.status, 404);
  });
  // });
}
