import 'package:ai_vocabulary/app_route.dart';
import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:ai_vocabulary/pages/vocabulary_page.dart';
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:ai_vocabulary/widgets/definition_tile.dart';
import 'package:ai_vocabulary/widgets/entry_actions.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class WordListPage extends StatelessWidget {
  const WordListPage({super.key, required this.words, this.nextTap});

  final List<Vocabulary> words;
  final VoidCallback? nextTap;

  @override
  Widget build(BuildContext context) {
    final hPadding = MediaQuery.of(context).size.width / 32;
    final dividerTheme = Theme.of(context).dividerTheme;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final routeName = ModalRoute.of(context)?.settings.name;
    final title = routeName != null && routeName.contains('entry')
        ? 'Review Words'
        : 'My table vocabulary';
    final reachTarget = ModalRoute.of(context)?.settings.arguments as bool?;
    return PlatformScaffold(
      appBar: PlatformAppBar(
        leading: nextTap == null
            ? null
            : CupertinoNavigationBarBackButton(
                onPressed: nextTap,
              ),
        title: Text(title),
        backgroundColor: colorScheme.primaryContainer,
        cupertino: (_, __) =>
            CupertinoNavigationBarData(trailing: const EntryActions()),
        material: (_, __) => MaterialAppBarData(
          backgroundColor: colorScheme.inversePrimary,
          actions: [const EntryActions()],
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView.builder(
              itemExtentBuilder: (index, dimensions) {
                if (words.length < 10 && words.isNotEmpty) {
                  return dimensions.viewportMainAxisExtent / kRemindLength;
                }
                return dimensions.viewportMainAxisExtent / 10;
              },
              itemCount: words.length, //+ (words.length < 10 ? 1 : 0),
              itemBuilder: (context, index) {
                // if (index >= words.length) return const SizedBox();
                final word = words[index];
                final phonetics = word.getPhonetics();
                return Column(
                  children: [
                    Offstage(
                        offstage: index == 0,
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: hPadding / 2),
                          child: DottedLine(
                              dashColor: dividerTheme.color ??
                                  Theme.of(context).dividerColor),
                        )),
                    PlatformListTile(
                      title: Row(
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
                                  text: phonetics.firstOrNull?.phonetic,
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
                      subtitle: Text(word.getSpeechAndTranslation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyLarge),
                      // Wrap(
                      //     spacing: 8,
                      //     children: word.definitions
                      //         .map((d) => Text(
                      //               speechShortcut(d.partOfSpeech),
                      //               style: textTheme.bodyLarge,
                      //             ))
                      //         .toList()),
                      onTap: () => Navigator.of(context).push(platformPageRoute(
                        context: context,
                        builder: (context) => VocabularyPage(word: word),
                        settings:
                            const RouteSettings(name: AppRoute.vocabulary),
                      )),
                    ),
                  ],
                );
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Offstage(
                offstage: nextTap == null,
                child: PlatformElevatedButton(
                  onPressed: nextTap,
                  child: Text(reachTarget != true ? 'Next set' : 'Complete'),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
