import 'package:ai_vocabulary/pages/slider_page.dart';
import 'package:ai_vocabulary/provider/word_provider.dart';
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
  final recommend = RecommendProvider(pageController: PageController());
  final review = ReviewProvider(pageController: PageController());

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
                child: PageView(
                  // key: PageStorageKey(pageController),
                  controller: pageController,
                  onPageChanged: (value) {
                    tabController.animateTo(value);
                    widget.onTabChanged?.call((value + 1) & 1);
                  },
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    SliderView(provider: review),
                    SliderView(provider: recommend),
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
}

class SliderView extends StatelessWidget {
  const SliderView({
    super.key,
    required this.provider,
  });

  final WordProvider provider;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) => FutureBuilder(
        future: provider.initial(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SpinKitFadingCircle(
                color: Theme.of(context).colorScheme.primaryContainer,
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
          return PageView.builder(
            key: PageStorageKey(provider[0].wordId),
            scrollDirection: Axis.vertical,
            findChildIndexCallback: (key) => (key as ValueKey).value,
            controller: provider.pageController,
            onPageChanged: (index) {
              provider.currentWord = provider[index % provider.length];

              if (provider is RecommendProvider) {
                (provider as RecommendProvider).fetchStudyWords(index);
                //TODO onError handle http failure
                //     .whenComplete(() {
                //   print(
                //       'provider = ${provider.map((e) => e.wordId).join(', ')}');
                //   print('words = ${provider.map((e) => e.word).join(', ')}');
                // });
                if (index == provider.length) {
                  Future.delayed(Durations.extralong4, () {
                    setState(() {
                      provider.pageController?.jumpToPage(0);
                    });
                  });
                }
              }
            },
            itemBuilder: (context, index) {
              final i = index % provider.length;
              final word = provider[i];
              return SliderPage(key: ValueKey(index), word: word);
            },
            itemCount: provider is RecommendProvider
                ? RecommendProvider.kMaxLength + 1
                : provider.length,
          );
        },
      ),
    );
  }
}
