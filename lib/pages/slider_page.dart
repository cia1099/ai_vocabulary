import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:im_charts/im_charts.dart';

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
              Wrap(
                spacing: screenWidth / 12,
                children: [
                  TextButton(
                    onPressed: () {
                      // MyDB.instance
                      //     .updateAcquaintance(wordId: word.wordId, acquaint: 0);
                      // // Navigator.of(context)
                      // //     .pushNamed(AppRoute.SliderPageVocabulary);
                      // pushNamed(context, AppRoute.SliderPageVocabulary);
                    },
                    style: TextButton.styleFrom(
                        fixedSize: Size.square(screenWidth / 3),
                        backgroundColor: colorScheme.secondaryContainer
                            .withValues(alpha: .8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                    child: Text(
                      "Unknown",
                      style:
                          textTheme.titleLarge!.apply(color: colorScheme.error),
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
                        backgroundColor: colorScheme.secondaryContainer
                            .withValues(alpha: .8),
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
          ),
        ),
        const Align(
          alignment: Alignment(1, .95),
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
            heightFactor: .4,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return Container(
                  // color: Colors.grey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: 16,
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      PlatformIconButton(
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          CupertinoIcons.star,
                          size: width * .9,
                        ),
                        material: (_, __) => MaterialIconButtonData(
                            style: IconButton.styleFrom(
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap)),
                      ),
                      PlatformIconButton(
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          CupertinoIcons.captions_bubble,
                          size: width * .9,
                        ),
                        material: (_, __) => MaterialIconButtonData(
                            style: IconButton.styleFrom(
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap)),
                      ),
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
                      // SizedBox.square(dimension: width * .9)
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
