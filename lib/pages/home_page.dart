import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../bottom_sheet/retrieval_bottom_sheet.dart';
import '../mock_data.dart';
import '../views/alphabet_list_tab.dart';
import '../views/chart_tab.dart';
import '../views/setting_tab.dart';
import '../widgets/definition_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // return simpleScaffold(context);

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
    return PlatformTabScaffold(
      tabController: PlatformTabController(),
      iosContentPadding: true,
      appBarBuilder: (_, index) => PlatformAppBar(
        title: Text('${bottomItems[index].label}'),
        material: (_, __) => MaterialAppBarData(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      bodyBuilder: (_, index) => IndexedStack(index: index, children: [
        Center(child: Text("Page ${index + 1}")),
        AlphabetListTab(
            contacts: List.generate(
                512, (i) => ClientModel(name: createName(), userId: i + 1))),
        ChartTab(),
        SettingTab(),
      ]),
      items: bottomItems,
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
