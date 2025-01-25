import 'package:ai_vocabulary/pages/collection_page.dart';
import 'package:ai_vocabulary/pages/slider_page.dart';
import 'package:ai_vocabulary/provider/slider_provider.dart';
import 'package:ai_vocabulary/provider/word_provider.dart';
import 'package:ai_vocabulary/app_route.dart';
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class VocabularyTab extends StatefulWidget {
  final void Function(int index)? onTabChanged;
  const VocabularyTab({
    super.key,
    this.onTabChanged,
  });

  @override
  State<VocabularyTab> createState() => _VocabularyTabState();
}

class _VocabularyTabState extends State<VocabularyTab>
    with SingleTickerProviderStateMixin {
  final pageController = PageController(initialPage: 1);
  late final tabController =
      TabController(initialIndex: 1, length: 2, vsync: this);
  final recommend = SliderProvider(pageController: PageController());

  @override
  Widget build(BuildContext context) {
    // return oldDesign(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final hPadding = MediaQuery.of(context).size.width / 32;
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: TabBar(
            controller: tabController,
            tabAlignment: TabAlignment.center,
            dividerColor: const Color(0x00000000),
            tabs: const [Tab(text: 'Review'), Tab(text: 'Recommend')]),
        backgroundColor: kCupertinoSheetColor.resolveFrom(context),
        cupertino: (_, __) =>
            CupertinoNavigationBarData(transitionBetweenRoutes: false),
      ),
      body: SafeArea(
        child: Listener(
          onPointerMove: (event) {
            final dx = event.delta.dx;
            final x = pageController.position.pixels;
            final shift = x - dx;
            if (shift < x || tabController.index == 0) {
              pageController.jumpTo(shift);
            }
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: PageView.builder(
                  // key: PageStorageKey(pageController),
                  controller: pageController,
                  onPageChanged: (value) {
                    tabController.animateTo(value);
                    widget.onTabChanged?.call((value + 1) & 1);
                  },
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) => index.isEven
                      ? const Center(
                          child: Text(
                            'Review tab view',
                            textScaler: TextScaler.linear(2.5),
                          ),
                        )
                      : FutureBuilder(
                          future: recommend.initial(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: SpinKitFadingCircle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                ),
                              );
                            }
                            return PageView.builder(
                              scrollDirection: Axis.vertical,
                              findChildIndexCallback: (key) =>
                                  (key as ValueKey).value,
                              controller: recommend.pageController,
                              onPageChanged: (index) {
                                recommend.currentWord =
                                    recommend[index % recommend.length];
                                recommend
                                    .fetchStudyWords(index)
                                    .whenComplete(() {
                                  print(
                                      'recommend = ${recommend.map((e) => e.wordId).join(', ')}');
                                });
                                // if (index > recommend.length) {
                                //   recommend.pageController
                                //       ?.jumpToPage(index - recommend.length);
                                // }
                              },
                              itemBuilder: (context, index) {
                                final i = index % recommend.length;
                                final word = recommend[i];
                                return SliderPage(
                                    key: ValueKey(index), word: word);
                              },
                            );
                          },
                        ),
                  itemCount: tabController.length,
                ),
              ),
              Align(
                alignment: const Alignment(0, -1),
                child: Container(
                  height: 100,
                  margin: EdgeInsets.only(
                      top: hPadding, left: hPadding, right: hPadding),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer.withValues(alpha: .8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Review today"),
                          Text(WordProvider().reviewProgress,
                              style: textTheme.headlineSmall),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("New today"),
                          Text(WordProvider().studyProgress,
                              style: textTheme.headlineSmall),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Learning today"),
                          Text('0min', style: textTheme.headlineSmall),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    tabController.addListener(() {
      pageController.animateToPage(tabController.index,
          duration: Durations.short4, curve: Curves.ease);
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Widget oldDesign(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height -
        kToolbarHeight -
        kBottomNavigationBarHeight;
    final hPadding = MediaQuery.of(context).size.width / 32;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Already checked days:', style: textTheme.titleLarge),
        Text('255', style: textTheme.headlineMedium),
        Container(
          height: 150,
          alignment: Alignment.center,
          width: double.maxFinite,
          margin: EdgeInsets.symmetric(horizontal: hPadding),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(),
              color: Theme.of(context).colorScheme.surfaceBright),
          child: PlatformTextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoute.todayWords),
              child: const Text("Today's study")),
        ),
        MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: Container(
            // color: Colors.red,
            height: maxHeight / 4,
            padding: EdgeInsets.all(hPadding),
            child: GridView.count(
              primary: false,
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                Card.outlined(
                  child: StreamBuilder(
                      stream: WordProvider().provideWord,
                      builder: (context, snapshot) {
                        return AbsorbPointer(
                          absorbing: snapshot.data == null,
                          child: InkWell(
                            onTap: () =>
                                Navigator.of(context).pushNamed(AppRoute.entry),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.square_stack),
                                Text("study")
                              ],
                            ),
                          ),
                        );
                      }),
                ),
                Card.outlined(
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(platformPageRoute(
                        context: context,
                        builder: (context) => const CollectionPage())),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(CupertinoIcons.star), Text("favorite")],
                    ),
                  ),
                ),
                const Card.outlined(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(CupertinoIcons.hand_draw), Text("game")],
                  ),
                ),
                const Card.outlined(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.photo),
                      Text(
                        "guess picture",
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
