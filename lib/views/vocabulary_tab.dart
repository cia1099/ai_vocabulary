import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:ai_vocabulary/pages/collection_page.dart';
import 'package:ai_vocabulary/pages/entry_page.dart';
import 'package:ai_vocabulary/provider/word_provider.dart';
import 'package:ai_vocabulary/app_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../widgets/definition_tile.dart';

class VocabularyTab extends StatelessWidget {
  const VocabularyTab({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height -
        kToolbarHeight -
        kBottomNavigationBarHeight;
    final hPadding = MediaQuery.of(context).size.width / 32;
    final textTheme = Theme.of(context).textTheme;
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemBuilder: (context, index) {
        final word = WordProvider().subList().elementAt(index);
        return Entry(
          word: word,
        );
      },
      itemCount: WordProvider().studyCount,
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Already checked days:', style: textTheme.titleLarge),
        Text('255', style: textTheme.headlineMedium),
        Container(
          height: 150,
          alignment: Alignment.center,
          width: double.maxFinite,
          margin: EdgeInsets.symmetric(horizontal: hPadding),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(),
              color: Theme.of(context).colorScheme.surfaceBright),
          child: PlatformTextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoute.todayWords),
              child: const Text("Today's study")),
        ),
        MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: Container(
            // color: Colors.red,
            height: maxHeight / 4,
            padding: EdgeInsets.all(hPadding),
            child: GridView.count(
              primary: false,
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                Card.outlined(
                  child: StreamBuilder(
                      stream: WordProvider().provideWord,
                      builder: (context, snapshot) {
                        return AbsorbPointer(
                          absorbing: snapshot.data == null,
                          child: InkWell(
                            onTap: () =>
                                Navigator.of(context).pushNamed(AppRoute.entry),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.square_stack),
                                Text("study")
                              ],
                            ),
                          ),
                        );
                      }),
                ),
                Card.outlined(
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(platformPageRoute(
                        context: context,
                        builder: (context) => const CollectionPage())),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(CupertinoIcons.star), Text("favorite")],
                    ),
                  ),
                ),
                const Card.outlined(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(CupertinoIcons.hand_draw), Text("game")],
                  ),
                ),
                const Card.outlined(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.photo),
                      Text(
                        "guess picture",
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class Entry extends StatelessWidget {
  const Entry({
    super.key,
    required this.word,
  });

  final Vocabulary word;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final hPadding = screenWidth / 32;
    final phonetics = word.getPhonetics();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPadding),
      child: Column(
        children: [
          Container(
            height: 100,
            margin: EdgeInsets.only(top: hPadding),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withValues(alpha: .8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Review today"),
                    Text(WordProvider().reviewProgress,
                        style: textTheme.headlineSmall),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("New today"),
                    Text(WordProvider().studyProgress,
                        style: textTheme.headlineSmall),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Learning today"),
                    Text('0min', style: textTheme.headlineSmall),
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
                            border: Border.all(color: CupertinoColors.black)),
                        child: const Text("Learned 3 month ago"),
                      ),
                      Text(word.word, style: textTheme.displayMedium),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: word.getInflection
                            .map((e) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(
                                          textTheme.bodyMedium!.fontSize!)),
                                  child: Text(e,
                                      style: TextStyle(
                                          color:
                                              colorScheme.onPrimaryContainer)),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                Container(
                  // color: Colors.red,
                  height: 80,
                  alignment: const Alignment(0, 0),
                  child: Wrap(
                    children: phonetics
                        .map(
                          (p) => RichText(
                            text: TextSpan(children: [
                              TextSpan(text: '\t' * 4),
                              TextSpan(text: p.phonetic),
                              TextSpan(text: '\t' * 2),
                              WidgetSpan(
                                  child: GestureDetector(
                                      onTap: playPhonetic(p.audioUrl,
                                          word: word.word),
                                      child:
                                          const Icon(CupertinoIcons.volume_up)))
                            ], style: textTheme.titleLarge),
                          ),
                        )
                        .toList(),
                  ),
                )
              ],
            ),
          ),
          TextButton.icon(
            style: TextButton.styleFrom(
              // foregroundColor: colorScheme.onSurfaceVariant,
              backgroundColor: colorScheme.surfaceContainer,
            ),
            onPressed: () {
              // MyDB.instance.updateAcquaintance(
              //     wordId: word.wordId, acquaint: kMaxAcquaintance);
              // // Navigator.of(context)
              // //     .pushNamed(AppRoute.entryVocabulary);
              // pushNamed(context, AppRoute.entryVocabulary);
            },
            icon:
                Icon(CupertinoIcons.trash, color: colorScheme.onSurfaceVariant),
            label: Text('Mark as too easy',
                style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ),
          const Expanded(child: SizedBox()),
          Wrap(
            spacing: screenWidth / 12,
            children: [
              TextButton(
                onPressed: () {
                  // MyDB.instance
                  //     .updateAcquaintance(wordId: word.wordId, acquaint: 0);
                  // // Navigator.of(context)
                  // //     .pushNamed(AppRoute.entryVocabulary);
                  // pushNamed(context, AppRoute.entryVocabulary);
                },
                style: TextButton.styleFrom(
                    fixedSize: Size.square(screenWidth / 3),
                    backgroundColor:
                        colorScheme.secondaryContainer.withValues(alpha: .8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                child: Text(
                  "Unknown",
                  style: textTheme.titleLarge!.apply(color: colorScheme.error),
                ),
              ),
              TextButton(
                onPressed: null,
                // onPressed: () => pushNamed(
                //     context,
                //     AppRoute
                //         .cloze), //Navigator.of(context).pushNamed(AppRoute.cloze),
                style: TextButton.styleFrom(
                    fixedSize: Size.square(screenWidth / 3),
                    backgroundColor:
                        colorScheme.secondaryContainer.withValues(alpha: .8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                child: Text(
                  "Recognize",
                  style:
                      textTheme.titleLarge!.apply(color: colorScheme.primary),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: PlatformAppBar(
          title: const Text('第二页'),
          material: (_, __) => MaterialAppBarData(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
      ),
      body: Container(
        // color: Colors.blueGrey,
        alignment: const Alignment(0, 0),
        child: const Text(
          '这是第二页',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
