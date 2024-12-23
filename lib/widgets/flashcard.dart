import 'package:ai_vocabulary/model/collection_mark.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/shortcut.dart';

class Flashcard extends StatefulWidget {
  final CollectionMark mark;
  final bool dragEnabled;
  const Flashcard({super.key, required this.mark, this.dragEnabled = false});

  @override
  State<Flashcard> createState() => _FlashcardState();
}

class _FlashcardState extends State<Flashcard>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    // final index = int.parse(widget.mark.name);
    return InkWell(
      onTap: () {},
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadialReactionRadius),
      ),
      child: //
          CupertinoContextMenu(
        actions: [
          const CupertinoContextMenuAction(
              trailingIcon: CupertinoIcons.pen, child: Text('Rename')),
          const CupertinoContextMenuAction(
              trailingIcon: CupertinoIcons.ellipsis_circle,
              child: Text('Edit')),
          ColoredBox(
              color: Theme.of(context).colorScheme.surfaceDim,
              child: const PopupMenuDivider(height: kMenuDividerHeight)),
          const CupertinoContextMenuAction(
              isDestructiveAction: true,
              trailingIcon: CupertinoIcons.xmark_octagon,
              child: Text('Delete')),
        ],
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 200, minHeight: 200),
          child: Card(
            // color: index.isOdd ? Colors.white : Colors.black12,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Icon(Icons.abc, size: 24 * 3),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      widget.mark.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      textScaler: const TextScaler.linear(2),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
