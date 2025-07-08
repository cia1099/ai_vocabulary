import 'package:ai_vocabulary/api/dict_api.dart';
import 'package:ai_vocabulary/app_settings.dart';
import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:ai_vocabulary/utils/function.dart';
import 'package:ai_vocabulary/widgets/entry_actions.dart';
import 'package:ai_vocabulary/widgets/inline_paragraph.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/shortcut.dart';
import '../../widgets/align_paragraph.dart';

class MatchingWordView extends StatefulWidget {
  const MatchingWordView({
    super.key,
    required this.word,
    required this.hPadding,
    this.buildExamples,
  });

  final Vocabulary word;
  final double hPadding;
  final Widget Function(BuildContext)? buildExamples;

  @override
  State<MatchingWordView> createState() => _MatchingWordViewState();
}

class _MatchingWordViewState extends State<MatchingWordView> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: widget.word.word,
                children: [
                  TextSpan(text: '\t' * 2),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () => soundGTTs(
                        widget.word.word,
                        AppSettings.of(context).accent.gTTS,
                      ),
                      child: Icon(
                        CupertinoIcons.volume_up,
                        size: textTheme.titleLarge?.fontSize?.scale(1.25),
                      ),
                    ),
                  ),
                ],
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Wrap(
              spacing: widget.hPadding / 4,
              children: widget.word.getInflection
                  .map(
                    (e) => Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.secondary),
                        borderRadius: BorderRadius.circular(
                          textTheme.labelMedium?.fontSize ?? 24,
                        ),
                      ),
                      child: Text(
                        e,
                        style: textTheme.labelMedium?.apply(
                          color: colorScheme.secondary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: widget.hPadding / 4),
            ExplanationBoard(word: widget.word, hPadding: widget.hPadding),
            SizedBox(height: widget.hPadding),
            ?widget.buildExamples?.call(context),
          ],
        ),
      ),
    );
  }
}

class ExplanationBoard extends StatefulWidget {
  const ExplanationBoard({
    super.key,
    required this.word,
    required this.hPadding,
  });
  final Vocabulary word;
  final double hPadding;

  @override
  State<ExplanationBoard> createState() => _ExplanationBoardState();
}

class _ExplanationBoardState extends State<ExplanationBoard> {
  late var selected = AppSettings.of(context).defaultExplanation;
  final unselectColor = CupertinoDynamicColor.withBrightness(
    color: CupertinoColors.systemFill.highContrastColor,
    darkColor: CupertinoColors.systemFill.darkHighContrastColor,
  );
  @override
  Widget build(BuildContext context) {
    final textTheme = CupertinoTheme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Wrap(
              spacing: widget.hPadding,
              children: [
                for (final s in SelectExplanation.values)
                  GestureDetector(
                    onTap: () {
                      if (selected != s) {
                        setState(() {
                          selected = s;
                        });
                      }
                    },
                    child: selected == s
                        ? HighlineText(
                            s.type,
                            style: textTheme.navTitleTextStyle,
                          )
                        : Text(
                            s.type,
                            style: textTheme.navTitleTextStyle.copyWith(
                              color: unselectColor.resolveFrom(context),
                            ),
                          ),
                  ),
              ],
            ),
            FractionalTranslation(
              translation: Offset(0, -.1),
              child: FavoriteStar(wordID: widget.word.wordId, size: 30),
            ),
          ],
        ),
        // SizedBox(height: widget.hPadding / 8),
        AnimatedSwitcher(
          duration: Durations.short4,
          transitionBuilder: (child, animation) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: ScaleTransition(scale: animation, child: child),
          ),
          child: Column(
            key: ValueKey(selected.index),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selected == SelectExplanation.translation)
                ...translationPanelComponents(textTheme),
              if (selected == SelectExplanation.explanation)
                for (final definition in widget.word.definitions)
                  AlignParagraph.text(
                    mark:
                        Text(
                          definition.partOfSpeech,
                          style: textTheme.textStyle.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ).coloredSpeech(
                          context: context,
                          isShortcut: true,
                          length: 4,
                        ),
                    paragraph: definition.index2Explanation(),
                    xInterval: widget.hPadding / 4,
                    paragraphStyle: textTheme.textStyle,
                  ),
            ],
          ),
        ),
      ],
    );
  }

  Iterable<Widget> translationPanelComponents(
    CupertinoTextThemeData textTheme,
  ) sync* {
    for (final definition in widget.word.definitions) {
      final speechText = Text(
        definition.partOfSpeech,
        style: textTheme.textStyle.copyWith(fontWeight: FontWeight.bold),
      ).coloredSpeech(context: context, isShortcut: true, length: 4);

      if (definition.translate != null) {
        yield AlignParagraph.text(
          mark: speechText,
          paragraph: definition.translate!,
          xInterval: widget.hPadding / 4,
          paragraphStyle: textTheme.textStyle,
        );
      }
      if (definition.synonyms != null) {
        yield AlignParagraph.text(
          mark: BoxText(
            text: "syn.",
            color: speechText.style?.color,
            style: textTheme.actionTextStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          xInterval: widget.hPadding / 4,
          paragraph: definition.synonyms!.replaceAll(', ', ' / '),
          paragraphStyle: textTheme.textStyle,
        );
      }
      if (definition.antonyms != null) {
        yield AlignParagraph.text(
          mark: BoxText(
            text: "ant.",
            color: speechText.style?.color,
            style: textTheme.actionTextStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          xInterval: widget.hPadding / 4,
          paragraph: definition.antonyms!.replaceAll(', ', ' / '),
          paragraphStyle: textTheme.textStyle,
        );
      }
    }
  }
}

enum SelectExplanation {
  translation("translation"),
  explanation("explanation");

  final String type;
  const SelectExplanation(this.type);
}

class HighlineText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  const HighlineText(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            colorScheme.inversePrimary,
            colorScheme.inversePrimary,
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [.6, .61, .85, .86],
        ),
      ),
      child: Text(text, style: style),
    );
  }
}
