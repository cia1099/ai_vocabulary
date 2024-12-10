import 'package:flutter/material.dart';

import '../api/dict_api.dart';
import '../model/message.dart';
import '../painters/chat_bubble.dart';
import 'chat_bubble.dart';
import 'dot3indicator.dart';

class RequireChatBubble extends StatelessWidget {
  final RequireMessage message;
  final Widget? leading;
  final void Function(Message?) updateMessage;
  const RequireChatBubble({
    super.key,
    required this.message,
    this.leading,
    required this.updateMessage,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;
    final leadingWidth = screenWidth * .1;
    final contentWidth = screenWidth * (.75 + (leading == null ? .1 : 0));
    final req = message;
    final future =
        chatVocabulary(req.vocabulary, req.content, req.timeStamp >= 0)
          ..then((ans) =>
              ChatBubble.showContents.value ? null : soundAzure(ans.answer));
    return Wrap(
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 8,
      children: [
        if (leading != null)
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: leadingWidth),
            child: leading,
          ),
        FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CustomPaint(
                painter: ChatBubblePainter(
                    color: colorScheme.surfaceContainerHigh, isMe: false),
                child: waitingContent(contentWidth),
              );
            }
            if (snapshot.hasError) {
              updateMessage(null);
              return Text('${snapshot.error}',
                  style: TextStyle(color: colorScheme.error));
            }
            final ans = snapshot.data!;
            final tmessage = TextMessage(
                content: ans.answer,
                timeStamp: ans.created,
                patterns: [message.vocabulary],
                wordID: message.wordID,
                userID: ans.userId);
            updateMessage(tmessage);
            return ChatBubble(
                message: tmessage,
                maxWidth: contentWidth,
                child: StreamBuilder(
                    stream: (String text) async* {
                      if (ChatBubble.showContents.value) {
                        await soundAzure(text);
                        for (int s = 1; s <= text.length; s++) {
                          yield Text(text.substring(0, s));
                          await Future.delayed(
                              s <= 4 ? Durations.short2 : Durations.short1);
                        }
                      }
                    }(ans.answer)
                        .asBroadcastStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done)
                        return ClickableText(ans.answer,
                            patterns: tmessage.patterns);
                      return snapshot.data ?? waitingContent(contentWidth);
                    }));
          },
        )
      ],
    );
  }

  Widget waitingContent(double maxWidth, [double width = 100]) {
    return Container(
      width: width,
      height: 50,
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: const DotDotDotIndicator(size: 20),
    );
  }
}
