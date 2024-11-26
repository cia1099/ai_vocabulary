import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/mock_data.dart';
import 'package:ai_vocabulary/model/message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:flutter_lorem/flutter_lorem.dart';

import '../painters/chat_bubble.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({
    super.key,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final messages = <Message>[];
  // late final word = MyDB().fetchWords([message.wordID]).first;
  final word = apple;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text('apple'),
        material: (_, __) => MaterialAppBarData(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) => ChatListTile(
                message: messages[index],
                leading: messages[index].userID == null && word.asset != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(word.asset!),
                      )
                    : null,
              ),
            ),
          ),
          Container(
            constraints: BoxConstraints(
                minHeight: screenHeight / 10, minWidth: double.infinity),
            color: colorScheme.onInverseSurface,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlatformIconButton(
                  onPressed: () {},
                  icon: const Icon(CupertinoIcons.keyboard),
                ),
                Expanded(
                  child: PlatformTextButton(
                    onPressed: () {
                      final now = DateTime.now().millisecondsSinceEpoch;
                      setState(() {
                        final myTalk = TextMessage(
                            content: lorem(paragraphs: 1, words: 10),
                            timeStamp: now,
                            userID: '1',
                            wordID: word.wordId);
                        final gptTalk = TextMessage(
                            content: lorem(paragraphs: 1),
                            timeStamp: now + 1000,
                            wordID: word.wordId);
                        messages.addAll([myTalk, gptTalk]);
                      });
                    },
                    padding: EdgeInsets.zero,
                    child: Container(
                      height: screenHeight / 16,
                      // width: double.maxFinite,
                      // padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(top: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: colorScheme.primary, width: 2),
                          borderRadius:
                              BorderRadius.circular(kRadialReactionRadius)),
                      child: const Text('Press to speak'),
                    ),
                  ),
                ),
                PlatformIconButton(
                  onPressed: () {},
                  icon: const Icon(CupertinoIcons.paperplane),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatListTile extends StatelessWidget {
  final Message message;
  final Widget? leading;
  const ChatListTile({
    super.key,
    required this.message,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      // width: double.infinity,
      margin: const EdgeInsets.all(8),
      child: Wrap(
        alignment:
            message.userID == null ? WrapAlignment.start : WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.end,
        spacing: 8,
        children: [
          if (leading != null)
            ConstrainedBox(
                constraints: BoxConstraints(maxWidth: screenWidth * .1),
                child: leading),
          createContent(message, maxWidth: screenWidth * .75)
        ],
      ),
    );
  }

  Widget createContent(Message message, {double maxWidth = double.infinity}) {
    switch (message.runtimeType) {
      case InfoMessage:
        return Text(message.content);
      case TextMessage:
        return TextBubble(message: message as TextMessage, maxWidth: maxWidth);
      default:
        return Text(message.content);
    }
  }
}

class TextBubble extends StatelessWidget {
  const TextBubble({
    super.key,
    required this.message,
    required this.maxWidth,
  });
  final TextMessage message;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateTime = DateTime.fromMillisecondsSinceEpoch(message.timeStamp);
    return CustomPaint(
      painter: ChatBubblePainter(
          isMe: message.userID != null,
          color: message.userID != null
              ? colorScheme.secondaryContainer
              : colorScheme.surfaceContainerHigh),
      child: Container(
        constraints:
            BoxConstraints(minHeight: 20, minWidth: 20, maxWidth: maxWidth),
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Text(
                message.content,
              ),
            ),
            Positioned(
                right: 4,
                bottom: 0,
                child: Text('${dateTime.hour}:${dateTime.minute}')),
          ],
        ),
      ),
    );
  }
}
