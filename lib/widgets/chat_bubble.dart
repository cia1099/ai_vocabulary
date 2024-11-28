import 'package:flutter/material.dart';

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
    return CustomPaint(
      painter: ChatBubblePainter(
          isMe: isMe,
          color: isMe
              ? colorScheme.secondaryContainer
              : colorScheme.surfaceContainerHigh),
      child: Container(
        constraints: BoxConstraints(minWidth: 96, maxWidth: maxWidth),
        padding: const EdgeInsets.only(right: 8, left: 8, top: 8),
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: content,
            ),
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
