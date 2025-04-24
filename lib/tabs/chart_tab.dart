import 'package:ai_vocabulary/api/dict_api.dart';
import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/utils/function.dart';
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:ai_vocabulary/widgets/punch_calendar.dart';
import 'package:dotted_line/dotted_line.dart';
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
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
                    stretchModes: kStretchModes,
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
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 17),
              padding: EdgeInsets.symmetric(vertical: 1.5),
              decoration: BoxDecoration(
                border: Border.symmetric(
                  horizontal: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 6.5),
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${MyDB().getPastPunchDays()}',
                            style: TextStyle(
                              fontSize: textTheme.titleMedium?.fontSize.scale(
                                1.2,
                              ),
                              fontWeight: textTheme.titleMedium?.fontWeight,
                              color:
                                  isCupertino(context)
                                      ? CupertinoColors.activeGreen.resolveFrom(
                                        context,
                                      )
                                      : Colors.green,
                            ),
                          ),
                          Text('Punched days', style: textTheme.labelMedium),
                        ],
                      ),
                    ),
                    DottedLine(
                      direction: Axis.vertical,
                      lineLength: 40,
                      dashColor: colorScheme.outline,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${MyDB().fetchReviewWordIDs().length}',
                            style: TextStyle(
                              fontSize: textTheme.titleMedium?.fontSize.scale(
                                1.2,
                              ),
                              fontWeight: textTheme.titleMedium?.fontWeight,
                              color: colorScheme.primary,
                            ),
                          ),
                          Text(
                            'Words have learned',
                            style: textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Align(
              alignment: Alignment(-.75, 0),
              child: FutureBuilder(
                future: getConsumeTokens(),
                builder:
                    (context, snapshot) =>
                        snapshot.hasData
                            ? Text.rich(
                              TextSpan(
                                text: '• You still have ',
                                children: [
                                  TextSpan(
                                    text: '${snapshot.data}',
                                    style: TextStyle(
                                      color: colorScheme.onSecondaryContainer,
                                      backgroundColor:
                                          colorScheme.secondaryContainer,
                                    ),
                                  ),
                                  TextSpan(text: ' tokens left today.'),
                                ],
                              ),
                              style: textTheme.titleMedium,
                            )
                            : SizedBox.shrink(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              // color: CupertinoColors.systemGrey.resolveFrom(context),
              height: 34,
            ),
          ),
        ],
      ),
    );
  }
}
