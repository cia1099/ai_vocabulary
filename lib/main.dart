import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_web_frame/flutter_web_frame.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'mock_data.dart';

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
    final apple_def = apple.definitions[0];
    return PlatformScaffold(
      appBar: PlatformAppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
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
                  DefinitionTile(definition: apple_def),
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

class DefinitionTile extends StatelessWidget {
  const DefinitionTile({
    super.key,
    required this.definition,
  });

  final Definition definition;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(definition.partOfSpeech,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontWeight: FontWeight.bold)),
            if (definition.phoneticUk != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🇬🇧${definition.phoneticUk!}'),
                  InkWell(
                    onTap: () {},
                    child: Icon(CupertinoIcons.volume_up,
                        size: Theme.of(context).textTheme.titleLarge!.fontSize),
                  ),
                ],
              ),
            if (definition.phoneticUs != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🇺🇸${definition.phoneticUs!}'),
                  InkWell(
                    onTap: () {},
                    child: Icon(CupertinoIcons.volume_up,
                        size: Theme.of(context).textTheme.titleLarge!.fontSize),
                  ),
                ],
              ),
          ],
        ),
        const Divider(height: 1),
        if (definition.inflection != null)
          Wrap(
            spacing: 8,
            children: definition.inflection!
                .split(", ")
                .map((e) => Container(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .fontSize!)),
                      child: Text(e,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer)),
                    ))
                .toList(),
          ),
        if (definition.translate != null) Text(definition.translate!),
        for (final explain in definition.explanations) ...[
          Text.rich(TextSpan(children: [
            if (explain.subscript != null)
              TextSpan(
                  text: '[${explain.subscript!}]\t',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .apply(color: Theme.of(context).colorScheme.primary)),
            TextSpan(
                text: explain.explain,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontWeight: FontWeight.bold)),
          ])),
          for (final example in explain.examples)
            Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: "\t" * 4),
                        WidgetSpan(
                            child: Icon(
                          CupertinoIcons.circle_fill,
                          size: Theme.of(context).textTheme.bodySmall!.fontSize,
                          color: Theme.of(context).colorScheme.primary,
                        )),
                        TextSpan(text: "\t"),
                        TextSpan(text: example),
                      ],
                    ),
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Icon(CupertinoIcons.volume_up,
                      size: Theme.of(context).textTheme.bodyLarge!.fontSize),
                ),
              ],
            )
        ]
      ],
    );
  }
}
