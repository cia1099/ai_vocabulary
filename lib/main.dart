import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_web_frame/flutter_web_frame.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lorem/flutter_lorem.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
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
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      useSafeArea: true,
                      isScrollControlled: true,
                      builder: (context) => StatefulBuilder(
                        builder: (context, setState) {
                          final content = lorem(paragraphs: 10, words: 500);
                          return DraggableScrollableSheet(
                            expand: false,
                            snap: true,
                            minChildSize: .1,
                            snapSizes: [.3, .98],
                            initialChildSize: .3,
                            builder: (context, scrollController) => Column(
                              children: [
                                SingleChildScrollView(
                                  controller: scrollController,
                                  physics: ClampingScrollPhysics(),
                                  child: Container(
                                    height: 25,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(),
                                        Icon(CupertinoIcons
                                            .chevron_up_chevron_down),
                                        Icon(CupertinoIcons.xmark_circle_fill)
                                      ],
                                    ),
                                  ),
                                ),
                                Flexible(
                                    child: ListView.builder(
                                  itemCount: 50,
                                  itemBuilder: (context, index) =>
                                      ListTile(title: Text('Item $index')),
                                )
                                    // SingleChildScrollView(
                                    //     // controller: scrollController,
                                    //     physics: BouncingScrollPhysics(),
                                    //     child: Column(
                                    //       children: List.generate(
                                    //           50,
                                    //           (index) => ListTile(
                                    //               title: Text('Item $index'))),
                                    //     )),
                                    ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    child: const Text('showModalBottomSheet'),
                  )
                ],
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
