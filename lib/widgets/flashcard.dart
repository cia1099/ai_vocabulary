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
  final focusNode = FocusNode();
  late final textController = TextEditingController(text: widget.mark.name);
  var editable = false;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        editable = false;
        widget.mark.name = textController.text;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // final index = int.parse(widget.mark.name);
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {},
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadialReactionRadius),
      ),
      child: //
          CupertinoContextMenu(
        actions: [
          CupertinoContextMenuAction(
              onPressed: !editable
                  ? () => setState(() {
                        editable = true;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          focusNode.requestFocus();
                        });
                      })
                  : null,
              trailingIcon: CupertinoIcons.pen,
              child: const Text('Rename')),
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
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      // color: Colors.green,
                      child: Icon(
                        Icons.abc,
                        size: 24 * 3,
                        color: DefaultTextStyle.of(context).style.color,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: //
                        MediaQuery(
                      data: const MediaQueryData(
                          textScaler: TextScaler.linear(2)),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: //
                            CupertinoTextField.borderless(
                          // Form(
                          // onChanged: () =>
                          //     Form.maybeOf(focusNode.context ?? context)
                          //         ?.validate(),
                          // child: CupertinoTextFormFieldRow(
                          readOnly: !editable,
                          focusNode: focusNode,
                          controller: textController,
                          // validator: (value) {
                          //   if (value!.isEmpty) return 'Cannot empty name';
                          //   return null;
                          // },
                          // showCursor: editable,
                          // textInputAction: TextInputAction.done,
                          padding: EdgeInsets.zero,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  kRadialReactionRadius / 2),
                              color: editable
                                  ? colorScheme.surfaceContainerHigh
                                  : Colors.transparent),
                          minLines: 1,
                          maxLines: 2,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  )
                  // Text(widget.mark.name,
                  //     overflow: TextOverflow.ellipsis,
                  //     maxLines: 3,
                  //     style: const TextStyle(fontWeight: FontWeight.w600),
                  //     textScaler: const TextScaler.linear(2)),
                  // )//Form
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
