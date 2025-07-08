import 'dart:async';

import 'package:ai_vocabulary/app_settings.dart';
import 'package:ai_vocabulary/utils/handle_except.dart';
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../api/dict_api.dart';
import '../effects/dot2loader.dart';
import '../effects/transient.dart';
import '../model/vocabulary.dart';

class SliderTitle extends StatefulWidget {
  const SliderTitle({super.key, required this.word});

  final Vocabulary word;
  @override
  State<SliderTitle> createState() => SliderTitleState();
}

class SliderTitleState extends State<SliderTitle>
    with AutomaticKeepAliveClientMixin {
  var streamSyllables = Stream.value(<Syllable>[]);
  var isCorrect = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      alignment: const Alignment(0, -1),
      children: [
        Wrap(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.spaceEvenly,
          children: [
            Container(
              alignment: Alignment(0, 0),
              child: Text(
                widget.word.word,
                style: textTheme.displayMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: widget.word.getInflection
                  .map(
                    (e) => Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(
                          textTheme.bodyMedium!.fontSize!,
                        ),
                      ),
                      child: Text(
                        e,
                        style: TextStyle(color: colorScheme.onPrimaryContainer),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        if (AppSettings.of(context).hideSliderTitle)
          AnimatedOpacity(
            duration: Durations.extralong1,
            opacity: isCorrect ? .0 : 1.0,
            child: const CupertinoPopupSurface(
              isSurfacePainted: false,
              child: Center(),
            ),
          ),
        Center(
          child: StreamBuilder<List<Syllable>>(
            stream: streamSyllables,
            builder: (context, snapshot) {
              Widget content;
              if (snapshot.connectionState == ConnectionState.waiting) {
                content = const Wrap(
                  direction: Axis.vertical,
                  spacing: 32,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [TwoDotLoader(), Text('Check pronunciation...')],
                );
              } else if (snapshot.hasError) {
                content = Text(
                  messageExceptions(snapshot.error),
                  key: const Key('error'),
                  style: TextStyle(
                    color: colorScheme.error,
                    backgroundColor: kCupertinoSheetColor.resolveFrom(context),
                  ),
                );
              } else {
                content = _tackleRecognition(
                  snapshot.data,
                  textTheme,
                  colorScheme,
                );
              }
              return AnimatedSwitcher(
                duration: Durations.medium1,
                transitionBuilder: (child, animation) =>
                    CupertinoDialogTransition(
                      animation: animation,
                      child: child,
                    ),
                child: content,
              );
            },
          ),
        ),
      ],
    );
  }

  void inputSpeech(List<int> bytes) {
    setState(() {
      streamSyllables = () async* {
        yield await pronunciationWord(bytes: bytes, word: widget.word.word);
        await Future.delayed(Durations.extralong4 * 2);
        yield <Syllable>[];
      }();
    });
  }

  Widget _tackleRecognition(
    List<Syllable>? syllables,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    if (syllables == null) {
      return Text(
        "Sorry we can't recognize your speech",
        key: const Key('failure'),
        style: textTheme.bodyLarge?.apply(
          color: CupertinoDynamicColor.withBrightness(
            color: colorScheme.onErrorContainer,
            darkColor: colorScheme.onError,
          ).resolveFrom(context),
          backgroundColor: kCupertinoSheetColor.resolveFrom(context),
        ),
      );
    }
    final avgScore =
        syllables.map((s) => s.score).fold(.0, (a, b) => a + b) /
        syllables.length.clamp(1, 100);
    if (avgScore > .74) {
      if (!wantKeepAlive && AppSettings.of(context).hideSliderTitle) {
        SchedulerBinding.instance.scheduleTask(() {
          if (mounted) {
            setState(() {
              isCorrect = true;
            });
            updateKeepAlive();
          }
        }, Priority.idle);
      }
    }

    final colorTween = ColorTween(
      begin: colorScheme.error,
      end: CupertinoColors.systemGreen.resolveFrom(context),
    );
    return Wrap(
      key: Key('result'),
      children: [
        for (final entry in syllables.asMap().entries) ...[
          Column(
            children: [
              Text(
                entry.value.grapheme,
                style: textTheme.displayMedium?.apply(
                  color: colorTween.lerp(entry.value.score),
                ),
              ),
              Text(
                entry.value.score.toStringAsFixed(2),
                style: textTheme.bodySmall?.apply(
                  color: colorTween.lerp(entry.value.score),
                  heightDelta: -1,
                ),
              ),
            ],
          ),
          if (entry.key < syllables.length - 1)
            Text(
              "\\",
              style: textTheme.displaySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w100,
              ),
            ),
        ],
      ],
    );
  }

  @override
  bool get wantKeepAlive => isCorrect;
}
