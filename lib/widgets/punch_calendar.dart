import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';

import '../database/my_db.dart';
import '../model/punch_day.dart';
import '../pages/word_list_page.dart';
import 'calendar.dart';

class PunchCalendar extends StatefulWidget {
  const PunchCalendar({super.key});

  @override
  State<PunchCalendar> createState() => _PunchCalendarState();
}

class _PunchCalendarState extends State<PunchCalendar>
    implements CalendarDelegate {
  var punchDays = <PunchDay>[];
  late final dbReady = MyDB().isReady.then((value) {
    if (value) {
      final now = DateTime.now();
      punchDays = MyDB().fetchPunchesInThisMonth(now.year, now.month);
    }
    return value;
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: dbReady,
      builder: (context, snapshot) {
        if (snapshot.data != true) {
          return const CircularProgressIndicator.adaptive();
        }
        return Calendar(delegate: this);
      },
    );
  }

  @override
  Widget dateItemBuilder(int day, int inSecondStamp, double maxHeight) {
    final index = punchDays.indexWhere((punch) => punch.date == inSecondStamp);
    final colorScheme = Theme.of(context).colorScheme;
    final style =
        index < 0
            ? null
            : TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            );
    final isToday =
        DateTime.now().millisecondsSinceEpoch ~/ (3600e3 * 24) ==
        inSecondStamp ~/ (3600 * 24);
    return GestureDetector(
      onTap: onTapCallBack(index),
      child: Column(
        children: [
          isToday
              ? CircleAvatar(maxRadius: maxHeight / 3.2, child: Text('$day'))
              : Text(day.toString(), style: style),
          if (index > -1)
            PlatformWidget(
              cupertino:
                  (_, __) => Icon(
                    CupertinoIcons.checkmark_alt,
                    size: maxHeight / 2.1,
                    color: CupertinoColors.systemGreen.resolveFrom(context),
                  ),
              material:
                  (_, __) => Icon(
                    Icons.file_download_done,
                    size: maxHeight / 2.1,
                    color: Colors.green,
                  ),
            ),
        ],
      ),
    );
  }

  VoidCallback? onTapCallBack(int index) {
    if (index < 0) return null;
    return () {
      final punchDay = punchDays[index];
      final words = MyDB().fetchWords(punchDay.studyWordIDs);
      Navigator.push(
        context,
        platformPageRoute(
          context: context,
          builder:
              (context) => WordListPage(
                words: words,
                title:
                    "Studied on ${DateFormat.MEd().format(DateTime.fromMillisecondsSinceEpoch(punchDay.date * 1000))}",
              ),
        ),
      );
    };
  }

  @override
  void onMonthChanged(DateTime date) {
    setState(() {
      punchDays = MyDB().fetchPunchesInThisMonth(date.year, date.month);
    });
  }
}
