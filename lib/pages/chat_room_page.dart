import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/model/message.dart';
import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:ai_vocabulary/provider/user_provider.dart';
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:ai_vocabulary/widgets/capital_avatar.dart';
import 'package:ai_vocabulary/widgets/chat_input_panel.dart';
import 'package:ai_vocabulary/widgets/require_chat_bubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';

import '../widgets/chat_bubble.dart';
import 'speech_confirm_dialog.dart';

part 'chat_room_page2.dart';

class ChatRoomPage extends StatefulWidget {
  final Vocabulary word;
  const ChatRoomPage({super.key, required this.word});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> implements ChatInput {
  late final messages = <Message>[]; //widget.getMessages();
  final scrollController = ScrollController();
  final showTips = ValueNotifier(false);
  var showBottomSheet = false;

  @override
  void initState() {
    super.initState();
    MyDB().isReady.then((_) {
      messages.addAll(widget.getMessages());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          messages.add(
            TextMessage(
              content:
                  'Hello,\nLet\'s practice how to do a sentence with ${widget.word.word}',
              timeStamp: DateTime.now().millisecondsSinceEpoch,
              wordID: widget.word.wordId,
            ),
          );
        });
      });
    });
  }

  @override
  void dispose() {
    showTips.dispose();
    scrollController.dispose();
    MyDB()
        .insertMessages(
          Stream.fromIterable(
            messages.whereType<TextMessage>(),
          ).where((msg) => msg.userID != null && !msg.hasError),
        )
        .then((_) => messages.clear());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    // print(messages.map((e) => e.runtimeType.toString()).join(' '));
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => scrollController.animateTo(
        scrollController.position.maxScrollExtent, //* .85,
        duration: Durations.short4,
        curve: Curves.ease,
      ),
    );
    return MediaQuery.removeViewInsets(
      context: context,
      removeBottom: showBottomSheet,
      child: PlatformScaffold(
        appBar: PlatformAppBar(
          title: Text(widget.word.word),
          trailingActions: [
            ValueListenableBuilder(
              valueListenable: ChatBubble.showContents,
              builder:
                  (context, value, child) => Switch.adaptive(
                    thumbIcon: WidgetStateProperty.resolveWith(
                      (states) => Icon(
                        states.contains(WidgetState.selected)
                            ? CupertinoIcons.eye
                            : CupertinoIcons.eye_slash,
                      ),
                    ),
                    value: value,
                    onChanged: (value) => ChatBubble.showContents.value = value,
                    applyCupertinoTheme: true,
                  ),
            ),
          ],
          material:
              (_, __) => MaterialAppBarData(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
                controller: scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final isMe =
                      messages[index].userID != null &&
                      messages[index].userID != kChatBotUID;
                  return ChatListTile(
                    message: messages[index],
                    leading:
                        !isMe
                            ? CapitalAvatar(
                              id: widget.word.wordId,
                              name: widget.word.word,
                              url: widget.word.asset,
                            )
                            : null,
                    upgradeMessage: (msg) => messages[index] = msg,
                    sendMessage: (msg) => mounted && sendMessage(msg),
                  );
                },
              ),
            ),
            ValueListenableBuilder(
              valueListenable: showTips,
              builder:
                  (context, value, child) => AnimatedContainer(
                    duration: Durations.medium1,
                    height: value ? null : 0.0,
                    color: colorScheme.onInverseSurface,
                    constraints: BoxConstraints(
                      maxHeight: screenHeight / 10,
                      minWidth: double.infinity,
                    ),
                    child: child,
                  ),
              child: CarouselView(
                itemExtent: screenWidth / 2,
                onTap:
                    (index) => setState(() {
                      showTips.value = false;
                      messages.add(
                        RequireMessage(
                          srcMsg: TextMessage(
                            content: _tips[index],
                            userID: null, //used to help
                            wordID: widget.word.wordId,
                            patterns: [widget.word.word],
                          ),
                        ),
                      );
                    }),
                children:
                    _tips
                        .map(
                          (e) => ColoredBox(
                            color: colorScheme.tertiaryContainer,
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.only(left: 16),
                              child: Text(
                                e,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: colorScheme.onTertiaryContainer,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
            ChatInputPanel(delegate: this, minHeight: screenHeight / 10),
          ],
        ),
      ),
    );
  }

  @override
  void doneRecord(String? outputPath) {
    if (outputPath == null) return;
    showBottomSheet = true;
    showPlatformModalSheet<Message?>(
      context: context,
      cupertino: CupertinoModalSheetData(barrierDismissible: false),
      material: MaterialModalSheetData(
        backgroundColor: Colors.transparent,
        scrollControlDisabledMaxHeightRatio: 1,
        isDismissible: false,
      ),
      builder: (context) => SpeechConfirmDialog(filePath: outputPath),
    ).then(onSubmit).then((_) => showBottomSheet = false);
  }

  @override
  void tipsButtonCallBack() {
    showTips.value ^= true;
  }

  @override
  void onSubmit(Message? msg) {
    if (msg == null) return;
    final newMessage = TextMessage(
      content: msg.content,
      timeStamp: msg.timeStamp,
      wordID: widget.word.wordId,
      patterns: widget.word.getMatchingPatterns,
      userID: UserProvider().currentUser?.uid,
    );
    Future.delayed(Durations.long3, () => mounted && sendMessage(newMessage));
    setState(() {
      messages.add(newMessage);
    });
  }

  bool sendMessage(TextMessage message) {
    setState(() {
      messages.removeWhere(
        (msg) => msg is RequireMessage && identical(msg.srcMsg, message),
      );
      messages.add(RequireMessage(srcMsg: message));
    });
    return false; //reset hasError
  }
}

const _tips = [
  'Is there an extended phrase, slang, or idiom associated with this word? What are they?',
  'Use disassembling a word to help me memorize the word.',
  'Give me some common synonyms or antonyms. I can recognize the word.',
  'Can you give me some tips to help me make a sentence using this word?',
  'Can you explain to me the definition of this vocabulary?',
  'Can you give me examples using this word?',
];
