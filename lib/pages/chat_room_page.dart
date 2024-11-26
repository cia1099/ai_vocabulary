import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/mock_data.dart';
import 'package:ai_vocabulary/model/message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:flutter_lorem/flutter_lorem.dart';

import '../widgets/chat_bubble.dart';

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
                leading: messages[index].userID == null
                    ? CircleAvatar(
                        backgroundImage: word.asset != null
                            ? NetworkImage(word.asset!)
                            : null,
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
                  onPressed: () {
                    setState(() {
                      messages.add(
                        InfoMessage(
                          content: 'Shit man',
                          timeStamp: DateTime.now().millisecondsSinceEpoch,
                        ),
                      );
                    });
                  },
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
    return Container(
      // width: double.infinity,
      margin: const EdgeInsets.all(8),
      child: createContent(message, context: context),
    );
  }

  Widget createContent(Message message, {required BuildContext context}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;
    switch (message.runtimeType) {
      case InfoMessage:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: colorScheme.tertiary,
                borderRadius: BorderRadius.circular(kRadialReactionRadius),
              ),
              child: Text(message.content,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colorScheme.onTertiary)),
            ),
          ],
        );
      case TextMessage:
        return Wrap(
          alignment:
              message.userID == null ? WrapAlignment.start : WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 8,
          children: [
            if (leading != null)
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: screenWidth * .1),
                child: leading,
              ),
            ChatBubble(
                content: Text(message.content),
                timeStamp: message.timeStamp,
                maxWidth: screenWidth * (.75 + (leading == null ? .1 : 0)),
                isMe: message.userID != null),
          ],
        );
      default:
        return Text(message.content);
    }
  }
}
