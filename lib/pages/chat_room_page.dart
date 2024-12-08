import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/model/message.dart';
import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:ai_vocabulary/widgets/require_chat_bubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:speech_record/speech_record.dart';

import '../widgets/chat_bubble.dart';
import 'speech_confirm_dialog.dart';

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
  final showTips = ValueNotifier(false);
  final tips = [
    'Can you give me some tips to help me make a sentence using this word?',
    'Can you explain to me the definition of this vocabulary?',
    'Is there an extended phrase, slang, or idiom associated with this word?',
    'Can you give me examples using this word?',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    // print(messages.map((e) => e.runtimeType.toString()).join(' '));
    return MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true,
      child: PlatformScaffold(
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
            ValueListenableBuilder(
              valueListenable: showTips,
              builder: (context, value, child) => AnimatedContainer(
                duration: Durations.medium1,
                height: value ? null : 0.0,
                color: colorScheme.onInverseSurface,
                constraints: BoxConstraints(
                    maxHeight: screenHeight / 10, minWidth: double.infinity),
                child: child,
              ),
              child: CarouselView(
                  itemExtent: screenWidth / 2,
                  onTap: (index) => setState(() {
                        showTips.value = false;
                        messages.add(RequireMessage(
                            vocabulary: widget.word.word,
                            wordID: widget.word.wordId,
                            timeStamp: 0,
                            content: tips[index]));
                      }),
                  children: tips
                      .map((e) => ColoredBox(
                            color: colorScheme.tertiaryContainer,
                            child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(left: 16),
                                child: Text(e,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: colorScheme.onTertiaryContainer,
                                    ))),
                          ))
                      .toList()),
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
                  FutureBuilder(
                    future: MyDB().futureAppDirectory,
                    builder: (context, snapshot) => snapshot.data == null
                        ? Placeholder(
                            fallbackHeight: screenHeight / 16,
                            fallbackWidth: 200,
                          )
                        : Expanded(
                            child: Container(
                              height: screenHeight / 16,
                              // width: double.maxFinite,
                              // padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(top: 4),
                              alignment: Alignment.center,
                              child: RecordSpeechButton(
                                appDirectory: snapshot.data!,
                                createWavFileName: () {
                                  final now = DateTime.now();
                                  return '${now.millisecondsSinceEpoch}.wav';
                                },
                                doneRecord: (outputPath) {
                                  if (outputPath != null) {
                                    showPlatformModalSheet<Message?>(
                                      context: context,
                                      cupertino: CupertinoModalSheetData(
                                          barrierDismissible: false),
                                      material: MaterialModalSheetData(
                                        backgroundColor: Colors.transparent,
                                        scrollControlDisabledMaxHeightRatio: 1,
                                        isDismissible: false,
                                      ),
                                      builder: (context) => SpeechConfirmDialog(
                                          filePath: outputPath),
                                    ).then((msg) {
                                      if (msg == null) return;
                                      Future.delayed(
                                          Durations.long3,
                                          () => setState(() {
                                                messages.add(RequireMessage(
                                                  vocabulary: widget.word.word,
                                                  wordID: widget.word.wordId,
                                                  content: msg.content,
                                                ));
                                              }));
                                      setState(() {
                                        messages.add(TextMessage(
                                            content: msg.content,
                                            timeStamp: msg.timeStamp,
                                            wordID: widget.word.wordId,
                                            patterns:
                                                widget.word.getMatchingPatterns,
                                            userID: myID));
                                      });
                                    });
                                  }
                                },
                                blinkShape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        kRadialReactionRadius)),
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: colorScheme.primary, width: 2),
                                      borderRadius: BorderRadius.circular(
                                          kRadialReactionRadius)),
                                  child: Stack(
                                    children: [
                                      Center(
                                          child: Text('Press to speak',
                                              style: TextStyle(
                                                  color: colorScheme.primary),
                                              textScaler:
                                                  const TextScaler.linear(
                                                      1.15))),
                                      const Align(
                                          alignment: Alignment(.95, 0),
                                          child: Icon(CupertinoIcons.mic)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                  PlatformIconButton(
                    onPressed: () => showTips.value ^= true,
                    icon: const Icon(CupertinoIcons.exclamationmark_bubble),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        final msg = message as TextMessage;
        return Wrap(
          alignment:
              msg.userID != myID ? WrapAlignment.start : WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 8,
          children: [
            if (leading != null && msg.userID != myID)
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: screenWidth * .1),
                child: leading,
              ),
            ChatBubble(
                message: msg,
                maxWidth: screenWidth * (.75 + (leading == null ? .1 : 0)),
                child: ClickableText(msg.content, patterns: msg.patterns)),
          ],
        );
      case RequireMessage:
        return RequireChatBubble(
            leading: leading,
            message: message as RequireMessage,
            updateMessage: updateMessage);
      default:
        return Text(message.content,
            style: TextStyle(color: colorScheme.error));
    }
  }
}
