import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../mock_data.dart';
import '../widgets/align_paragraph.dart';
import '../widgets/definition_tile.dart';

class RetrievalBottomSheet extends StatefulWidget {
  const RetrievalBottomSheet({
    super.key,
  });

  @override
  State<RetrievalBottomSheet> createState() => _RetrievalBottomSheetState();
}

class _RetrievalBottomSheetState extends State<RetrievalBottomSheet> {
  late final futureWords = Future.delayed(
    Duration(milliseconds: 500),
    () => apple,
  );

  @override
  Widget build(BuildContext context) {
    final hPadding = MediaQuery.of(context).size.width / 16;
    final screenHeight = MediaQuery.of(context).size.height;
    return DraggableScrollableSheet(
      expand: false,
      snap: true,
      minChildSize: .12,
      maxChildSize: .9,
      snapSizes: const [.32, .9],
      initialChildSize: .32,
      builder: (context, scrollController) => PlatformWidgetBuilder(
        material: (_, child, ___) => child,
        cupertino: (_, child, ___) => Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16)),
            child: child),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sheetHeight = constraints.maxHeight;
            final scale =
                ((sheetHeight - .32 * screenHeight) / (.9 - .32) / screenHeight)
                    .clamp(0.0, 1.0);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  controller: scrollController,
                  physics: const ClampingScrollPhysics(),
                  child: Container(
                    height: 32,
                    padding: EdgeInsets.only(
                        top: 16, right: hPadding / 2, left: hPadding / 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(),
                        const Icon(CupertinoIcons.chevron_up_chevron_down),
                        GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Icon(CupertinoIcons.xmark_circle_fill)),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: hPadding),
                    child: FutureBuilder(
                      future: futureWords,
                      builder: (context, snapshot) {
                        final words = snapshot.data;
                        if (words == null)
                          return Center(
                              child: PlatformCircularProgressIndicator());

                        return MatchingWordPage(
                          word: words,
                          hPadding: hPadding,
                          buildExamples: (_) => Container(
                            height: scale < .05 ? 0 : null,
                            child: Transform.scale(
                              alignment: Alignment.topCenter,
                              scaleY: scale,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (final definition in words.definitions)
                                      if (definition.explanations
                                          .map((e) => e.examples)
                                          .reduce((e1, e2) => e1 + e2)
                                          .isNotEmpty) ...[
                                        PartOfSpeechTitle(
                                          definition: definition,
                                        ),
                                        const Divider(height: 4),
                                        for (final explain
                                            in definition.explanations)
                                          ...explain.examples.map(
                                            (example) => ExampleParagraph(
                                                example: example,
                                                inflection:
                                                    words.getInflection),
                                          ),
                                      ]
                                  ]),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

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
                child: FadeTransition(opacity: animation, child: child)),
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

class PartOfSpeechTitle extends StatelessWidget {
  const PartOfSpeechTitle({
    super.key,
    required this.definition,
  });

  final Definition definition;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(definition.partOfSpeech,
            style: textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
        if (definition.phoneticUk != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🇬🇧${definition.phoneticUk!}', style: textTheme.bodyLarge),
              PlatformWidgetBuilder(
                material: (_, child, __) => InkWell(onTap: () {}, child: child),
                cupertino: (_, child, __) =>
                    GestureDetector(onTap: () {}, child: child),
                child: Icon(CupertinoIcons.volume_up,
                    size: textTheme.bodyLarge!.fontSize),
              ),
            ],
          ),
        if (definition.phoneticUs != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🇺🇸${definition.phoneticUs!}', style: textTheme.bodyLarge),
              PlatformWidgetBuilder(
                material: (_, child, __) => InkWell(onTap: () {}, child: child),
                cupertino: (_, child, __) =>
                    GestureDetector(onTap: () {}, child: child),
                child: Icon(CupertinoIcons.volume_up,
                    size: textTheme.bodyLarge!.fontSize),
              ),
            ],
          ),
      ],
    );
  }
}
