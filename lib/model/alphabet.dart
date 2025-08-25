import 'package:intl/intl.dart';

class AlphabetModel {
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
    } else if (dt < 172800) {
      info = 'yesterday';
    } else if (isInCurrentWeek(lastTimeStamp)) {
      info =
          'on ${DateFormat.EEEE().format(DateTime.fromMillisecondsSinceEpoch(lastTimeStamp))}';
    } else if (dt < 2419200) {
      info =
          'on ${DateFormat('EEEE, d').format(DateTime.fromMillisecondsSinceEpoch(lastTimeStamp))}';
    } else if (dt < 31536000) {
      info =
          'at ${DateFormat('M/d').format(DateTime.fromMillisecondsSinceEpoch(lastTimeStamp))}';
    } else {
      info =
          'at ${DateFormat('y/M/d').format(DateTime.fromMillisecondsSinceEpoch(lastTimeStamp))}';
    }
    return 'last chat $info';
  }
}

bool isInCurrentWeek(int timestamp) {
  // 1. 获取当前时间
  final now = DateTime.now();

  // 2. 转换 Unix 时间戳为 DateTime
  final targetDate = DateTime.fromMillisecondsSinceEpoch(timestamp);

  // 3. 计算当前星期的开始日期（星期天）
  final startOfWeek = now.subtract(Duration(days: now.weekday % 7)).toLocal();
  // 星期天到星期六，`now.weekday % 7` 处理当周第一天

  // 4. 计算当前星期的结束日期（星期六 23:59:59.999）
  final endOfWeek = startOfWeek.add(
    const Duration(
      days: 6,
      hours: 23,
      minutes: 59,
      seconds: 59,
      milliseconds: 999,
    ),
  );

  // 5. 判断目标日期是否在当前星期内
  return targetDate.isAfter(startOfWeek) && targetDate.isBefore(endOfWeek);
}
