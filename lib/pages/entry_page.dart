import 'dart:math';

import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/model/collect_word.dart';
import 'package:ai_vocabulary/provider/word_provider.dart';
import 'package:ai_vocabulary/widgets/definition_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../app_route.dart';

class EntryPage extends StatelessWidget {
  const EntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final hPadding = screenWidth / 16;
    return PlatformScaffold(
      appBar: PlatformAppBar(
        material: (_, __) => MaterialAppBarData(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPadding),
          child: StreamBuilder(
              initialData: WordProvider().currentWord,
              stream: WordProvider().provideWord,
              builder: (context, snapshot) {
                final word = snapshot.data;
                if (word == null) {
                  Future.delayed(Durations.short1, Navigator.of(context).pop);
                  return const Center(
                      child: Text(
                          'There is no vocabulary you need to learn today'));
                }
                //TODO: It'll call twice when first build
                final idx = Random().nextInt(word.definitions.length);
                final phonetic = word.definitions[idx].phoneticUs;
                final audioUrl = word.definitions[idx].audioUs;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Future.delayed(Durations.medium1,
                      playPhonetic(audioUrl, word: word.word));
                  // print('soud $idx');
                });
                return Column(
                  children: [
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer.withOpacity(.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Review today"),
                              Text("0/120", style: textTheme.headlineSmall),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("New today"),
                              Text("0/40", style: textTheme.headlineSmall),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Learning today"),
                              Text("1min", style: textTheme.headlineSmall),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      // color: Colors.green,
                      height: 250,
                      width: double.maxFinite,
                      margin: const EdgeInsets.only(top: 16),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 250 - 80,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: CupertinoColors.black)),
                                  child: const Text("Learned 3 month ago"),
                                ),
                                Text(word.word, style: textTheme.displayMedium),
                                RichText(
                                  text: TextSpan(children: [
                                    TextSpan(text: '\t' * 4),
                                    TextSpan(text: phonetic),
                                    TextSpan(text: '\t' * 4),
                                    WidgetSpan(
                                        child: GestureDetector(
                                            onTap: playPhonetic(audioUrl,
                                                word: word.word),
                                            child: const Icon(
                                                CupertinoIcons.volume_up)))
                                  ], style: textTheme.titleLarge),
                                ),
                              ],
                            ),
                          ),
                          Container(
                              height: 80,
                              // color: colorScheme.secondaryContainer,
                              alignment: Alignment.centerLeft,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Wrap(
                                spacing: 8,
                                children: word.getInflection
                                    .map((e) => Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 8),
                                          decoration: BoxDecoration(
                                              color:
                                                  colorScheme.primaryContainer,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      textTheme.bodyMedium!
                                                          .fontSize!)),
                                          child: Text(e,
                                              style: TextStyle(
                                                  color: colorScheme
                                                      .onPrimaryContainer)),
                                        ))
                                    .toList(),
                              )),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        // foregroundColor: colorScheme.onSurfaceVariant,
                        backgroundColor: colorScheme.surfaceContainer,
                      ),
                      onPressed: () {
                        MyDB.instance.updateCollectWord(
                            wordId: word.wordId, acquaint: kMaxAcquaintance);
                        Navigator.of(context)
                            .pushNamed(AppRoute.entryVocabulary);
                      },
                      icon: Icon(CupertinoIcons.trash,
                          color: colorScheme.onSurfaceVariant),
                      label: Text('Mark as too easy',
                          style:
                              TextStyle(color: colorScheme.onSurfaceVariant)),
                    ),
                    const Expanded(child: SizedBox()),
                    Wrap(
                      spacing: screenWidth / 12,
                      children: [
                        TextButton(
                          onPressed: () {
                            MyDB.instance.updateCollectWord(
                                wordId: word.wordId, acquaint: 0);
                            Navigator.of(context)
                                .pushNamed(AppRoute.entryVocabulary);
                          },
                          style: TextButton.styleFrom(
                              fixedSize: Size.square(screenWidth / 3),
                              backgroundColor: colorScheme.secondaryContainer
                                  .withOpacity(.8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16))),
                          child: Text(
                            "Unknown",
                            style: textTheme.titleLarge!
                                .apply(color: colorScheme.error),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamed(AppRoute.cloze),
                          style: TextButton.styleFrom(
                              fixedSize: Size.square(screenWidth / 3),
                              backgroundColor: colorScheme.secondaryContainer
                                  .withOpacity(.8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16))),
                          child: Text(
                            "Recognize",
                            style: textTheme.titleLarge!
                                .apply(color: colorScheme.primary),
                          ),
                        ),
                      ],
                    )
                  ],
                );
              }),
        ),
      ),
    );
  }
}
