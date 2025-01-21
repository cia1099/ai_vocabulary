import 'dart:math';
import 'package:ai_vocabulary/utils/clickable_text_mixin.dart';
import 'package:ai_vocabulary/utils/regex.dart';
import 'package:ai_vocabulary/widgets/capital_avatar.dart';
import 'package:ai_vocabulary/widgets/entry_actions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:im_charts/im_charts.dart';

import '../bottom_sheet/retrieval_bottom_sheet.dart';
import '../model/vocabulary.dart';
import '../widgets/definition_tile.dart';

class SliderPage extends StatefulWidget {
  const SliderPage({
    super.key,
    required this.word,
  });

  final Vocabulary word;

  @override
  State<SliderPage> createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final hPadding = screenWidth / 32;
    final phonetics = widget.word.getPhonetics();
    var defSliderHeight = DefinitionSliders.kDefaultHeight;
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(
              top: 100 + hPadding, left: hPadding, right: hPadding),
          child: Column(
            children: [
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
                                border:
                                    Border.all(color: colorScheme.onSurface)),
                            child: const Text("Learned 3 month ago"),
                          ),
                          Text(widget.word.word,
                              style: textTheme.displayMedium),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: widget.word.getInflection
                                .map((e) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 8),
                                      decoration: BoxDecoration(
                                          color: colorScheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(
                                              textTheme.bodyMedium!.fontSize!)),
                                      child: Text(e,
                                          style: TextStyle(
                                              color: colorScheme
                                                  .onPrimaryContainer)),
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
                                              word: widget.word.word),
                                          child: const Icon(
                                              CupertinoIcons.volume_up)))
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
                  // //     .pushNamed(AppRoute.SliderPageVocabulary);
                  // pushNamed(context, AppRoute.SliderPageVocabulary);
                },
                icon: Icon(CupertinoIcons.trash,
                    color: colorScheme.onSurfaceVariant),
                label: Text('Mark as too easy',
                    style: TextStyle(color: colorScheme.onSurfaceVariant)),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
        StatefulBuilder(
          builder: (context, setState) {
            return AnimatedPositioned(
              bottom: kFloatingActionButtonMargin * 1.6,
              duration: Durations.short2,
              height: defSliderHeight,
              width: screenWidth * .85,
              child: DefinitionSliders(
                definitions: widget.word.definitions,
                getMore: (h) => setState(() {
                  defSliderHeight = h;
                }),
              ),
            );
          },
        ),
        const Align(
          alignment: Alignment(1, .25),
          child: FractionallySizedBox(
            widthFactor: .16,
            child: AspectRatio(
              aspectRatio: 1,
              child: ImPieChart(
                percentage: .3,
              ),
            ),
          ),
        ),
        Align(
          alignment: const Alignment(.95, 1),
          child: FractionallySizedBox(
            widthFactor: .12,
            // heightFactor: .36,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return Container(
                  // color: Colors.grey,
                  margin: const EdgeInsets.only(
                      bottom: kFloatingActionButtonMargin),
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    runSpacing: 8,
                    children: [
                      PlatformIconButton(
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        icon: Transform(
                          alignment: const Alignment(0, 0),
                          transform: Matrix4.rotationY(pi),
                          child: Icon(
                            CupertinoIcons.captions_bubble,
                            size: width * .9,
                          ),
                        ),
                        material: (_, __) => MaterialIconButtonData(
                            style: IconButton.styleFrom(
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap)),
                      ),
                      FavoriteStar(
                          wordID: widget.word.wordId, size: width * .9),
                      PlatformIconButton(
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        icon: Transform(
                            alignment: const Alignment(0, 0),
                            transform: Matrix4.rotationY(pi),
                            child:
                                Icon(CupertinoIcons.reply, size: width * .9)),
                        material: (_, __) => MaterialIconButtonData(
                            style: IconButton.styleFrom(
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap)),
                      ),
                      CapitalAvatar(
                        name: widget.word.word,
                        id: widget.word.wordId,
                        url: widget.word.asset,
                        size: width * .9,
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class DefinitionSliders extends StatefulWidget {
  const DefinitionSliders({
    super.key,
    required this.definitions,
    required this.getMore,
  });

  final List<Definition> definitions;
  final void Function(double requiredHeight) getMore;
  static const double kDefaultHeight = 100.0;

  @override
  State<DefinitionSliders> createState() => _DefinitionSlidersState();
}

class _DefinitionSlidersState extends State<DefinitionSliders>
    with TickerProviderStateMixin, ClickableTextStateMixin {
  late final tabController = widget.definitions.length > 1
      ? TabController(length: widget.definitions.length, vsync: this)
      : null;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      spacing: 4,
      children: [
        tabController != null
            ? RotatedBox(
                quarterTurns: 1,
                child: TabPageSelector(
                  controller: tabController,
                  selectedColor: Theme.of(context).colorScheme.primary,
                ),
              )
            : const SizedBox.square(dimension: 12),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final titleStyle =
                  textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600);
              final remainHeight = constraints.maxHeight -
                  (titleStyle.fontSize! * titleStyle.height!);
              final style = textTheme.bodyLarge!;
              final maxLines =
                  remainHeight ~/ (style.fontSize! * style.height!);
              return PageView.builder(
                scrollDirection: Axis.vertical,
                onPageChanged: (value) {
                  tabController?.animateTo(value);
                  widget.getMore(DefinitionSliders.kDefaultHeight);
                },
                itemBuilder: (context, index) {
                  final definition = widget.definitions[index];
                  final text = definition.index2Explanation();
                  final textPainter = TextPainter(
                      text: TextSpan(text: text, style: style),
                      maxLines: maxLines,
                      textDirection: TextDirection.ltr)
                    ..layout(maxWidth: constraints.maxWidth);
                  final overflowIndex =
                      textPainter.overflowIndex(constraints.maxWidth);
                  // print('overflow index = $overflowIndex');
                  // print('paint: ${textPainter.plainText}');
                  var splitText = text;
                  var remainText = '';
                  if (overflowIndex > 0) {
                    splitText = text.substring(0, overflowIndex - 9);
                    final lastSpace = splitText.lastIndexOf(' ');
                    remainText = splitText.substring(lastSpace);
                    splitText = splitText.substring(0, lastSpace);
                  }
                  return Stack(
                    children: [
                      SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(definition.partOfSpeech, style: titleStyle),
                            Text.rich(
                              TextSpan(children: [
                                ...clickableWords(splitText),
                                if (overflowIndex > 0) ...[
                                  TextSpan(text: '$remainText...'),
                                  TextSpan(
                                    text: 'more',
                                    style: style.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        requireFittingHeight(
                                            TextSpan(text: text, style: style),
                                            constraints.maxWidth);
                                      },
                                  )
                                ],
                              ]),
                              style: style,
                            )
                          ],
                        ),
                      ),
                      if (overflowIndex < 0 &&
                          constraints.maxHeight >
                              DefinitionSliders.kDefaultHeight)
                        Align(
                          alignment: const Alignment(1, 1),
                          child: PlatformTextButton(
                            onPressed: () {
                              widget.getMore(DefinitionSliders.kDefaultHeight);
                            },
                            alignment: const Alignment(1, 1),
                            padding: EdgeInsets.zero,
                            child: Text(
                              'hide',
                              style: style.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            material: (_, __) => MaterialTextButtonData(
                                style: TextButton.styleFrom(
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap)),
                          ),
                        )
                    ],
                  );
                },
                itemCount: widget.definitions.length,
              );
            },
          ),
        ),
      ],
    );
  }

  void requireFittingHeight(TextSpan text, double maxWidth) {
    final textPainter =
        TextPainter(text: text, textDirection: TextDirection.ltr)
          ..layout(maxWidth: maxWidth);
    final titleStyle = Theme.of(context)
        .textTheme
        .titleLarge!
        .copyWith(fontWeight: FontWeight.w600);
    widget.getMore(
        textPainter.height + titleStyle.fontSize! * titleStyle.height!);
  }

  @override
  void initState() {
    super.initState();
    onTap = <T>(word) => showPlatformModalSheet<T>(
          context: context,
          material: MaterialModalSheetData(
            useSafeArea: true,
            isScrollControlled: true,
          ),
          builder: (context) => RetrievalBottomSheet(queryWord: word),
        );
  }
}
