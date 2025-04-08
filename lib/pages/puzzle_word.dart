import 'dart:async';

import 'package:ai_vocabulary/app_route.dart';
import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:ai_vocabulary/utils/phonetic.dart' show playPhonetic;
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:ai_vocabulary/widgets/definition_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../effects/show_toast.dart' show appearAward;

class PuzzleWord extends StatefulWidget {
  final Vocabulary word;
  final MapEntry<String, String>? entry;

  const PuzzleWord({super.key, required this.word, this.entry});

  @override
  State<PuzzleWord> createState() => _PuzzleWordState();
}

class _PuzzleWordState extends State<PuzzleWord> {
  late final puzzle = widget.word.word.split('')..shuffle();
  final showPhonetic = ValueNotifier(false);
  final showFault = ValueNotifier(false);
  Timer? tipTimer;
  Timer? faultTimer;

  @override
  Widget build(BuildContext context) {
    final word = widget.word;
    final entry = widget.entry ?? word.generateClozeEntry();
    final explain = entry.key;
    final definition = word.definitions.firstWhere(
      (d) => d.explanations.any((e) => e.explain == explain),
    );
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final hPadding = MediaQuery.sizeOf(context).width / 32;
    final routeName = ModalRoute.of(context)?.settings.name;
    const cardSize = kToolbarHeight; //64.0;
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text("Puzzle Quiz"),
        backgroundColor: Theme.of(context).colorScheme.surface,
        cupertino: (_, __) => CupertinoNavigationBarData(border: Border()),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: hPadding * 2,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPadding),
              child: Wrap(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        definition.partOfSpeech,
                        style: textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ).coloredSpeech(context: context),
                      ValueListenableBuilder(
                        valueListenable: showPhonetic,
                        builder:
                            (context, value, child) => AnimatedSwitcher(
                              duration: Durations.long3,
                              transitionBuilder: (child, animation) {
                                final opacity =
                                    animation.status ==
                                            AnimationStatus.dismissed
                                        ? .8
                                        : 0.0;
                                return FadeTransition(
                                  opacity: Tween(
                                    begin: opacity,
                                    end: 1.0,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeIn,
                                    ),
                                  ),
                                  child: child,
                                );
                              },
                              child: value ? child : SizedBox.shrink(),
                            ),
                        child: Text(
                          definition.phoneticUs!,
                          style: textTheme.bodyLarge,
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints(maxHeight: 30),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withAlpha(
                            0x50,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: PlatformTextButton(
                          onPressed: () {
                            playPhonetic(definition.audioUs, word: word.word)();
                            showPhonetic.value = true;
                            tipTimer?.cancel();
                            tipTimer = Timer(const Duration(seconds: 3), () {
                              showPhonetic.value = false;
                            });
                          },
                          padding: EdgeInsets.symmetric(
                            horizontal: hPadding / 1.5,
                          ),
                          child: Text(
                            'Tip',
                            style: textTheme.bodySmall?.apply(
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 4),
                  DefinitionParagraph(
                    explain: definition.explanations.firstWhere(
                      (e) => e.explain == explain,
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: SizedBox(
                // color: Colors.grey,
                // alignment: Alignment(0, 0),
                height: cardSize,
                width: cardSize * puzzle.length,
                child: StatefulBuilder(
                  builder:
                      (context, setState) => ReorderableListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemExtentBuilder:
                            (index, dimensions) =>
                                (dimensions.viewportMainAxisExtent /
                                        puzzle.length)
                                    .clamp(0, cardSize),
                        itemBuilder:
                            (context, index) => ReorderableDragStartListener(
                              key: ValueKey(index),
                              index: index,
                              child: Container(
                                alignment: Alignment(0, 0),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.systemYellow
                                      .resolveFrom(context),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(width: 2),
                                ),
                                child: ValueListenableBuilder(
                                  valueListenable: showFault,
                                  builder:
                                      (context, show, _) => Text(
                                        puzzle[index],
                                        style: textTheme.labelLarge?.apply(
                                          color:
                                              show && isFaultCharacter(index)
                                                  ? CupertinoColors.systemRed
                                                      .resolveFrom(context)
                                                  : Colors.black,
                                        ),
                                        textScaler: TextScaler.linear(2),
                                      ),
                                ),
                              ),
                            ),
                        itemCount: puzzle.length,
                        onReorder: (oldIndex, newIndex) {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final item = puzzle.removeAt(oldIndex);
                          puzzle.insert(newIndex, item);
                          setState(() {});
                        },
                      ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: hPadding * 3),
              constraints: BoxConstraints(minWidth: 100, minHeight: 100),
              child: PlatformWidgetBuilder(
                cupertino:
                    (_, child, _) => CupertinoButton.tinted(
                      onPressed: submitAnswer,
                      child: child!,
                    ),
                material:
                    (_, child, _) => FilledButton.tonal(
                      onPressed: submitAnswer,
                      child: child,
                    ),
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void submitAnswer() {
    if (puzzle.join() == widget.word.word) {
      MyDB().updateAcquaintance(
        wordId: widget.word.wordId,
        acquaint: ++widget.word.acquaint,
        isCorrect: true,
      );
      appearAward(context, widget.word.word);
      Navigator.of(context).popAndPushNamed(AppRoute.entryVocabulary);
    } else {
      showFault.value = true;
      faultTimer?.cancel();
      faultTimer = Timer(const Duration(seconds: 2), () {
        showFault.value = false;
      });
    }
  }

  bool isFaultCharacter(int index) => puzzle[index] != widget.word.word[index];
}
