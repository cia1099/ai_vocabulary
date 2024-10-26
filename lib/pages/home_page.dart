import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../bottom_sheet/retrieval_bottom_sheet.dart';
import '../mock_data.dart';
import '../views/alphabet_list_tab.dart';
import '../views/chart_tab.dart';
import '../views/setting_tab.dart';
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
          material: (_, __) => Icon(Icons.book_outlined),
          cupertino: (_, __) => Icon(CupertinoIcons.book),
        ),
        label: "vocabulary"),
    BottomNavigationBarItem(
        icon: PlatformWidget(
          material: (_, __) => Icon(Icons.chat_bubble_outline),
          cupertino: (_, __) => Icon(CupertinoIcons.chat_bubble_2),
        ),
        label: "chat"),
    BottomNavigationBarItem(
        icon: PlatformWidget(
          material: (_, __) => Icon(Icons.bar_chart),
          cupertino: (_, __) => Icon(CupertinoIcons.doc_chart),
        ),
        label: "charts"),
    BottomNavigationBarItem(
        icon: PlatformWidget(
          material: (_, __) => Icon(Icons.settings),
          cupertino: (_, __) => Icon(CupertinoIcons.gear),
        ),
        label: "setting"),
  ];
  @override
  Widget build(BuildContext context) {
    // return simpleScaffold(context);
    // return tabScaffold(bottomItems, context);

    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: PlatformAppBar(
            title: Text('${bottomItems[_index].label}'),
            material: (_, __) => MaterialAppBarData(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
          )),
      body: IndexedStack(index: _index, children: [
        Center(child: Text("Page ${_index + 1}")),
        AlphabetListTab(
            contacts: List.generate(
                512, (i) => ClientModel(name: createName(), userId: i + 1))),
        ChartTab(),
        SettingTab(),
      ]),
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        height: kBottomNavigationBarHeight,
        // color: Colors.red,
        notchMargin: 8,
        shape: CircularNotchedRectangle(),
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Row(
              // crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(bottomItems.length + 1, (i) {
                var index = i;
                if (i == 2)
                  return SizedBox(width: 32);
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
        child: Icon(CupertinoIcons.add),
        shape: CircleBorder(),
        elevation: 1,
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
            ChartTab(),
            SettingTab(),
          ]),
          Align(
            alignment: FractionalOffset(.5, .9),
            child: Offstage(
              offstage: platform(context) != PlatformTarget.iOS,
              child: FloatingActionButton(
                onPressed: () {},
                tooltip: 'My note',
                shape: CircleBorder(),
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
                    SizedBox(height: 20),
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
            alignment: FractionalOffset(.9, .9),
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
    showPlatformModalSheet(
      context: context,
      material: MaterialModalSheetData(
        useSafeArea: true,
        isScrollControlled: true,
      ),
      builder: (context) => RetrievalBottomSheet(queryWord: "shit"),
    );
  }
}
