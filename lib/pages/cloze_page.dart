import 'dart:async';

import 'package:ai_vocabulary/api/dict_api.dart';
import 'package:ai_vocabulary/app_settings.dart';
import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/effects/fade_out_conceal.dart';
import 'package:ai_vocabulary/effects/show_toast.dart';
import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:ai_vocabulary/utils/phonetic.dart';
import 'package:ai_vocabulary/utils/regex.dart';
import 'package:ai_vocabulary/widgets/entry_actions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../app_route.dart';

class ClozePage extends StatefulWidget {
  const ClozePage({super.key, required this.word, this.entry});
  final Vocabulary word;
  final MapEntry<String, String>? entry;

  @override
  State<ClozePage> createState() => _ClozePageState();
}

class _ClozePageState extends State<ClozePage> {
  final defaultTip = 'Press enter or space to submit answer';
  late final tip = ValueNotifier(defaultTip);
  final inputController = TextEditingController();
  final focusNode = FocusNode();
  final showPhonetic = ValueNotifier(ConcealState.hide);
  Timer? timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final routeName = ModalRoute.of(context)?.settings.name;
      if (routeName == AppRoute.quiz) {
        focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    inputController.dispose();
    tip.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final word = widget.word;
    final entry = widget.entry ?? word.generateClozeEntry();
    final explain = entry.key;
    final example = entry.value;
    final phonetic = word.definitions
        .where((d) => d.explanations.any((e) => e.explain == explain))
        .map((d) => Phonetic('${d.phoneticUs}', d.audioUs))
        .first;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final hPadding = MediaQuery.sizeOf(context).width / 16;
    final routeName = ModalRoute.of(context)?.settings.name;
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text('Cloze Quiz'),
        material: (_, __) => MaterialAppBarData(
          actions: routeName == AppRoute.quiz
              ? [EntryActions(wordID: word.wordId)]
              : null,
        ),
        cupertino: (_, __) => CupertinoNavigationBarData(
          transitionBetweenRoutes: false,
          trailing: routeName == AppRoute.quiz
              ? EntryActions(wordID: word.wordId)
              : null,
        ),
      ),
      // PreferredSize(
      //     preferredSize: const Size.fromHeight(kToolbarHeight),
      //     child: Stack(
      //       children: [
      //         PlatformAppBar(
      //           title: const Text('Cloze Quiz'),
      //           material: (_, __) => MaterialAppBarData(
      //             backgroundColor:
      //                 Theme.of(context).colorScheme.inversePrimary,
      //           ),
      //         ),
      //         Positioned(
      //             bottom: kAppBarPadding,
      //             right: 16,
      //             child: EntryActions(wordID: word.wordId)),
      //       ],
      //     )),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(hPadding),
          child: Column(
            // direction: Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: hPadding,
            children: [
              Text(
                explain,
                style: textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
              ),
              Text.rich(
                TextSpan(
                  children: generateCloze(
                    example,
                    word.getMatchingPatterns,
                    Theme.of(context).colorScheme,
                    autofocus: routeName == AppRoute.quiz,
                  ),
                ),
                style: textTheme.bodyLarge,
              ),
              Container(
                height: 80,
                // width: hPadding * 14,
                padding: EdgeInsets.symmetric(horizontal: hPadding / 2),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer.withValues(alpha: .8),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.centerLeft,
                child: AnimatedBuilder(
                  animation: tip,
                  builder: (context, child) => Row(
                    children: [
                      Expanded(
                        child: Text(
                          tip.value,
                          style: textTheme.bodyLarge!.apply(
                            color: tip.value == defaultTip
                                ? null
                                : CupertinoColors.destructiveRed.resolveFrom(
                                    context,
                                  ),
                          ),
                        ),
                      ),
                      child!,
                    ],
                  ),
                  child: Container(
                    constraints: BoxConstraints(maxHeight: 30),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest.withAlpha(0x50),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: PlatformTextButton(
                      onPressed: () {
                        playPhonetic(phonetic.audioUrl, word: word.word)();
                        showPhonetic.value = ConcealState.unhide;
                        timer?.cancel();
                        timer = Timer(const Duration(seconds: 3), () {
                          showPhonetic.value = ConcealState.hide;
                        });
                      },
                      padding: EdgeInsets.symmetric(horizontal: hPadding / 1.5),
                      child: Text(
                        'Tip',
                        style: textTheme.bodySmall?.apply(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(child: SizedBox.shrink()),
              Center(
                child: ValueListenableBuilder(
                  valueListenable: showPhonetic,
                  builder: (context, value, child) =>
                      FadeOutConceal(fadeOutState: value, child: child),
                  child: Text(phonetic.phonetic, style: textTheme.bodyLarge),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<InlineSpan> generateCloze(
    String text,
    Iterable<String> matches,
    ColorScheme colorScheme, {
    bool autofocus = true,
  }) {
    return splitWords(text).map((s) {
      if (matches.contains(s) || matches.contains(s.toLowerCase())) {
        final wordPainter = TextPainter(
          text: TextSpan(text: s),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: double.maxFinite);

        final check = ValueNotifier(true);
        return WidgetSpan(
          child: ValueListenableBuilder(
            valueListenable: check,
            builder: (context, _, __) {
              return TextFormField(
                autofocus: autofocus,
                autocorrect: false,
                enableSuggestions: false,
                focusNode: focusNode,
                keyboardType: TextInputType.text,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                ],
                onChanged: (input) {
                  tip.value = defaultTip;
                  if (input.contains(RegExp(r'\s+'))) {
                    inputController.text = input.replaceAll(RegExp(r'\s+'), '');
                    final answer = verifyAnswer(s, matches);
                    if (answer == 'Correct') {
                      Navigator.of(context).popAndPushNamed(
                        AppRoute.entryVocabulary,
                        result: AppRoute.quiz,
                      );
                    } else {
                      tip.value = answer;
                    }
                  }
                  check.value = s.contains(RegExp(inputController.text));
                },
                style: TextStyle(
                  color: check.value ? colorScheme.primary : colorScheme.error,
                ),
                onFieldSubmitted: (_) {
                  focusNode.requestFocus();
                  final answer = verifyAnswer(s, matches);
                  if (answer == 'Correct') {
                    Navigator.of(context).popAndPushNamed(
                      AppRoute.entryVocabulary,
                      result: AppRoute.quiz,
                    );
                  } else {
                    tip.value = answer;
                  }
                },
                controller: inputController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(bottom: 4, left: 4),
                  constraints: BoxConstraints.tightFor(
                    width: wordPainter.width * 1.6,
                    height: wordPainter.height * 2,
                  ),
                ),
              );
            },
          ),
        );
      }
      return TextSpan(text: s);
    }).toList()..add(
      TextSpan(
        text: '\t\t',
        children: [
          WidgetSpan(
            child: GestureDetector(
              onTap: () {
                final accent = AppSettings.of(context).accent;
                final voicer = AppSettings.of(context).voicer;
                soundAzure(
                  text,
                  lang: accent.azure.lang,
                  sound: voicer,
                ).onError((_, __) => soundGTTs(text, accent.gTTS));
              },
              child: Icon(CupertinoIcons.volume_up),
            ),
          ),
        ],
      ),
    );
  }

  String verifyAnswer(String correctWord, Iterable<String> matches) {
    if (inputController.text.toLowerCase() == correctWord.toLowerCase()) {
      MyDB().upsertAcquaintance(
        wordId: widget.word.wordId,
        acquaint: ++widget.word.acquaint,
        isCorrect: true,
      );
      appearAward(context, widget.word.word);
      return "Correct";
    }
    if (matches.contains(inputController.text)) {
      final index = matches.toList().indexOf(correctWord);
      if (index < 2) {
        return 'Check Subject and Plural form';
      } else {
        return 'Check Tense and Participle forms';
      }
    }
    return 'Your answer is wrong!';
  }
}
