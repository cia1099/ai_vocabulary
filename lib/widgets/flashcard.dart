import 'dart:math';

import 'package:ai_vocabulary/bottom_sheet/edit_flashcard_sheet.dart';
import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/model/collections.dart';
import 'package:ai_vocabulary/utils/function.dart';
import 'package:ai_vocabulary/utils/load_word_route.dart';
import 'package:ai_vocabulary/utils/regex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../effects/pointer_down_physic.dart';
import '../effects/slide_appear.dart';
import '../pages/favorite_words_page.dart';
import '../utils/shortcut.dart';

class Flashcard extends StatefulWidget {
  final CollectionMark mark;
  final String filter;
  final bool dragEnabled;
  final void Function(CollectionMark)? onRemove;

  const Flashcard({
    super.key,
    required this.mark,
    this.filter = '',
    this.dragEnabled = false,
    this.onRemove,
  });

  @override
  State<Flashcard> createState() => _FlashcardState();
}

class _FlashcardState extends State<Flashcard>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    vsync: this,
    duration: Durations.short3,
    value: .5,
  );
  @override
  void dispose() {
    controller.stop();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dragEnabled) {
      startShaking();
    } else {
      stopShaking();
    }
    return AbsorbPointer(
      absorbing: widget.onRemove == null, // || widget.dragEnabled,
      child: CupertinoContextMenu(
        actions: contextActions(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 200, minHeight: 200),
          child: RotationTransition(
            turns: Tween<double>(
              begin: -pi / 512,
              end: pi / 512,
            ).animate(controller),
            child: OnPointerDownPhysic(
              child: Card(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: widget.mark.gradient(context),
                  ),
                  child: InkWell(
                    onTap: widget.dragEnabled
                        ? null
                        : () => Navigator.push(
                            context,
                            WordListRoute(
                              wordIDs: MyDB().fetchWordIDsByMarkID(
                                widget.mark.id,
                              ),
                              builder: (context, words) => FavoriteWordsPage(
                                mark: widget.mark,
                                words: words,
                              ),
                            ),
                          ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Stack(
                        fit: StackFit.passthrough,
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: FittedBox(
                              child: Icon(
                                widget.mark.icon != null
                                    ? IconData(
                                        widget.mark.icon!,
                                        fontFamily: 'CupertinoIcons',
                                        fontPackage: 'cupertino_icons',
                                      )
                                    : Icons.abc,
                                size: 24 * 3,
                                color: DefaultTextStyle.of(context).style.color,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: matchFilterText(widget.mark.name),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> contextActions() {
    final colorScheme = Theme.of(context).colorScheme;
    final style = CupertinoTheme.of(context).textTheme.textStyle;
    return [
      CupertinoContextMenuAction(
        onPressed: () {
          final editName = TextEditingController(text: widget.mark.name);
          final content = Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            // onChanged: () {
            //   if (!Form.of(primaryFocus!.context!).validate())
            //     editName.clear();
            // },
            child: CupertinoTextFormFieldRow(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Mark cannot be anonymous';
                }
                return null;
              },
              controller: editName,
              style: style,
              autofocus: true,
              minLines: 1,
              maxLines: 3,
              decoration: BoxDecoration(
                color: colorScheme.surfaceDim,
                borderRadius: BorderRadius.circular(kRadialReactionRadius / 2),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
            ),
          );
          showCupertinoModalPopup(
            context: context,
            builder: (context) => PlatformAlertDialog(
              title: const Text('Rename the mark'),
              actions: [
                PlatformDialogAction(
                  onPressed: Navigator.of(context).pop,
                  child: const Text('Cancel'),
                ),
                ListenableBuilder(
                  listenable: editName,
                  builder: (context, child) => PlatformDialogAction(
                    onPressed: editName.text.isEmpty
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            if (MyDB().renameMark(
                              id: widget.mark.id,
                              newName: editName.text,
                            )) {
                              setState(() {
                                widget.mark.name = editName.text;
                              });
                            }
                          },
                    child: child,
                  ),
                  child: const Text('Done'),
                ),
              ],
              cupertino: (_, _) => CupertinoAlertDialogData(content: content),
              material: (_, _) => MaterialAlertDialogData(
                content: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight:
                        style.fontSize?.scale(style.height ?? 1).scale(4) ?? 64,
                  ),
                  child: content,
                ),
              ),
            ),
          ).then((_) {
            if (mounted) Navigator.of(context).pop();
          });
        },
        trailingIcon: CupertinoIcons.pen,
        child: const Text('Rename'),
      ),
      CupertinoContextMenuAction(
        onPressed: () =>
            showCupertinoModalPopup<CollectionMark?>(
              context: context,
              builder: (context) {
                return SlideAppear(
                  child: EditFlashcardSheet(mark: widget.mark),
                );
              },
            ).then((mark) {
              if (mark != null) {
                setState(() {
                  widget.mark.color = mark.color;
                  widget.mark.icon = mark.icon;
                });
                MyDB().upsertCollection(mark);
              }
              if (mounted) Navigator.of(context).pop();
            }),
        trailingIcon: CupertinoIcons.ellipsis_circle,
        child: const Text('Edit'),
      ),
      ColoredBox(
        color: colorScheme.surfaceDim,
        child: const PopupMenuDivider(height: kMenuDividerHeight),
      ),
      CupertinoContextMenuAction(
        onPressed: () {
          Navigator.of(context).pop();
          widget.onRemove?.call(widget.mark);
        },
        isDestructiveAction: true,
        trailingIcon: CupertinoIcons.xmark_octagon,
        child: const Text('Delete'),
      ),
    ];
  }

  Text matchFilterText(String text) {
    final matches = text.matchIndexes(widget.filter);
    final style = TextStyle(
      fontWeight: FontWeight.w600,
      shadows: Theme.of(context).brightness == Brightness.light
          ? null
          : List.generate(
              4,
              (i) => Shadow(
                offset: Offset.fromDirection(pi * (1 + 2 * i) / 4, 2),
                color: Theme.of(context).colorScheme.shadow,
              ),
            ),
    );
    if (matches.isEmpty) {
      return Text(
        text,
        overflow: TextOverflow.ellipsis,
        maxLines: 3,
        textScaler: const TextScaler.linear(2),
        style: style,
      );
    }
    return Text.rich(
      TextSpan(
        children: List.generate(
          text.length,
          (i) => TextSpan(
            text: text[i],
            style: !matches.contains(i)
                ? null
                : TextStyle(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.tertiaryContainer,
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
          ),
        ),
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 3,
      textScaler: const TextScaler.linear(2),
      style: style,
    );
  }

  void stopShaking() {
    if (controller.isAnimating) controller.animateBack(.5);
  }

  void startShaking() {
    Future.delayed(Duration(milliseconds: Random().nextInt(150)), () {
      controller.repeat(reverse: true);
    });
  }
}

extension CardColors on CollectionMark {
  Gradient? gradient(BuildContext context, {double rotate = pi / 2}) {
    final brightness = Theme.of(context).brightness;
    return color == null
        ? null
        : LinearGradient(
            transform: GradientRotation(rotate),
            colors: brightness == Brightness.light
                ? [
                    HSVColor.fromColor(Color(color!)).withValue(1).toColor(),
                    HSVColor.fromColor(Color(color!)).withValue(.75).toColor(),
                  ]
                : [
                    HSVColor.fromColor(
                      Color(color!),
                    ).withSaturation(.5).toColor(),
                    HSVColor.fromColor(
                      Color(color!),
                    ).withSaturation(.75).toColor(),
                  ],
          );
  }
}
