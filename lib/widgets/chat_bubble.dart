import 'package:ai_vocabulary/model/message.dart';
import 'package:ai_vocabulary/utils/clickable_text_mixin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../bottom_sheet/retrieval_bottom_sheet.dart';
import '../painters/chat_bubble.dart';

class ChatBubble extends StatelessWidget {
  final Widget child;
  final Message message;
  final double maxWidth;
  const ChatBubble({
    super.key,
    required this.child,
    required this.message,
    this.maxWidth = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateTime = DateTime.fromMillisecondsSinceEpoch(message.timeStamp);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final iconSize = Theme.of(context).iconTheme.size ?? 24.0;
    final isMe = message.userID == '1';
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
              child: MediaQuery(
                  data: const MediaQueryData(
                      textScaler: TextScaler.linear(1.414)),
                  child: child),
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

class ClickableText extends StatefulWidget {
  final String text;
  final Iterable<String> patterns;
  const ClickableText(this.text,
      {super.key, this.patterns = const Iterable.empty()});

  @override
  State<ClickableText> createState() => _ClickableTextState();
}

class _ClickableTextState extends State<ClickableText>
    with ClickableTextStateMixin {
  @override
  void initState() {
    super.initState();
    onTap = <T>(word) => showPlatformModalSheet<T>(
          context: context,
          material: MaterialModalSheetData(
            useSafeArea: true,
            isScrollControlled: true,
          ),
          builder: (context) => RetrievalBottomSheet(queryWord: word),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(children: [
        TextSpan(
          children: clickableWords(widget.text, patterns: widget.patterns),
        ),
      ]),
    );
  }
}
