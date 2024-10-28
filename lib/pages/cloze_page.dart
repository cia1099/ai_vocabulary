import 'dart:math';

import 'package:ai_vocabulary/utils/regex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../mock_data.dart';

class ClozePage extends StatelessWidget {
  ClozePage({super.key});

  final defaultTip = 'Press enter or space to submit answer';
  late final tip = ValueNotifier(defaultTip);
  final inputController = TextEditingController();
  final rng = Random();
  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final word = record;
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
    WidgetsBinding.instance
        .addPostFrameCallback((_) => focusNode.requestFocus());

    final textTheme = Theme.of(context).textTheme;
    final hPadding = MediaQuery.of(context).size.width / 16;
    return PlatformScaffold(
      appBar: PlatformAppBar(),
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.symmetric(horizontal: hPadding),
        child: Wrap(
          direction: Axis.vertical,
          spacing: hPadding,
          children: [
            Container(
              // color: Colors.red,
              width: hPadding * 14,
              child: Text(explain,
                  style: textTheme.bodyLarge!
                      .copyWith(fontWeight: FontWeight.bold, height: 1.25)),
            ),
            Container(
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
                color: CupertinoColors.systemGrey6.withOpacity(.8),
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
                                : CupertinoColors.destructiveRed),
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
      if (matches.contains(s)) {
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
                  tip.value = verifyAnswer(s, matches);
                }
                check.value = s.contains(RegExp(inputController.text));
              },
              style: TextStyle(
                  color: check.value ? colorScheme.primary : colorScheme.error),
              onFieldSubmitted: (_) {
                tip.value = verifyAnswer(s, matches);
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
    if (inputController.text == correctWord) return "Correct";
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
