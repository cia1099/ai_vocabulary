import 'package:ai_vocabulary/database/my_db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EntryActions extends StatefulWidget {
  const EntryActions({
    super.key,
    required this.wordID,
  });
  final int wordID;

  @override
  State<EntryActions> createState() => _EntryActionsState();
}

class _EntryActionsState extends State<EntryActions> {
  late final collectWord = MyDB.instance.getCollectWord(widget.wordID);
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        const Icon(CupertinoIcons.search),
        GestureDetector(
            onTap: toggleCollection,
            child: collectWord.collect
                ? const Icon(CupertinoIcons.star_fill,
                    color: CupertinoColors.systemYellow)
                : const Icon(CupertinoIcons.star)),
        const Icon(CupertinoIcons.ellipsis_vertical),
      ],
    );
  }

  void toggleCollection() {
    collectWord.collect ^= true;
    MyDB.instance
        .updateCollectWord(wordId: widget.wordID, collect: collectWord.collect);
    setState(() {});
  }
}

class NaiveSegment extends StatefulWidget {
  const NaiveSegment({
    super.key,
    required this.wordID,
  });

  final int wordID;

  @override
  State<NaiveSegment> createState() => _NaiveSegmentState();
}

class _NaiveSegmentState extends State<NaiveSegment> {
  late final collectWord = MyDB.instance.getCollectWord(widget.wordID);
  late int learned = collectWord.learned;
  String firstText = 'Unknown', secondText = 'Naive';

  @override
  void dispose() {
    MyDB().updateCollectWord(wordId: widget.wordID, learned: learned);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    firstText = learned == 0
        ? 'Learn in future'
        : learned < 5
            ? 'Unknown'
            : "Don't learn anymore";
    secondText = learned > 0 && learned < 5 ? 'Naive' : 'withdraw';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            GestureDetector(
                onTap: learned > 0 && learned < 5 ? resetLearned : null,
                child: Text.rich(
                    TextSpan(children: [
                      WidgetSpan(
                          child: Offstage(
                              offstage: firstText != 'Unknown',
                              child:
                                  const Icon(CupertinoIcons.escape, size: 16))),
                      const TextSpan(text: ' '),
                      TextSpan(text: firstText),
                    ]),
                    style: TextStyle(color: colorScheme.onPrimaryContainer))),
            SizedBox(
              height: 12,
              child: VerticalDivider(
                color: colorScheme.onSecondaryContainer,
                width: 8,
              ),
            ),
            GestureDetector(
                onTap: learned > 0 && learned < 5 ? setNaive : withdraw,
                child: Text.rich(
                  TextSpan(children: [
                    WidgetSpan(
                        child: Offstage(
                            offstage: secondText != 'Naive',
                            child:
                                const Icon(CupertinoIcons.smiley, size: 16))),
                    const TextSpan(text: ' '),
                    TextSpan(text: secondText),
                  ]),
                  style: TextStyle(
                      color: secondText != 'withdraw'
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.primary),
                ))
          ]),
    );
  }

  void resetLearned() {
    setState(() {
      learned = 0;
    });
  }

  void setNaive() {
    setState(() {
      learned = 5;
    });
  }

  void withdraw() {
    setState(() {
      if (collectWord.learned > 0 && collectWord.learned < 5) {
        learned = collectWord.learned;
      } else if (collectWord.learned == 0) {
        learned = (++collectWord.learned).clamp(0, 4);
      } else {
        learned = (--collectWord.learned).clamp(0, 4);
      }
    });
  }
}
