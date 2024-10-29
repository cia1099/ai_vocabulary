import 'package:ai_vocabulary/api/dict_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // group("Dictionary API test by client", () {
  test('Get Maximum Id of word', () async {
    final maxId = await getMaxId();
    expect(maxId, greaterThanOrEqualTo(16852));
  }, tags: 'direct_api');
  test('retrieval word API', () async {
    final words = await retrievalWord('apple');
    expect(words.first.word, 'apple');
  }, tags: 'direct_api');
  test('Get words by Ids', () async {
    final words = await getWords([830, 30]);
    expect(words.length, greaterThan(1));
  }, tags: 'direct_api');
  test('Get words by a Id', () async {
    const wordId = 830;
    final word = await getWordById(wordId);
    expect(word.wordId, wordId);
  }, tags: 'direct_api');
  test('Test failure case by Id', () async {
    final maxId = await getMaxId();
    expect(maxId, greaterThan(0), reason: 'Guarantee max Id exist');
    expect(
        () async => await getWordById(maxId + 1), throwsA(isA<ApiException>()));
    expect(
        () async => await getWords([maxId + 1]), throwsA(isA<ApiException>()));
  }, tags: 'except_api');
  // }, skip: true);
}
