part of 'chat_room_page.dart';

extension _ChatListTile on _ChatRoomPageState {
  Widget createContent({
    required Message message,
    Widget? leading,
    required void Function(Message msg) updateMessage,
    required bool Function(TextMessage msg) sendMessage,
  }) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final colorScheme = Theme.of(context).colorScheme;
    final myID = UserProvider().currentUser?.uid;
    final leadingWidth = screenWidth * .1;
    final contentWidth = screenWidth * (.75 + (leading == null ? .1 : 0));
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
              child: Text(
                message.content,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colorScheme.onTertiary),
              ),
            ),
          ],
        );
      case TextMessage:
        final msg = message as TextMessage;
        return ListenableBuilder(
          listenable: msg,
          builder: (context, child) => Wrap(
            alignment: msg.userID != myID
                ? WrapAlignment.start
                : WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 8,
            children: [
              if (leading != null && msg.userID != myID)
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: leadingWidth),
                  child: leading,
                ),
              if (msg.hasError)
                IconButton.filledTonal(
                  onPressed: () {
                    msg.hasError = sendMessage(msg);
                  },
                  padding: EdgeInsets.zero,
                  isSelected: false,
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    maximumSize: Size.fromWidth(leadingWidth),
                    minimumSize: Size.fromRadius(screenWidth * .04),
                  ),
                  color: colorScheme.onSurfaceVariant,
                  icon: const Icon(Icons.refresh),
                ),
              child!,
            ],
          ),
          child: ChatBubble(
            message: msg,
            maxWidth: contentWidth,
            child: msg.userID == null
                ? Text(msg.content)
                : ClickableText(msg.content, patterns: msg.patterns),
          ),
        );
      case RequireMessage:
        return RequireChatBubble(
          key: ValueKey(message.timeStamp),
          leading: leading,
          controller: scrollController,
          message: message as RequireMessage,
          updateMessage: updateMessage,
        );
      default:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [ErrorBanner(message: message)],
        );
    }
  }
}

class ErrorBanner extends StatelessWidget {
  final Message message;
  const ErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final maxWidth = MediaQuery.sizeOf(context).width * .75;
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(kRadialReactionRadius),
      ),
      child: Text(
        message.content,
        style: TextStyle(color: colorScheme.onErrorContainer),
      ),
    );
  }
}

extension on ChatRoomPage {
  List<Message> getMessages() {
    final dbMessage = MyDB().fetchMessages(word.wordId);
    final maxDateTimes = dbMessage.map((msg) {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(msg.timeStamp);
      final maxDateTime = DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day + 1,
      );
      return maxDateTime.millisecondsSinceEpoch - 1;
    }).toSet();
    final today = DateTime.now().copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
    );
    return List<Message>.from(dbMessage)
      ..addAll(
        maxDateTimes.map((value) {
          final maxDateTime = DateTime.fromMillisecondsSinceEpoch(value);
          return InfoMessage(
            content: value - today.millisecondsSinceEpoch >= 0
                ? 'Today'
                : today.year - maxDateTime.year > 0
                ? DateFormat.yMMMMd().format(maxDateTime)
                : DateFormat('EEEE, MMMM d').format(maxDateTime),
            timeStamp: value,
          );
        }),
      )
      ..sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
  }
}
