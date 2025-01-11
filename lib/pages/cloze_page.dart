import 'dart:math';

import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/effects/show_toast.dart';
import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:ai_vocabulary/utils/regex.dart';
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:ai_vocabulary/widgets/entry_actions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../app_route.dart';

class ClozePage extends StatefulWidget {
  const ClozePage({super.key, required this.word});
  final Vocabulary word;

  @override
  State<ClozePage> createState() => _ClozePageState();
}

class _ClozePageState extends State<ClozePage> {
  final defaultTip = 'Press enter or space to submit answer';
  late final tip = ValueNotifier(defaultTip);
  final inputController = TextEditingController();
  final rng = Random();
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => focusNode.requestFocus());
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
    var idx = rng.nextInt(word.definitions.length);
    var example = '', explain = '';
    final definition = word.definitions[idx];
    idx = rng.nextInt(definition.explanations.length);
    final explanation = definition.explanations[idx];
    explain = explanation.explain;
    if (explanation.examples.isEmpty) {
      example = explain.split(' ').length > 1 ? word.word : explain;
    } else {
      idx = rng.nextInt(explanation.examples.length);
      example = explanation.examples[idx];
    }

    final textTheme = Theme.of(context).textTheme;
    final hPadding = MediaQuery.of(context).size.width / 16;
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Stack(
            children: [
              PlatformAppBar(
                material: (_, __) => MaterialAppBarData(
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              Positioned(
                  bottom: kAppBarPadding,
                  right: 16,
                  child: EntryActions(wordID: word.wordId)),
            ],
          )),
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.all(hPadding),
        child: Wrap(
          direction: Axis.vertical,
          spacing: hPadding,
          children: [
            SizedBox(
              // color: Colors.red,
              width: hPadding * 14,
              child: Text(explain,
                  style: textTheme.bodyLarge!
                      .copyWith(fontWeight: FontWeight.bold, height: 1.25)),
            ),
            SizedBox(
                // color: Colors.green,
                width: hPadding * 14,
                child: Text.rich(
                    TextSpan(
                      children: generateCloze(example, word.getMatchingPatterns,
                          Theme.of(context).colorScheme),
                    ),
                    style: textTheme.bodyLarge)),
            Container(
              height: 80,
              width: hPadding * 14,
              padding: EdgeInsets.symmetric(horizontal: hPadding / 2),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .secondaryContainer
                    .withValues(alpha: .8),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.centerLeft,
              child: AnimatedBuilder(
                  animation: tip,
                  builder: (context, child) => Text(
                        tip.value,
                        style: textTheme.bodyLarge!.apply(
                            color: tip.value == defaultTip
                                ? null
                                : CupertinoColors.destructiveRed
                                    .resolveFrom(context)),
                      )),
            )
          ],
        ),
      )),
    );
  }

  List<InlineSpan> generateCloze(
      String text, Iterable<String> matches, ColorScheme colorScheme) {
    return splitWords(text).map((s) {
      if (matches.contains(s.toLowerCase())) {
        final wordPainter = TextPainter(
            text: TextSpan(text: s),
            maxLines: 1,
            textDirection: TextDirection.ltr)
          ..layout(maxWidth: double.maxFinite);

        final check = ValueNotifier(true);
        return WidgetSpan(
            child: ValueListenableBuilder(
          valueListenable: check,
          builder: (context, _, __) {
            return TextFormField(
              autofocus: true,
              focusNode: focusNode,
              keyboardType: TextInputType.text,
              onChanged: (input) {
                tip.value = defaultTip;
                if (input.contains(RegExp(r'\s+'))) {
                  inputController.text = input.replaceAll(RegExp(r'\s+'), '');
                  final answer = verifyAnswer(s, matches);
                  if (answer == 'Correct') {
                    Navigator.of(context).popAndPushNamed(
                        AppRoute.entryVocabulary,
                        result: AppRoute.cloze);
                  } else {
                    tip.value = answer;
                  }
                }
                check.value = s.contains(RegExp(inputController.text));
              },
              style: TextStyle(
                  color: check.value ? colorScheme.primary : colorScheme.error),
              onFieldSubmitted: (_) {
                focusNode.requestFocus();
                final answer = verifyAnswer(s, matches);
                if (answer == 'Correct') {
                  Navigator.of(context).popAndPushNamed(
                      AppRoute.entryVocabulary,
                      result: AppRoute.cloze);
                } else {
                  tip.value = answer;
                }
              },
              controller: inputController,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(bottom: 4, left: 4),
                  constraints: BoxConstraints.tightFor(
                      width: wordPainter.width * 1.6,
                      height: wordPainter.height * 2)),
            );
          },
        ));
      }
      return TextSpan(text: s);
    }).toList();
  }

  String verifyAnswer(String correctWord, Iterable<String> matches) {
    if (inputController.text.toLowerCase() == correctWord.toLowerCase()) {
      MyDB().updateAcquaintance(
          wordId: widget.word.wordId, acquaint: ++widget.word.acquaint);
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
