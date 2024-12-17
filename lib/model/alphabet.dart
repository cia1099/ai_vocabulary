import 'package:azlistview/azlistview.dart';
import 'package:intl/intl.dart';

class AlphabetModel extends ISuspensionBean {
  final int id;
  final String name;
  final int lastTimeStamp;
  final String? avatarUrl;

  AlphabetModel({
    required this.id,
    required this.name,
    required this.lastTimeStamp,
    this.avatarUrl,
  });
  @override
  String getSuspensionTag() => name.substring(0, 1).toUpperCase();

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
