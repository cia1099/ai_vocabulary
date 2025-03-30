import 'package:ai_vocabulary/model/acquaintance.dart';
import 'package:flutter/material.dart';
import 'package:im_charts/im_charts.dart';
import 'package:intl/intl.dart';

import '../utils/function.dart';

class RememberRetention extends StatelessWidget {
  const RememberRetention({super.key, this.acquaintance});

  final Acquaintance? acquaintance;

  @override
  Widget build(BuildContext context) {
    final acquaint = acquaintance?.acquaint ?? 0;
    final lastLearnedTime = acquaintance?.lastLearnedTime;
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

class LearnedLabel extends StatelessWidget {
  const LearnedLabel({super.key, this.lastLearnedTime});
  final int? lastLearnedTime;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Offstage(
      offstage: lastLearnedTime == null,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          // color: Colors.yellow,
          border: Border.all(color: colorScheme.onSurface),
        ),
        child: Text("${title(lastLearnedTime)}", maxLines: 1),
      ),
    );
  }

  String? title(int? lastLearnedTime) {
    String? info;
    if (lastLearnedTime == null) return info;
    final now = DateTime.now();
    final dt = now.millisecondsSinceEpoch ~/ 6e4 - lastLearnedTime;

    if (dt < 60 * 4) {
      info = 'recently';
    } else if (dt < 1440) {
      info = '${dt ~/ 60} hours ago';
    } else if (dt < 2880) {
      info = 'yesterday';
    } else if (dt < 43200) {
      info = '${dt ~/ 1440} days ago';
    } else if (dt < 518400) {
      info = '${dt ~/ 43200} month ago';
    } else {
      info =
          'at ${DateFormat('y/M/d').format(DateTime.fromMillisecondsSinceEpoch(lastLearnedTime * 6e4.toInt()))}';
    }
    return 'Learned $info';
  }
}
