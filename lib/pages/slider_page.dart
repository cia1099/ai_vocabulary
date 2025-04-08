import 'dart:math';
import 'dart:typed_data';

import 'package:ai_vocabulary/app_route.dart';
import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/model/acquaintance.dart';
import 'package:ai_vocabulary/utils/phonetic.dart' show playPhonetic;
import 'package:ai_vocabulary/widgets/capital_avatar.dart';
import 'package:ai_vocabulary/widgets/entry_actions.dart';
import 'package:ai_vocabulary/widgets/slider_title.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:speech_record/speech_record.dart';
import 'package:text2speech/text2speech.dart';

import '../model/vocabulary.dart';
import '../widgets/definition_sliders.dart';
import '../widgets/remember_retention.dart';

class SliderPage extends StatefulWidget {
  const SliderPage({required Key key, required this.word}) : super(key: key);

  final Vocabulary word;

  @override
  State<SliderPage> createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {
  Acquaintance? acquaintance;
  late final titleKey = GlobalObjectKey<SliderTitleState>(widget.key!);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final hPadding = screenWidth / 32;
    final phonetics = widget.word.getPhonetics();
    var defSliderHeight = DefinitionSliders.kDefaultHeight;
    if (acquaintance == null) {
      acquaintance = Acquaintance(
        wordId: widget.word.wordId,
        acquaint: widget.word.acquaint,
        lastLearnedTime: widget.word.lastLearnedTime,
      );
    } else {
      acquaintance = MyDB().getAcquaintance(widget.word.wordId);
      widget.word.acquaint = acquaintance!.acquaint;
      widget.word.lastLearnedTime = acquaintance!.lastLearnedTime;
    }
    final labelHeight =
        textTheme.bodyMedium!.fontSize! * textTheme.bodyMedium!.height! + 10;
    final dH = acquaintance?.lastLearnedTime == null ? .0 : labelHeight;
    // final textbutton = TextButton.icon(
    //   onPressed: () {},
    //   label: const Text('123'),
    // ).defaultStyleOf(context).minimumSize?.resolve({WidgetState.hovered});
    // final remainHeight = MediaQuery.sizeOf(context).height -
    //     250 -
    //     kToolbarHeight -
    //     116 -
    //     hPadding -
    //     80 -
    //     DefinitionSliders.kDefaultHeight -
    //     textbutton!.height;
    // print(textbutton);
    // print('remain height = $remainHeight');
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: 100 + hPadding + 16,
            left: hPadding,
            right: hPadding,
          ),
          child: Column(
            children: [
              //#begin height=250
              LearnedLabel(lastLearnedTime: acquaintance?.lastLearnedTime),
              Container(
                // color: Colors.green,
                constraints: BoxConstraints.tightFor(height: 250 - 80 - dH),
                child: SliderTitle(key: titleKey, word: widget.word),
              ),
              Container(
                // color: Colors.red,
                height: 80,
                alignment: const Alignment(0, 0),
                child: Wrap(
                  children:
                      phonetics
                          .map(
                            (p) => RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(text: '\t' * 4),
                                  TextSpan(text: p.phonetic),
                                  TextSpan(text: '\t' * 2),
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: playPhonetic(
                                        p.audioUrl,
                                        word: widget.word.word,
                                      ),
                                      child: const Icon(
                                        CupertinoIcons.volume_up,
                                      ),
                                    ),
                                  ),
                                ],
                                style: textTheme.titleLarge,
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
              //#end height=250
              TextButton.icon(
                style: TextButton.styleFrom(
                  // foregroundColor: colorScheme.onSurfaceVariant,
                  backgroundColor: colorScheme.surfaceContainer,
                ),
                onPressed: () => Navigator.pushNamed(context, AppRoute.quiz),
                icon: Icon(
                  CupertinoIcons.square_arrow_right_fill,
                  color: colorScheme.onSurfaceVariant,
                ),
                label: Text(
                  'Go to quiz',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
              // const Expanded(child: SizedBox()),
            ],
          ),
        ),
        Positioned(
          bottom:
              DefinitionSliders.kDefaultHeight +
              kFloatingActionButtonMargin * 1.6,
          left: (screenWidth - 105 * 1.82) / 2,
          right: (screenWidth - 105 * 1.82) / 2,
          child: PhoneticButton(
            height: 105,
            startRecordHint:
                () => immediatelyPlay(
                  'assets/sounds/speech_to_text_listening.m4r',
                ),
            doneRecord: (bytes) {
              bytesPlay(Uint8List.fromList(bytes), 'audio/wav');
              titleKey.currentState?.inputSpeech(bytes);
            },
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
                getMore:
                    (h) => setState(() {
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
                onTap: () => Navigator.pushNamed(context, AppRoute.quiz),
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
        ),
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
                  child: Icon(CupertinoIcons.captions_bubble, size: iconSize),
                ),
                material:
                    (_, __) => MaterialIconButtonData(
                      style: IconButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
              ),
              FavoriteStar(wordID: widget.word.wordId, size: iconSize),
              PlatformIconButton(
                onPressed: () => Navigator.pushNamed(context, AppRoute.report),
                padding: EdgeInsets.zero,
                icon: Transform(
                  alignment: const Alignment(0, 0),
                  transform: Matrix4.rotationY(pi),
                  child: Icon(CupertinoIcons.reply, size: iconSize),
                ),
                material:
                    (_, __) => MaterialIconButtonData(
                      style: IconButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoute.vocabulary),
                child: CapitalAvatar(
                  name: widget.word.word,
                  id: widget.word.wordId,
                  url: widget.word.asset,
                  size: iconSize,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
