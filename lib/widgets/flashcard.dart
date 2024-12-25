import 'dart:math';

import 'package:ai_vocabulary/model/collection_mark.dart';
import 'package:ai_vocabulary/utils/regex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../utils/shortcut.dart';

class Flashcard extends StatefulWidget {
  final CollectionMark mark;
  final String filter;
  final bool dragEnabled;
  final void Function(CollectionMark)? onRemove;

  const Flashcard(
      {super.key,
      required this.mark,
      this.filter = '',
      this.dragEnabled = false,
      this.onRemove});

  @override
  State<Flashcard> createState() => _FlashcardState();
}

class _FlashcardState extends State<Flashcard>
    with SingleTickerProviderStateMixin {
  late final controller =
      AnimationController(vsync: this, duration: Durations.short3, value: .5);
  @override
  void dispose() {
    controller.isAnimating ? controller.stop() : null;
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
            turns: Tween<double>(begin: -pi / 512, end: pi / 512)
                .animate(controller),
            child: Card(
              // color: index.isOdd ? Colors.white : Colors.black12,
              child: InkWell(
                onTap: widget.dragEnabled ? null : () => print('tap inner'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Stack(
                    fit: StackFit.passthrough,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Icon(
                          Icons.abc,
                          size: 24 * 3,
                          color: DefaultTextStyle.of(context).style.color,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: matchFilterText(widget.mark.name),
                      )
                    ],
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
    return [
      CupertinoContextMenuAction(
          onPressed: () {
            final editName = TextEditingController(text: widget.mark.name);
            showCupertinoModalPopup(
              context: context,
              builder: (context) => PlatformAlertDialog(
                title: const Text('Rename the mark'),
                content: Form(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    // onChanged: () {
                    //   if (!Form.of(primaryFocus!.context!).validate())
                    //     editName.clear();
                    // },
                    child: CupertinoTextFormFieldRow(
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Mark cannot be anonymous';
                        return null;
                      },
                      controller: editName,
                      autofocus: true,
                      minLines: 1,
                      maxLines: 3,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceDim,
                        borderRadius:
                            BorderRadius.circular(kRadialReactionRadius / 2),
                        border: Border.all(color: colorScheme.outline),
                      ),
                    )),
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
                              setState(() {
                                widget.mark.name = editName.text;
                              });
                            },
                      child: child,
                    ),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ).then((_) {
              if (mounted) {
                Navigator.of(context).pop();
              }
            });
          },
          trailingIcon: CupertinoIcons.pen,
          child: const Text('Rename')),
      const CupertinoContextMenuAction(
          trailingIcon: CupertinoIcons.ellipsis_circle, child: Text('Edit')),
      ColoredBox(
          color: colorScheme.surfaceDim,
          child: const PopupMenuDivider(height: kMenuDividerHeight)),
      CupertinoContextMenuAction(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onRemove?.call(widget.mark);
          },
          isDestructiveAction: true,
          trailingIcon: CupertinoIcons.xmark_octagon,
          child: const Text('Delete')),
    ];
  }

  Text matchFilterText(String text) {
    final matches = text.matchIndexes(widget.filter);
    if (matches.isEmpty) {
      return Text(text,
          overflow: TextOverflow.ellipsis,
          maxLines: 3,
          textScaler: const TextScaler.linear(2),
          style: const TextStyle(fontWeight: FontWeight.w600));
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
                  backgroundColor:
                      Theme.of(context).colorScheme.tertiaryContainer,
                  color: Theme.of(context).colorScheme.onTertiaryContainer),
        ),
      )),
      overflow: TextOverflow.ellipsis,
      maxLines: 3,
      textScaler: const TextScaler.linear(2),
      style: const TextStyle(fontWeight: FontWeight.w600),
    );
  }

  void stopShaking() {
    controller.stop();
    controller.value = .5;
  }

  void startShaking() {
    Future.delayed(Duration(milliseconds: Random().nextInt(150)), () {
      controller.repeat(reverse: true);
    });
  }
}
