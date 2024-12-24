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
  @override
  Widget build(BuildContext context) {
    // final index = int.parse(widget.mark.name);
    return AbsorbPointer(
      absorbing: widget.onRemove == null || widget.dragEnabled,
      child: InkWell(
        onTap: () {},
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadialReactionRadius),
        ),
        child: //
            CupertinoContextMenu(
          actions: contextActions(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 200, minHeight: 200),
            child: Card(
              // color: index.isOdd ? Colors.white : Colors.black12,
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
    );
  }

  List<Widget> contextActions() {
    return [
      CupertinoContextMenuAction(
          onPressed: () {
            Navigator.of(context).pop();
            final editName = ValueNotifier(widget.mark.name);
            showCupertinoModalPopup(
              context: context,
              builder: (context) => PlatformAlertDialog(
                title: const Text('Rename the mark'),
                content: Form(
                    child: CupertinoTextFormFieldRow(
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'The mark cannot be empty';
                    return null;
                  },
                  onChanged: (value) {
                    editName.value = value;
                    Form.maybeOf(primaryFocus!.context!)?.validate();
                  },
                  autofocus: true,
                  initialValue: editName.value,
                  minLines: 1,
                  maxLines: 3,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceDim,
                    borderRadius:
                        BorderRadius.circular(kRadialReactionRadius / 2),
                    border: Border.all(
                        color: Theme.of(context).colorScheme.outline),
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
                      onPressed: editName.value.isEmpty
                          ? null
                          : () {
                              Navigator.of(context).pop();
                              setState(() {
                                widget.mark.name = editName.value;
                              });
                            },
                      child: child,
                    ),
                    child: const Text('Done'),
                  ),
                ],
              ),
            );
          },
          trailingIcon: CupertinoIcons.pen,
          child: const Text('Rename')),
      const CupertinoContextMenuAction(
          trailingIcon: CupertinoIcons.ellipsis_circle, child: Text('Edit')),
      ColoredBox(
          color: Theme.of(context).colorScheme.surfaceDim,
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
}
