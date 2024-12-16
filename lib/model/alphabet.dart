import 'package:azlistview/azlistview.dart';
import 'package:intl/intl.dart';

import 'vocabulary.dart';

class AlphabetModel extends ISuspensionBean {
  final Vocabulary word;
  final int lastTimeStamp;

  AlphabetModel({required this.word, required this.lastTimeStamp});
  @override
  String getSuspensionTag() => word.word[0].toUpperCase();

  int get userId => word.wordId;
  String get name => word.word;
  String? get avatarUrl => word.asset;
  String get subtitle {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final dt = now - lastTimeStamp ~/ 1000;
    var info = '';
    if (dt < 60) {
      info = 'recently';
    } else if (dt < 3600) {
      info = '${dt ~/ 60} minutes ago';
    } else if (dt < 86400) {
      info = '${dt ~/ 3600} hour ago';
    } else if (dt < 31536000) {
      info =
          'at ${DateFormat.MMMMd().format(DateTime.fromMillisecondsSinceEpoch(lastTimeStamp))}';
    } else {
      info =
          'at ${DateFormat('y/MM/dd').format(DateTime.fromMillisecondsSinceEpoch(lastTimeStamp))}';
    }
    return 'last chat $info';
  }
}
