import 'package:flutter/cupertino.dart';
import 'package:im_charts/im_charts.dart';

import '../database/my_db.dart';
import '../utils/function.dart';

class RememberRetention extends StatelessWidget {
  const RememberRetention({
    super.key,
    required this.wordID,
  });

  final int wordID;

  @override
  Widget build(BuildContext context) {
    final acquaintance = MyDB().getAcquaintance(wordID);
    final acquaint = acquaintance.acquaint;
    final lastLearnedTime = acquaintance.lastLearnedTime;
    var percentage = 0.0;
    if (acquaint > 0 && lastLearnedTime != null) {
      final fib = Fibonacci().sequence(acquaint);
      final inMinute =
          DateTime.now().millisecondsSinceEpoch ~/ 6e4 - lastLearnedTime;
      percentage = forgettingCurve(inMinute / 1440, fib.toDouble());
    }

    return ImPieChart(percentage: percentage);
  }
}
