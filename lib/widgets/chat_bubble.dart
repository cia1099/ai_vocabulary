import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../painters/chat_bubble.dart';

class ChatBubble extends StatelessWidget {
  final Widget content;
  final int timeStamp;
  final double maxWidth;
  final bool isMe;
  const ChatBubble(
      {super.key,
      required this.content,
      required this.timeStamp,
      required this.maxWidth,
      required this.isMe});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timeStamp);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final iconSize = Theme.of(context).iconTheme.size ?? 24.0;
    return CustomPaint(
      painter: ChatBubblePainter(
          isMe: isMe,
          color: isMe
              ? colorScheme.secondaryContainer
              : colorScheme.surfaceContainerHigh),
      child: Container(
        constraints: BoxConstraints(minWidth: iconSize * 7, maxWidth: maxWidth),
        padding: const EdgeInsets.only(right: 8, left: 8, top: 8),
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: iconSize * 1.414),
              child: content,
            ),
            Positioned(
                left: 4,
                bottom: 0,
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 8,
                  children: [
                    PlatformTextButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {},
                      material: (_, __) => MaterialTextButtonData(
                          style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.square(iconSize),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )),
                      cupertino: (_, __) =>
                          CupertinoTextButtonData(minSize: iconSize),
                      child: Icon(CupertinoIcons.play_circle, size: iconSize),
                    ),
                    PlatformTextButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {},
                      material: (_, __) => MaterialTextButtonData(
                          style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.square(iconSize),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )),
                      cupertino: (_, __) =>
                          CupertinoTextButtonData(minSize: iconSize),
                      child: Icon(CupertinoIcons.eye_slash, size: iconSize),
                    ),
                  ],
                )),
            Positioned(
                right: 4,
                bottom: 0,
                child: Text(
                  '${dateTime.hour}:$minute',
                  style: TextStyle(color: colorScheme.onSecondaryContainer),
                )),
          ],
        ),
      ),
    );
  }
}
