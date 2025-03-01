import 'dart:async';
import 'dart:math';

import 'package:ai_vocabulary/app_settings.dart';
import 'package:ai_vocabulary/utils/handle_except.dart';
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../api/dict_api.dart';
import '../effects/dot2loader.dart';
import '../effects/transient.dart';
import '../model/chat_answer.dart';
import '../model/vocabulary.dart';

class SliderTitle extends StatefulWidget {
  const SliderTitle({super.key, required this.word});

  final Vocabulary word;
  @override
  State<SliderTitle> createState() => SliderTitleState();
}

class SliderTitleState extends State<SliderTitle>
    with AutomaticKeepAliveClientMixin {
  var futureRecognize = Future.value(
    SpeechRecognition(text: '', recognize: true),
  );
  var isCorrect = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      alignment: const Alignment(0, -1),
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              widget.word.word,
              style: textTheme.displayMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children:
                  widget.word.getInflection
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
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                            ),
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
          child: StreamBuilder(
            stream: (future) async* {
              yield await future;
              await Future.delayed(Durations.extralong4 * 1.5);
              final empty = SpeechRecognition(text: '', recognize: true);
              futureRecognize = Future.value(empty);
              yield empty;
            }(futureRecognize),
            builder: (context, snapshot) {
              Widget content;
              if (snapshot.connectionState == ConnectionState.waiting) {
                content = const Wrap(
                  direction: Axis.vertical,
                  spacing: 32,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [TwoDotLoader(), Text('Speech Recognizing...')],
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
                transitionBuilder:
                    (child, animation) => CupertinoDialogTransition(
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
      futureRecognize = recognizeSpeechBytes(bytes);
    });
  }

  Widget _tackleRecognition(
    SpeechRecognition? sr,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    if (sr == null || !sr.recognize) {
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
    if (sr.text.isEmpty) return const Text('');

    final recognition = sr.text.toLowerCase().replaceAll(RegExp(r'[.,]'), '');
    final correct = widget.word.getMatchingPatterns.where(
      (w) => recognition.contains(w),
    );
    final correctColor = CupertinoColors.systemGreen.resolveFrom(context);
    if (correct.isNotEmpty) {
      if (!isCorrect && AppSettings.of(context).hideSliderTitle) {
        SchedulerBinding.instance.scheduleTask(() {
          if (mounted) {
            setState(() {
              isCorrect = true;
            });
            updateKeepAlive();
          }
        }, Priority.idle);
      }
      return Text(
        correct.first,
        key: const Key('correct'),
        style: textTheme.displayMedium?.apply(color: correctColor),
      );
    }

    final recognitions = recognition.split(' ');
    final differences = recognitions.map((w) => widget.word.differ(w));
    final bestMatch = recognitions.elementAt(
      differences.toList().indexWhere((d) => d == differences.reduce(min)),
    );
    return Text.rich(
      TextSpan(
        children: List.generate(widget.word.word.length, (i) {
          final word = widget.word.word;
          final char = i < bestMatch.length ? bestMatch[i] : '•';
          return TextSpan(
            text: char,
            style: TextStyle(
              color: word[i] == char ? correctColor : colorScheme.error,
            ),
          );
        }),
      ),
      key: const Key('wrong'),
      style: textTheme.displayMedium,
    );
  }

  @override
  bool get wantKeepAlive => isCorrect;
}
