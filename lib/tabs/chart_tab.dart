import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:ai_vocabulary/widgets/punch_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:im_charts/im_charts.dart';

class ChartTab extends StatelessWidget {
  const ChartTab({super.key});

  @override
  Widget build(BuildContext context) {
    // final maxHeight = MediaQuery.of(context).size.height -
    //     kToolbarHeight -
    //     kBottomNavigationBarHeight;
    return PlatformScaffold(
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          PlatformSliverAppBar(
            stretch: true,
            cupertino:
                (_, __) => CupertinoSliverAppBarData(
                  transitionBetweenRoutes: false,
                  title: const Text('Charts'),
                ),
            material:
                (_, _) => MaterialSliverAppBarData(
                  pinned: true,
                  expandedHeight: kExpandedSliverAppBarHeight,
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text('Charts'),
                    titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                    stretchModes: const [
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground,
                      StretchMode.fadeTitle,
                    ],
                    background: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ),
                ),
          ),
          const SliverToBoxAdapter(child: PunchCalendar()),
          SliverToBoxAdapter(
            child: FutureBuilder(
              future: MyDB().averageFibonacci,
              builder:
                  (context, snapshot) => Stack(
                    alignment: const Alignment(0, -.25),
                    children: [
                      RememberChart(trainingRate: snapshot.data),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const CircularProgressIndicator.adaptive(),
                    ],
                  ),
            ),
          ),
          // SliverToBoxAdapter(
          //   child: AspectRatio(
          //     aspectRatio: 1.5,
          //     child: ImBarChart(
          //       barData: List.generate(10, (index) => createProfit()),
          //       barLabel: [
          //         'PC28' * 50,
          //         '一分快三',
          //         '香港六合彩',
          //         '龙虎',
          //         '三公',
          //         '快车',
          //         '鱼虾蟹',
          //         '百人牛牛',
          //         '轮盘',
          //         '百家乐'
          //       ],
          //     ),
          //   ),
          // ),
          const SliverToBoxAdapter(
            child: AspectRatio(
              aspectRatio: 3,
              child: ImPieChart(percentage: .7),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: CupertinoColors.systemGrey.resolveFrom(context),
              height: 34,
            ),
          ),
        ],
      ),
    );
  }
}
