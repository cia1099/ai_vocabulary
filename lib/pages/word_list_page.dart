import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:ai_vocabulary/pages/vocabulary_page.dart';
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:ai_vocabulary/widgets/definition_tile.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class WordListPage extends StatelessWidget {
  const WordListPage({super.key, required this.words});

  final List<Vocabulary> words;

  @override
  Widget build(BuildContext context) {
    final hPadding = MediaQuery.of(context).size.width / 16;
    final dividerTheme = Theme.of(context).dividerTheme;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text('My table vocabulary'),
        material: (_, __) => MaterialAppBarData(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      body: ListView.builder(
        itemCount: words.length,
        itemBuilder: (context, index) {
          final word = words[index];
          final phonetics = word.getPhonetics();
          return Column(
            children: [
              Offstage(
                  offstage: index == 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: hPadding / 2),
                    child: DottedLine(
                        dashColor: dividerTheme.color ??
                            Theme.of(context).dividerColor),
                  )),
              PlatformListTile(
                title: Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text.rich(
                            TextSpan(children: [
                              TextSpan(
                                text: word.word,
                                // style: textTheme.headlineSmall,
                                style: textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600)
                                    .apply(fontSizeFactor: 1.414),
                              ),
                              TextSpan(text: '\t' * 2),
                              TextSpan(
                                  text: phonetics.first.phonetic,
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                  )),
                            ]),
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleMedium,
                          ),
                          RichText(
                              text: TextSpan(children: [
                            WidgetSpan(
                                child: GestureDetector(
                                    onTap: playPhonetic(null, word: word.word),
                                    child:
                                        const Icon(CupertinoIcons.volume_up)))
                          ]))
                        ],
                      ),
                      Wrap(
                        spacing: 8,
                        children: word.definitions
                            .map((d) => Text(speechShortcut(d.partOfSpeech)))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                onTap: () => Navigator.of(context).push(platformPageRoute(
                  context: context,
                  builder: (context) => VocabularyPage(word: word),
                  settings: const RouteSettings(name: '/vocabulary'),
                )),
              ),
            ],
          );
        },
      ),
    );
  }
}
