import 'package:ai_vocabulary/api/dict_api.dart';
import 'package:ai_vocabulary/firebase/authorization.dart';
import 'package:ai_vocabulary/provider/user_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'firebase_helper.dart';

void main() {
  /// NOTE! execute integration test will delete app in device!
  //cmd flutter test -d iPhone\ 16 -x direct_api integration_test/api_test.dart
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group("Dictionary API test by client", () {
    final tester = UserProvider();
    setUpAll(() async {
      tester.currentUser = await testerWithFirebase();
    });
    tearDownAll(() {
      signOutFirebase();
      debugPrint("Access token = ${tester.currentUser?.accessToken}");
    });
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
    test('search word API', () async {
      final words = await searchWord(word: 'apple');
      // printOnFailure(words.map((w) => w.word).join(', '));
      expect(words.length, greaterThanOrEqualTo(1));
      expect(words.map((w) => w.word), contains('apple'));
    }, tags: 'direct_api');
    test('Test failure case by Id', () async {
      // debugPrint("We have user ${user.toRawJson()}");
      final maxId = await getMaxId();
      expect(maxId, greaterThan(0), reason: 'Guarantee max Id exist');
      expect(
        () async => await getWordById(maxId + 1),
        throwsA(isA<ApiException>()),
      );
      expect(
        () async => await getWords([maxId + 1]),
        throwsA(isA<ApiException>()),
      );
    }, tags: 'except_api');
  });
}
