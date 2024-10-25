import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:im_charts/im_charts.dart';

class ChartTab extends StatelessWidget {
  const ChartTab({super.key});

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height -
        kToolbarHeight -
        kBottomNavigationBarHeight;
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      child: Container(
        color: CupertinoColors.systemGrey5,
        height: maxHeight,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 8),
              child: ImLineChart(
                statisticTime: StatisticTime.hour,
                playAnimation: true,
                xData: List.generate(256, (index) => createTodayTime()),
                yData: List.generate(256, (index) => createProfit()),
                pointAtLine: (t, y) {
                  debugPrint('what time is the value?\nt=$t\nvalue=$y');
                },
              ),
            ),
            AspectRatio(
              aspectRatio: 1.5,
              child: ImBarChart(
                barData: List.generate(10, (index) => createProfit()),
                barLabel: [
                  'PC28' * 50,
                  '一分快三',
                  '香港六合彩',
                  '龙虎',
                  '三公',
                  '快车',
                  '鱼虾蟹',
                  '百人牛牛',
                  '轮盘',
                  '百家乐'
                ],
              ),
            ),
            AspectRatio(
              aspectRatio: 3,
              child: ImPieChart(
                percentage: .25,
              ),
            ),
            Container(
              color: CupertinoColors.systemGrey,
              height: 34,
            ),
          ],
        ),
      ),
    );
  }
}
