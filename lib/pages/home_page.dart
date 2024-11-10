import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:text2speech/text2speech.dart';

import '../bottom_sheet/retrieval_bottom_sheet.dart';
import '../mock_data.dart';
import '../views/alphabet_list_tab.dart';
import '../views/chart_tab.dart';
import '../views/setting_tab.dart';
import '../views/vocabulary_tab.dart';
import '../widgets/definition_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _index = 0;
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
        label: "chat"),
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

    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: PlatformAppBar(
            title: Text('${bottomItems[_index].label}'),
            material: (_, __) => MaterialAppBarData(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
          )),
      body: IndexedStack(index: _index, children: [
        const VocabularyTab(),
        AlphabetListTab(
            contacts: List.generate(
                512, (i) => ClientModel(name: createName(), userId: i + 1))),
        const ChartTab(),
        const SettingTab(),
      ]),
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        height: kBottomNavigationBarHeight,
        // color: Colors.red,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
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

                return IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _index == index
                        ? null
                        : setState(() {
                            _index = index;
                          }),
                    tooltip: bottomItems[index].tooltip,
                    icon: Column(
                      children: [
                        bottomItems[index].icon,
                        Text('${bottomItems[index].label}')
                      ],
                    ));
              })),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        shape: const CircleBorder(),
        elevation: 1,
        child: const Icon(CupertinoIcons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
            AlphabetListTab(
                contacts: List.generate(512,
                    (i) => ClientModel(name: createName(), userId: i + 1))),
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
                    )
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
