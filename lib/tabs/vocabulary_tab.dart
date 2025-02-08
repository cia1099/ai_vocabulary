import 'dart:math';

import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/pages/slider_page.dart';
import 'package:ai_vocabulary/provider/word_provider.dart';
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../app_settings.dart';

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
  late final recommend = RecommendProvider(context: context);
  final review = ReviewProvider();
  final rng = Random();

  @override
  Widget build(BuildContext context) {
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
          child: Stack(
            children: [
              Positioned.fill(
                child: PageView(
                  // key: PageStorageKey(pageController),
                  controller: pageController,
                  onPageChanged: (value) {
                    tabController.animateTo(value);
                    widget.onTabChanged?.call((value + 1) & 1);
                    AppSettings.of(context).wordProvider =
                        value == 0 ? review : recommend;
                  },
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    sliders(provider: review),
                    sliders(provider: recommend),
                  ],
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
                          Text('0/20', style: textTheme.headlineSmall),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("New today"),
                          Text('0/20', style: textTheme.headlineSmall),
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

  Widget sliders({required WordProvider provider}) {
    return FutureBuilder(
      future: provider.isReady,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SpinKitFadingCircle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          );
        }
        if (provider.length == 0) {
          return const Center(
            child: Text(
              "You don't have to do review",
              textAlign: TextAlign.center,
              textScaler: TextScaler.linear(2.5),
            ),
          );
        }
        return ListenableBuilder(
          listenable: MyDB(),
          builder: (context, child) => PageView.builder(
            // key: PageStorageKey(provider),
            // findChildIndexCallback: (key) => (key as ValueKey).value,
            scrollDirection: Axis.vertical,
            controller: provider.pageController,
            onPageChanged: (index) {
              provider.currentWord = provider[index % provider.length];
              provider.clozeSeed = rng.nextInt(256);
              if (provider is RecommendProvider) {
                provider.fetchStudyWords(index);
                //TODO onError handle http failure
                //     .whenComplete(() {
                //   print('provider = ${provider.map((e) => e.wordId).join(', ')}');
                //   //   print('words = ${provider.map((e) => e.word).join(', ')}');
                // });
                if (index == RecommendProvider.kMaxLength) {
                  Future.delayed(Durations.extralong4, () {
                    setState(() {
                      provider.pageController.jumpToPage(0);
                    });
                  });
                } else if (index > 0 &&
                    provider.pageController.position.atEdge) {
                  //TODO: fetch http request error
                  print('at max page');
                }
              }
            },
            itemBuilder: (context, index) {
              final i = index % provider.length;
              final word = provider[i];
              return SliderPage(word: word);
            },
            itemCount:
                provider.length + (provider is RecommendProvider ? 1 : 0),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    tabController.addListener(() {
      pageController.animateToPage(tabController.index,
          duration: Durations.short4, curve: Curves.ease);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppSettings.of(context).wordProvider ??= recommend;
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }
}
