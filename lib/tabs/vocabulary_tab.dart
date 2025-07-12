import 'dart:async' show Timer;
import 'dart:math';

import 'package:ai_vocabulary/api/dict_api.dart' show soundGTTs;
import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/effects/refreshed_scroller.dart';
import 'package:ai_vocabulary/pages/slider_page.dart';
import 'package:ai_vocabulary/provider/word_provider.dart';
import 'package:ai_vocabulary/utils/gesture_route_page.dart';
import 'package:ai_vocabulary/utils/handle_except.dart';
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:ai_vocabulary/widgets/entry_actions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../app_settings.dart';
import '../widgets/study_board.dart';

class VocabularyTab extends StatefulWidget {
  final void Function(int index)? onTabChanged;
  const VocabularyTab({super.key, this.onTabChanged});

  @override
  State<VocabularyTab> createState() => _VocabularyTabState();
}

class _VocabularyTabState extends State<VocabularyTab>
    with SingleTickerProviderStateMixin {
  final pageController = PageController(initialPage: 1);
  late final tabController = TabController(
    initialIndex: 1,
    length: 2,
    vsync: this,
  );
  late final recommend = RecommendProvider(context: context);
  final review = ReviewProvider();
  final rng = Random();
  final autoDelay = Durations.extralong4 * 2.25;
  Timer? autoSound;

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: TabBar(
          controller: tabController,
          tabAlignment: TabAlignment.center,
          dividerColor: const Color(0x00000000),
          tabs: const [
            Tab(text: 'Review'),
            Tab(text: 'Recommend'),
          ],
        ),
        trailingActions: const [EntryActions()],
        cupertino: (_, __) =>
            CupertinoNavigationBarData(transitionBetweenRoutes: false),
        material: (_, _) => MaterialAppBarData(centerTitle: true),
      ),
      body: SafeArea(
        bottom: false,
        child: Listener(
          onPointerMove: (event) {
            final dx = event.delta.dx;
            final x = pageController.position.pixels;
            final shift = x - dx;
            if (shift < x || tabController.index == 0) {
              pageController.jumpTo(shift);
            }
          },
          child: Column(
            children: [
              StudyBoard(),
              Expanded(
                child: PageView(
                  // key: PageStorageKey(pageController),
                  controller: pageController,
                  onPageChanged: (value) {
                    tabController.animateTo(value);
                    widget.onTabChanged?.call((value + 1) & 1);
                    final provider = value == 0 ? review : recommend;
                    AppSettings.of(context).wordProvider = provider;
                    if (provider.currentWord != null) {
                      newSound(provider.currentWord!.word);
                    }
                  },
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    RefreshedScroller(
                      controller: review.pageController,
                      // thresholdExtent: 150,
                      refresh: (atTop) async {
                        final hasError = !await review.isReady.onError(
                          (_, _) => false,
                        );
                        registerFunc() => hasError
                            ? setState(() {})
                            : MyDB().notifyListeners();
                        return (atTop
                                ? review.resetReviews
                                : review.fetchReviewWords)()
                            .whenComplete(registerFunc);
                      },
                      bottomAlignment: Alignment(0, .9),
                      child: sliders(provider: review),
                    ),
                    RefreshedScroller(
                      controller: recommend.pageController,
                      // thresholdExtent: 180,
                      refresh: (atTop) async {
                        final hasError = !await recommend.isReady.onError(
                          (_, _) => false,
                        );
                        void registerFunc() {
                          if (hasError && atTop) setState(() {});
                          if (atTop || hasError) return;
                          recommend.pageController.animateToPage(
                            0,
                            duration: Durations.long2,
                            curve: Curves.ease,
                          );
                        }

                        return recommend
                            .fetchStudyWords()
                            .whenComplete(registerFunc)
                            .then((_) => newSound(recommend.currentWord?.word));
                        // if (atTop) {
                        //   // return recommend.resetWords().whenComplete(
                        //   //   registerFunc,
                        //   // );
                        // }
                        // if (hasError) return;

                        // // return recommend.length < RecommendProvider.kMaxLength
                        // //     ? recommend.bottomRequest()
                        // //     : recommend.resetWords().whenComplete(
                        // //         () => recommend.pageController.animateToPage(
                        // //           0,
                        // //           duration: Durations.long2,
                        // //           curve: Curves.ease,
                        // //         ),
                        // //       );
                      },
                      bottomAlignment: Alignment(0, .9),
                      child: sliders(provider: recommend),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sliders({required WordProvider provider}) {
    return FutureBuilder(
      future: provider.isReady,
      builder: (context, snapshot) {
        final isDisplay = AppSettings.of(context).wordProvider == provider;
        return ListenableBuilder(
          listenable: MyDB(),
          builder: (context, child) => PageView.builder(
            // key: PageStorageKey(provider),
            findChildIndexCallback: (key) =>
                provider.indexWhere((w) => w.wordId == (key as ValueKey).value),
            scrollDirection: Axis.vertical,
            physics: AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            controller: provider.pageController,
            onPageChanged: (index) {
              provider.currentWord = provider[index];
              provider.clozeSeed = rng.nextInt(256);
              // if (provider is RecommendProvider) {
              //   // provider.oldFetchStudyWords(index).catchError((_) {});
              // }
              if (provider.currentWord != null && isDisplay) {
                newSound(provider.currentWord!.word);
              }
            },
            itemBuilder: (context, index) {
              final error = verifyProvider(snapshot, provider);
              if (error != null) return error;
              final i = index % provider.length;
              final word = provider[i];
              autoSound ??= Timer(
                autoDelay,
                () => soundGTTs(word.word, AppSettings.of(context).accent.gTTS),
              );
              final textTheme = CupertinoTheme.of(context).textTheme;
              return Stack(
                children: [
                  SliderPage(
                    key: ValueKey(word.wordId),
                    word: word,
                    autoSound: autoSound,
                  ),
                  if (provider is RecommendProvider &&
                      index == provider.length - 1)
                    Align(
                      alignment: Alignment(.1, .95),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.end,
                        spacing: 4,
                        children: [
                          Text(
                            "Next round",
                            style: textTheme.dateTimePickerTextStyle.apply(
                              color: textTheme.tabLabelTextStyle.color
                                  ?.withAlpha(180),
                            ),
                            textScaler: TextScaler.noScaling,
                          ),
                          Icon(
                            CupertinoIcons.chevron_down,
                            color: textTheme.tabLabelTextStyle.color?.withAlpha(
                              180,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
            itemCount: provider.length.clamp(1, kMaxInt64),
            // (provider.length + (provider is RecommendProvider ? 1 : 0))
            //     .clamp(1, kMaxInt64),
          ),
        );
      },
    );
  }

  void newSound(String? text) {
    if (text == null) return;
    final accent = AppSettings.of(context).accent;
    autoSound?.cancel();
    autoSound = Timer(
      autoDelay,
      () => soundGTTs(text, accent.gTTS).onError((e, _) {}),
    );
  }

  Widget? verifyProvider(AsyncSnapshot snapshot, WordProvider provider) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(
        child: SpinKitFadingCircle(
          color: Theme.of(context).colorScheme.secondary,
        ),
      );
    } else if (snapshot.hasError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          Text(
            messageExceptions(snapshot.error),
            style: Theme.of(context).textTheme.titleLarge?.apply(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          Text("Pull down to refresh the page."),
        ],
      );
    }
    if (provider.length == 0) {
      return Center(
        child: Text(
          "You don't have to do review now",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      );
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    tabController.addListener(() {
      pageController.animateToPage(
        tabController.index,
        duration: Durations.short4,
        curve: Curves.ease,
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppSettings.of(context).wordProvider = recommend;
    });
    GestureRoutePage.onRoute = () => autoSound?.cancel();
  }

  @override
  void dispose() {
    tabController.dispose();
    GestureRoutePage.onRoute = null;
    super.dispose();
  }
}
