import 'package:ai_vocabulary/pages/vocabulary_page.dart';
import 'package:ai_vocabulary/widgets/alphabet_list_sheet.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_web_frame/flutter_web_frame.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'bottom_sheet/retrieval_bottom_sheet.dart';
import 'mock_data.dart';
import 'widgets/definition_tile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformProvider(
      settings: PlatformSettingsData(
        iosUsesMaterialWidgets: true,
      ),
      builder: (context) => PlatformTheme(
        builder: (context) => PlatformApp(
          title: 'AI Vocabulary App',
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
          ],
          home: FlutterWebFrame(
            builder: (context) => MyHomePage(title: 'Flutter Demo Home Page'),
            maximumSize: Size(300, 812.0), // Maximum size
            enabled: kIsWeb,
            backgroundColor: Colors.grey,
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    showPlatformModalSheet(
      context: context,
      material: MaterialModalSheetData(
        useSafeArea: true,
        isScrollControlled: true,
      ),
      builder: (context) => RetrievalBottomSheet(queryWord: "abdominal"),
    );
  }

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
    return PlatformTabScaffold(
      tabController: PlatformTabController(),
      iosContentPadding: true,
      appBarBuilder: (_, index) => PlatformAppBar(
        title: Text('${platform(context)} Page Title'),
        material: (_, __) => MaterialAppBarData(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      bodyBuilder: (_, index) => IndexedStack(index: index, children: [
        Center(child: Text("Page ${index + 1}")),
        AlphabetListSheet(
            contacts: List.generate(
                512, (i) => ClientModel(name: createName(), userId: i + 1))),
        Center(child: Text("Page ${index + 1}")),
        Center(child: Text("Page ${index + 1}")),
      ]),
      items: bottomItems,
      cupertino: (_, __) => CupertinoTabScaffoldData(
          appBarBuilder: (_, index) => CupertinoNavigationBar(
                middle: Text('iOS ${index + 1} page'),
              ),
          tabViewDataBuilder: (_, __) => CupertinoTabViewData(
              defaultTitle: '${platform(context)} Page Title')),
    );
  }

  PlatformScaffold simpleScaffold(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(widget.title),
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
                    const Text(
                      'You have pushed the button this many times:',
                    ),
                    Text(
                      '$_counter',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 20),
                    for (final defApple in apple.definitions)
                      DefinitionTile(
                        definition: defApple,
                        word: apple.word,
                      ),
                    PlatformElevatedButton(
                      onPressed: _incrementCounter,
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
                onPressed: _incrementCounter,
                tooltip: 'Increment',
                child: const Icon(Icons.add),
              ),
            ),
          )
        ],
      ),
      material: (context, platform) => MaterialScaffoldData(
          floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      )),
    );
  }
}
