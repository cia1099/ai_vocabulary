import 'dart:async';

import 'package:ai_vocabulary/app_settings.dart';
import 'package:ai_vocabulary/database/my_db.dart';
import 'package:flutter/material.dart';

import '../model/acquaintance.dart';

class StudyBoard extends StatefulWidget {
  const StudyBoard({
    super.key,
  });

  @override
  State<StudyBoard> createState() => _StudyBoardState();
}

class _StudyBoardState extends State<StudyBoard> with WidgetsBindingObserver {
  final elapsedMinute = ValueNotifier(0);
  Timer? timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    timer = _startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hPadding = MediaQuery.sizeOf(context).width / 32;
    return Container(
      height: 100,
      margin: EdgeInsets.only(top: hPadding, left: hPadding, right: hPadding),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: .8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ValueListenableBuilder(
        valueListenable: AppSettings.of(context).targetStudy,
        builder: (context, targetStudy, _) => ListenableBuilder(
          listenable: MyDB(),
          builder: (context, child) => FutureBuilder(
            future: MyDB().isReady,
            builder: (context, snapshot) {
              final studyCount = snapshot.data == true
                  ? MyDB().fetchStudyCounts()
                  : StudyCount();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Review today"),
                      Text(
                          '${studyCount.reviewCount}/${targetStudy.reviewCount}',
                          style: textTheme.headlineSmall),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("New today"),
                      Text('${studyCount.newCount}/${targetStudy.newCount}',
                          style: textTheme.headlineSmall),
                    ],
                  ),
                  child!
                ],
              );
            },
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Learning today"),
              ValueListenableBuilder(
                valueListenable: elapsedMinute,
                builder: (context, value, _) {
                  final hour = value ~/ 60;
                  final elapsedHour = hour > 0 ? '${hour}h' : '';
                  return Text('$elapsedHour${value % 60}min',
                      style: textTheme.headlineSmall);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      timer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      if (timer?.isActive == false || timer == null) {
        timer = _startTimer();
      }
    }
  }

  Timer _startTimer() => Timer.periodic(Durations.extralong4 * 60, (timer) {
        if ((elapsedMinute.value + 1) >= 1440) {
          elapsedMinute.value = 0;
          timer.cancel();
        } else {
          elapsedMinute.value++;
        }
      });
}
