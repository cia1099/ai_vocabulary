import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:flutter/material.dart';

import '../utils/shortcut.dart';
import '../widgets/align_paragraph.dart';

class MatchingWordPage extends StatelessWidget {
  const MatchingWordPage({
    super.key,
    required this.word,
    required this.hPadding,
    this.buildExamples,
  });

  final Vocabulary word;
  final double hPadding;
  final Widget Function(BuildContext)? buildExamples;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
            //PageView a word
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(word.word,
                  style: textTheme.titleLarge!
                      .copyWith(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: hPadding / 4,
                children: word.getInflection
                    .map((e) => Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 4),
                          decoration: BoxDecoration(
                              border: Border.all(color: colorScheme.secondary),
                              borderRadius: BorderRadius.circular(
                                  textTheme.labelMedium!.fontSize!)),
                          child: Text(e,
                              style: textTheme.labelMedium!
                                  .apply(color: colorScheme.secondary)),
                        ))
                    .toList(),
              ),
              SizedBox(height: hPadding / 4),
              ExplanationBoard(word: word, hPadding: hPadding),
              SizedBox(height: hPadding),
              if (buildExamples != null) buildExamples!(context)
            ]));
  }
}

class ExplanationBoard extends StatefulWidget {
  const ExplanationBoard(
      {super.key, required this.word, required this.hPadding});
  final Vocabulary word;
  final double hPadding;

  @override
  State<ExplanationBoard> createState() => _ExplanationBoardState();
}

class _ExplanationBoardState extends State<ExplanationBoard> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final selection = ["translation", "explanation"];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
            spacing: widget.hPadding,
            children: List.generate(selection.length, (i) {
              final text = selection[i];
              return GestureDetector(
                  onTap: () {
                    if (selectedIndex != i) {
                      selectedIndex = i;
                      setState(() {});
                    }
                  },
                  child: selectedIndex == i ? HighlineText(text) : Text(text));
            })),
        SizedBox(height: widget.hPadding / 8),
        AnimatedSwitcher(
            duration: Durations.short4,
            transitionBuilder: (child, animation) => SlideTransition(
                position:
                    Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
                        .animate(animation),
                child: ScaleTransition(scale: animation, child: child)),
            child: Column(
              key: ValueKey(selectedIndex),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedIndex == 0)
                  for (final definition in widget.word.definitions)
                    if (definition.translate != null)
                      AlignParagraph(
                        markWidget: Text(
                          speechShortcut[definition.partOfSpeech] ??
                              '${definition.partOfSpeech.substring(0, 3)}.',
                          style: textTheme.titleMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        paragraph: Text(definition.translate!),
                        xInterval: widget.hPadding / 4,
                      ),
                if (selectedIndex == 1)
                  for (final definition in widget.word.definitions)
                    AlignParagraph(
                      markWidget: Text(
                        speechShortcut[definition.partOfSpeech] ??
                            '${definition.partOfSpeech.substring(0, 3)}.',
                        style: textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      paragraph: Text(definition.explanations
                          .map((e) => e.explain)
                          .reduce((e1, e2) => e1.length < e2.length ? e1 : e2)),
                      xInterval: widget.hPadding / 4,
                    ),
              ],
            )),
      ],
    );
  }
}

class HighlineText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  const HighlineText(
    this.text, {
    super.key,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
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
        stops: [.6, .61, .85, .86],
      )),
      child: Text(text, style: style),
    );
  }
}
