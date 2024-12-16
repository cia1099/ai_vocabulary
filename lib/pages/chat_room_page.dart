import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/model/message.dart';
import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:ai_vocabulary/widgets/chat_input_panel.dart';
import 'package:ai_vocabulary/widgets/require_chat_bubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';

import '../widgets/chat_bubble.dart';
import 'speech_confirm_dialog.dart';

class ChatRoomPage extends StatefulWidget {
  final Vocabulary word;
  const ChatRoomPage({
    super.key,
    required this.word,
  });

  List<Message> getMessages() {
    final dbMessage = MyDB().fetchMessages(word.wordId);
    final maxDateTimes = dbMessage.map((msg) {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(msg.timeStamp);
      final maxDateTime =
          DateTime(dateTime.year, dateTime.month, dateTime.day + 1);
      return maxDateTime.millisecondsSinceEpoch - 1;
    }).toSet();
    final today =
        DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
    return List<Message>.from(dbMessage)
      ..addAll(maxDateTimes.map((value) {
        final maxDateTime = DateTime.fromMillisecondsSinceEpoch(value);
        return InfoMessage(
            content: value - today.millisecondsSinceEpoch >= 0
                ? 'Today'
                : today.year - maxDateTime.year > 0
                    ? DateFormat.yMMMMd().format(maxDateTime)
                    : DateFormat('EEEE, MMMM d').format(maxDateTime),
            timeStamp: value);
      }))
      ..sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
  }

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> implements ChatInput {
  late final messages = <Message>[]; //widget.getMessages();
  final scrollController = ScrollController();
  final showTips = ValueNotifier(false);
  var showBottomSheet = false;
  final myID = '1';
  final tips = [
    'Can you give me some tips to help me make a sentence using this word?',
    'Can you explain to me the definition of this vocabulary?',
    'Is there an extended phrase, slang, or idiom associated with this word? What are they?',
    'Can you give me examples using this word?',
  ];

  @override
  void initState() {
    super.initState();
    MyDB().futureAppDirectory.then((_) {
      messages.addAll(widget.getMessages());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          messages.add(TextMessage(
              content:
                  'Hello,\nLet\'s practice how to do a sentence with ${widget.word.word}',
              timeStamp: DateTime.now().millisecondsSinceEpoch,
              wordID: widget.word.wordId));
        });
      });
    });
  }

  @override
  void dispose() {
    showTips.dispose();
    scrollController.dispose();
    MyDB()
        .insertMessages(Stream.fromIterable(messages
            .where((msg) => msg.userID != null)
            .whereType<TextMessage>()))
        .then((_) => messages.clear());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    // print(messages.map((e) => e.runtimeType.toString()).join(' '));
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        scrollController.animateTo(scrollController.position.maxScrollExtent,
            duration: Durations.short4, curve: Curves.ease));
    return MediaQuery.removeViewInsets(
      context: context,
      removeBottom: showBottomSheet,
      child: PlatformScaffold(
        appBar: PlatformAppBar(
          title: Text(widget.word.word),
          trailingActions: [
            ValueListenableBuilder(
              valueListenable: ChatBubble.showContents,
              builder: (context, value, child) => Switch.adaptive(
                thumbIcon: WidgetStateProperty.resolveWith((states) => Icon(
                    states.contains(WidgetState.selected)
                        ? CupertinoIcons.eye
                        : CupertinoIcons.eye_slash)),
                value: value,
                onChanged: (value) => ChatBubble.showContents.value = value,
                applyCupertinoTheme: true,
              ),
            )
          ],
          material: (_, __) => MaterialAppBarData(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) => ChatListTile(
                  message: messages[index],
                  leading: messages[index].userID != myID
                      ? CircleAvatar(
                          foregroundImage: widget.word.asset != null
                              ? NetworkImage(widget.word.asset!)
                              : null,
                          child: const Icon(CupertinoIcons.profile_circled,
                              size: 36))
                      : null,
                  updateMessage: (msg) => msg == null
                      ? messages.removeAt(index)
                      : messages[index] = msg,
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
    Future.delayed(
        Durations.long3,
        () => setState(() {
              messages.add(RequireMessage(
                vocabulary: widget.word.getMatchingPatterns.join(', '),
                wordID: widget.word.wordId,
                content: msg.content,
              ));
            }));
    setState(() {
      messages.add(TextMessage(
          content: msg.content,
          timeStamp: msg.timeStamp,
          wordID: widget.word.wordId,
          patterns: widget.word.getMatchingPatterns,
          userID: myID));
    });
  }
}

class ChatListTile extends StatelessWidget {
  final Message message;
  final Widget? leading;
  final void Function(Message?) updateMessage;
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
                child: msg.userID == null
                    ? Text(msg.content)
                    : ClickableText(msg.content, patterns: msg.patterns)),
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
