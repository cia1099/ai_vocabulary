import 'package:ai_vocabulary/app_settings.dart';
import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:ai_vocabulary/pages/collection_page.dart';
import 'package:ai_vocabulary/widgets/imagen_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:text2speech/text2speech.dart';

import '../bottom_sheet/retrieval_bottom_sheet.dart';
import '../mock_data.dart';

import '../tabs/alphabet_list_tab.dart';
import '../tabs/chart_tab.dart';
import '../tabs/setting_tab.dart';
import '../tabs/vocabulary_tab.dart';
import '../widgets/definition_tile.dart';

class NavigationPage extends StatefulWidget {
  final Function(int index)? onTabChanged;
  const NavigationPage({super.key, this.onTabChanged});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  var _index = 0;
  var editableAlphabet = false;
  final bottomItems = [
    BottomNavigationBarItem(
        icon: PlatformWidget(
          material: (_, __) => const Icon(Icons.book_outlined),
          cupertino: (_, __) => const Icon(CupertinoIcons.book),
        ),
        label: "vocabulary"),
    BottomNavigationBarItem(
        icon: PlatformWidget(
          material: (_, __) => const Icon(Icons.chat_bubble_outline),
          cupertino: (_, __) => const Icon(CupertinoIcons.chat_bubble_2),
        ),
        label: "chats"),
    BottomNavigationBarItem(
        icon: PlatformWidget(
          material: (_, __) => const Icon(Icons.bar_chart),
          cupertino: (_, __) => const Icon(CupertinoIcons.doc_chart),
        ),
        label: "charts"),
    BottomNavigationBarItem(
        icon: PlatformWidget(
          material: (_, __) => const Icon(Icons.settings),
          cupertino: (_, __) => const Icon(CupertinoIcons.gear),
        ),
        label: "setting"),
  ];
  @override
  Widget build(BuildContext context) {
    // return simpleScaffold(context);
    // return tabScaffold(bottomItems, context);
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body:
          // PageView.builder(
          //   controller: widget.tabController,
          //   itemBuilder: (context, index) => switch (index) {
          //     1 => const AlphabetListTab(),
          //     2 => const ChartTab(),
          //     3 => const SettingTab(),
          //     _ => const VocabularyTab(),
          //   },
          //   itemCount: 4,
          //   physics: const NeverScrollableScrollPhysics(),
          // ),
          IndexedStack(index: _index, children: [
        MediaQuery.removeViewInsets(
            context: context,
            removeBottom: true,
            child: VocabularyTab(onTabChanged: widget.onTabChanged)),
        MediaQuery.removeViewInsets(
            context: context,
            removeBottom: true,
            child: const AlphabetListTab()),
        ChartTab(key: _index == 2 ? ValueKey(_index) : null),
        const SettingTab(),
      ]),
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        height: kBottomNavigationBarHeight,
        notchMargin: 2,
        shape: const CircularNotchedRectangle(),
        // color: Colors.red,
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Row(
              // crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(bottomItems.length + 1, (i) {
                var index = i;
                if (i == 2)
                  return const SizedBox(width: 32);
                else if (i > 2) {
                  index -= 1;
                }

                return PlatformIconButton(
                  padding: EdgeInsets.zero,
                  onPressed: _index == index
                      ? index != 0
                          ? null
                          : () => AppSettings.of(context)
                              .wordProvider
                              ?.pageController
                              .animateToPage(0,
                                  duration: Durations.medium3,
                                  curve: Curves.easeIn)
                      : () => setState(() {
                            _index = index;
                            widget.onTabChanged?.call(index);
                            // widget.tabController.jumpToPage(index);
                          }),
                  icon: Column(
                    children: [
                      Theme(
                          data: ThemeData(
                              iconTheme: IconThemeData(
                                  color: colorScheme.primary.withValues(
                                      alpha: _index == index ? 1 : .4))),
                          child: bottomItems[index].icon),
                      // _index == index
                      //     ? Expanded(
                      //         child: Lottie.asset('assets/lottie/chart.json'))
                      //     : bottomItems[index].icon,
                      Text(
                        '${bottomItems[index].label}',
                        style: TextStyle(
                          color: colorScheme.primary
                              .withValues(alpha: _index == index ? 1 : .4),
                          fontWeight: _index == index ? FontWeight.w600 : null,
                        ),
                      )
                    ],
                  ),
                  material: (_, __) => MaterialIconButtonData(
                      tooltip: bottomItems[index].tooltip,
                      style: IconButton.styleFrom(
                        padding: EdgeInsets.zero,
                        // minimumSize: const Size.square(50),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )),
                  // cupertino: (_, __) => CupertinoIconButtonData(minSize: 50),
                );
              })),
        ),
      ),
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context,
            platformPageRoute(
              context: context,
              fullscreenDialog: true,
              builder: (context) => const CollectionPage(),
            )),
        mini: true,
        shape: const CircleBorder(),
        elevation: 1,
        child: const Icon(CupertinoIcons.add),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
    );
  }

  PlatformTabScaffold tabScaffold(
      List<BottomNavigationBarItem> bottomItems, BuildContext context) {
    return PlatformTabScaffold(
      tabController: PlatformTabController(),
      iosContentPadding: true,
      appBarBuilder: (_, index) => PlatformAppBar(
        title: Text('${bottomItems[index].label}'),
        material: (_, __) => MaterialAppBarData(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      bodyBuilder: (_, index) => Stack(
        children: [
          IndexedStack(index: index, children: [
            Center(child: Text("Page ${index + 1}")),
            const AlphabetListTab(),
            const ChartTab(),
            const SettingTab(),
          ]),
          Align(
            alignment: const FractionalOffset(.5, .9),
            child: Offstage(
              offstage: platform(context) != PlatformTarget.iOS,
              child: FloatingActionButton(
                onPressed: () {},
                tooltip: 'My note',
                shape: const CircleBorder(),
                child: const Icon(CupertinoIcons.add),
              ),
            ),
          )
        ],
      ),
      items: bottomItems,
      cupertino: (_, __) => CupertinoTabScaffoldData(),
      cupertinoTabs: (_, __) => CupertinoTabBarData(),
    );
  }

  PlatformScaffold simpleScaffold(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text('Simple Scaffold Page'),
        material: (_, __) => MaterialAppBarData(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      body: Stack(
        children: [
          // SafeArea(
          //   child: ListView.builder(
          //       padding: const EdgeInsets.symmetric(horizontal: 16),
          //       itemCount: abdomen.definitions.length,
          //       itemBuilder: (context, index) => DefinitionTile(
          //             definition: abdomen.definitions[index],
          //             word: abdomen.word,
          //           )),
          // ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 20),
                    for (final defApple in apple.definitions)
                      DefinitionTile(
                        definition: defApple,
                        word: apple.word,
                      ),
                    PlatformElevatedButton(
                      onPressed: () => showWord(context),
                      child: const Text('showModalBottomSheet'),
                    ),
                    PlatformElevatedButton(
                      onPressed: () => showPlatformDialog(
                        context: context,
                        builder: (context) =>
                            ImagenDialog(apple.getExamples.first),
                      ),
                      child: const Text('show dialog window'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: const FractionalOffset(.9, .9),
            child: Offstage(
              offstage: platform(context) != PlatformTarget.iOS,
              child: FloatingActionButton(
                onPressed: () => showWord(context),
                tooltip: 'Increment',
                child: const Icon(Icons.add),
              ),
            ),
          )
        ],
      ),
      material: (context, platform) => MaterialScaffoldData(
          floatingActionButton: FloatingActionButton(
        onPressed: () => showWord(context),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      )),
    );
  }

  void showWord(BuildContext context) {
    immediatelyPlay(
      'https://www.cia1099.cloudns.ch/dict/dictionary/audio/apple__us_1.mp3',
    );
    // soundGTTs('shit man! (Hello, this is a test of the Azure speech service.)');
    // soundAzure(
    //     'shit man! (Hello, this is a test of the Azure speech service.)');
    showPlatformModalSheet(
      context: context,
      material: MaterialModalSheetData(
        useSafeArea: true,
        isScrollControlled: true,
      ),
      builder: (context) => const RetrievalBottomSheet(queryWord: "shit"),
    );
  }
}
