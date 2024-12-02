import 'package:ai_vocabulary/api/dict_api.dart';
import 'package:ai_vocabulary/model/message.dart';
import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:ai_vocabulary/painters/chat_bubble.dart';
import 'package:ai_vocabulary/widgets/dot3indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

// import 'package:flutter_lorem/flutter_lorem.dart';

import '../widgets/chat_bubble.dart';

class ChatRoomPage extends StatefulWidget {
  final Vocabulary word;
  const ChatRoomPage({
    super.key,
    required this.word,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final messages = <Message>[];
  final myID = '1';
  final gptID = '123';
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    // print(messages.map((e) => e.runtimeType.toString()).join(' '));
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(widget.word.word),
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
                leading: messages[index].userID != myID
                    ? CircleAvatar(
                        backgroundImage: widget.word.asset != null
                            ? NetworkImage(widget.word.asset!)
                            : null,
                      )
                    : null,
                updateMessage: (msg) => messages[index] = msg,
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
                            content: 'I eat apple juice this morning.',
                            timeStamp: now,
                            userID: myID,
                            wordID: widget.word.wordId);
                        final gptTalk = RequireMessage(
                          content: 'I eat apple juice this morning.',
                          timeStamp: now + 1000,
                          vocabulary: widget.word.word,
                          wordID: widget.word.wordId,
                        );
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
  final void Function(Message) updateMessage;
  const ChatListTile({
    super.key,
    required this.message,
    this.leading,
    required this.updateMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      // width: double.infinity,
      margin: const EdgeInsets.all(8),
      child: createContent(message, context: context),
    );
  }

  Widget createContent(Message message, {required BuildContext context}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;
    const myID = '1';
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
              message.userID != myID ? WrapAlignment.start : WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 8,
          children: [
            if (leading != null && message.userID != myID)
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: screenWidth * .1),
                child: leading,
              ),
            ChatBubble(
                content: Text(message.content),
                timeStamp: message.timeStamp,
                maxWidth: screenWidth * (.75 + (leading == null ? .1 : 0)),
                isMe: message.userID == myID),
          ],
        );
      case RequireMessage:
        final req = message as RequireMessage;
        final future = chatVocabulary(req.vocabulary, req.content);
        return Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 8,
          children: [
            if (leading != null)
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: screenWidth * .1),
                child: leading,
              ),
            FutureBuilder(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CustomPaint(
                    painter: ChatBubblePainter(
                        color: colorScheme.surfaceContainerHigh, isMe: false),
                    child: Container(
                      width: 100,
                      height: 50,
                      constraints: BoxConstraints(
                          maxWidth:
                              screenWidth * (.75 + (leading == null ? .1 : 0))),
                      child: const DotDotDotIndicator(size: 20),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                final ans = snapshot.data!;
                updateMessage(TextMessage(
                    content: ans.answer,
                    timeStamp: ans.created,
                    wordID: req.wordID,
                    userID: ans.userId));
                return ChatBubble(
                    content: StreamBuilder(
                        stream: (String text) async* {
                          for (int s = 1; s <= text.length; s++) {
                            yield text.substring(0, s);
                            await Future.delayed(Durations.short1);
                          }
                        }(ans.answer),
                        builder: (context, snapshot) {
                          return Text(snapshot.data ?? '');
                        }),
                    timeStamp: ans.created,
                    maxWidth: screenWidth * (.75 + (leading == null ? .1 : 0)),
                    isMe: false);
              },
            )
          ],
        );
      default:
        return Text(message.content);
    }
  }
}
