import 'dart:math';

import 'package:ai_vocabulary/app_route.dart';
import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/model/acquaintance.dart';
import 'package:ai_vocabulary/widgets/capital_avatar.dart';
import 'package:ai_vocabulary/widgets/entry_actions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../model/vocabulary.dart';
import '../widgets/definition_sliders.dart';
import '../widgets/definition_tile.dart';
import '../widgets/remember_retention.dart';

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
  Acquaintance? acquaintance;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final hPadding = screenWidth / 32;
    final phonetics = widget.word.getPhonetics();
    var defSliderHeight = DefinitionSliders.kDefaultHeight;
    if (acquaintance == null) {
      acquaintance = Acquaintance(
          wordId: widget.word.wordId,
          acquaint: widget.word.acquaint,
          lastLearnedTime: widget.word.lastLearnedTime);
    } else {
      acquaintance = MyDB().getAcquaintance(widget.word.wordId);
    }
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
                          LearnedLabel(
                            lastLearnedTime: acquaintance?.lastLearnedTime,
                          ),
                          Text(
                            widget.word.word,
                            style: textTheme.displayMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
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
                onPressed: () => Navigator.pushNamed(context, AppRoute.cloze),
                icon: Icon(CupertinoIcons.square_arrow_right_fill,
                    color: colorScheme.onSurfaceVariant),
                label: Text('Go to quiz',
                    style: TextStyle(color: colorScheme.onSurfaceVariant)),
              ),
              const PhoneticButton(height: 110),
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
        Align(
          alignment: const Alignment(1, .25),
          child: FractionallySizedBox(
            widthFactor: .16,
            child: AspectRatio(
              aspectRatio: 1,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoute.cloze),
                child: RememberRetention(acquaintance: acquaintance),
              ),
            ),
          ),
        ),
        Align(
          alignment: const Alignment(.95, 1),
          child: FractionallySizedBox(
            widthFactor: .12,
            // heightFactor: .36,
            child: wordActions(),
          ),
        )
      ],
    );
  }

  LayoutBuilder wordActions() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final iconSize = width * .9;
        return Container(
          // color: Colors.grey,
          margin: const EdgeInsets.only(bottom: kFloatingActionButtonMargin),
          child: Wrap(
            alignment: WrapAlignment.end,
            runSpacing: 8,
            children: [
              PlatformIconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/shit');
                },
                padding: EdgeInsets.zero,
                icon: Transform.flip(
                  flipX: true,
                  child: Icon(
                    CupertinoIcons.captions_bubble,
                    size: iconSize,
                  ),
                ),
                material: (_, __) => MaterialIconButtonData(
                    style: IconButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap)),
              ),
              FavoriteStar(wordID: widget.word.wordId, size: iconSize),
              PlatformIconButton(
                onPressed: () => Navigator.pushNamed(context, AppRoute.report),
                padding: EdgeInsets.zero,
                icon: Transform(
                    alignment: const Alignment(0, 0),
                    transform: Matrix4.rotationY(pi),
                    child: Icon(CupertinoIcons.reply, size: iconSize)),
                material: (_, __) => MaterialIconButtonData(
                    style: IconButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap)),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoute.vocabulary),
                child: CapitalAvatar(
                  name: widget.word.word,
                  id: widget.word.wordId,
                  url: widget.word.asset,
                  size: iconSize,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class PhoneticButton extends StatefulWidget {
  const PhoneticButton({
    super.key,
    required this.height,
  });

  final double height;

  @override
  State<PhoneticButton> createState() => _PhoneticButtonState();
}

class _PhoneticButtonState extends State<PhoneticButton> {
  var isPress = false;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final strokeColor = CupertinoDynamicColor.withBrightness(
            color: colorScheme.secondaryContainer,
            darkColor: colorScheme.secondary)
        .resolveFrom(context);
    final height = widget.height;
    return GestureDetector(
      onTapDown: (details) {
        setState(() => isPress = true);
      },
      onTapUp: (details) {
        setState(() => isPress = false);
      },
      child: AnimatedContainer(
        duration: Durations.long2,
        width: 200,
        height: height,
        decoration: BoxDecoration(
            color: !isPress ? colorScheme.surfaceContainer : null,
            borderRadius: BorderRadius.circular(kRadialReactionRadius)),
        child: Stack(
          alignment: const Alignment(0, 0),
          children: [
            // const SpeakRipple(progress: 1, diameter: height),
            AnimatedPhysicalModel(
              duration: Durations.long2,
              color: strokeColor,
              animateColor: false,
              shadowColor: colorScheme.inverseSurface,
              elevation: !isPress ? 4 : 1,
              shape: BoxShape.circle,
              child: CircleAvatar(
                radius: height * .6 / 2,
                backgroundColor: colorScheme.inversePrimary,
                child: Icon(
                  Icons.mic,
                  size: height * .4,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            if (!isPress)
              const Positioned(
                  bottom: 0, child: Text('Press to speak out word')),
          ],
        ),
      ),
    );
  }
}
