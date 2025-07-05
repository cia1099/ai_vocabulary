import 'dart:io';

import 'package:ai_vocabulary/api/dict_api.dart';
import 'package:ai_vocabulary/app_settings.dart';
import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/model/message.dart';
import 'package:ai_vocabulary/painters/bubble_shape.dart';
import 'package:ai_vocabulary/provider/user_provider.dart';
import 'package:ai_vocabulary/utils/clickable_text_mixin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:text2speech/text2speech.dart';

import '../effects/show_toast.dart';
import '../utils/handle_except.dart';

class ChatBubble extends StatefulWidget {
  final Widget child;
  final Message message;
  final double maxWidth;
  const ChatBubble({
    super.key,
    required this.child,
    required this.message,
    this.maxWidth = double.infinity,
  });

  static final showContents = ValueNotifier(true);

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> with ShowContentMixin {
  late final isMe = widget.message.userID == UserProvider().currentUser?.uid;
  //!= null && widget.message.userID != kChatBotUID;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateTime = DateTime.fromMillisecondsSinceEpoch(
      widget.message.timeStamp,
    );
    final iconSize = Theme.of(context).iconTheme.size ?? 24.0;

    return Container(
      constraints: BoxConstraints(
        minWidth: iconSize * 7,
        maxWidth: widget.maxWidth,
      ),
      padding: const EdgeInsets.only(right: 8, left: 8, top: 8),
      decoration: ShapeDecoration(
        color: isMe
            ? colorScheme.secondaryContainer
            : colorScheme.surfaceContainerHigh,
        shape: ChatBubbleShape(isMe: isMe),
      ),
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: iconSize * 1.414),
            child: showContent || widget.child is! ClickableText
                ? MediaQuery(
                    data: const MediaQueryData(
                      textScaler: TextScaler.linear(1.414),
                    ),
                    child: widget.child,
                  )
                : Theme(
                    data: ThemeData(
                      iconTheme: IconThemeData(
                        color: colorScheme.onSurface.withValues(alpha: .6),
                        size: iconSize * 1.6,
                      ),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      children: [
                        const Icon(CupertinoIcons.waveform_path_ecg),
                        Transform.scale(
                          scaleX: 1.3,
                          child: const Icon(CupertinoIcons.waveform_path),
                        ),
                        Transform.flip(
                          flipX: true,
                          // flipY: true,
                          child: const Icon(CupertinoIcons.waveform_path_ecg),
                        ),
                      ],
                    ),
                  ),
          ),
          Positioned(
            left: 4,
            bottom: 0,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 8,
              children: [
                PlatformIconButton(
                  onPressed: widget.child is ClickableText
                      ? () => soundContent(widget.message)
                      : null,
                  padding: EdgeInsets.zero,
                  material: (_, __) => MaterialIconButtonData(
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.square(iconSize),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  cupertino: (_, __) =>
                      CupertinoIconButtonData(minSize: iconSize),
                  icon: Builder(
                    builder: (context) => Icon(
                      CupertinoIcons.play_circle,
                      size: iconSize,
                      color: DefaultTextStyle.of(context).style.color,
                    ),
                  ),
                ),
                PlatformTextButton(
                  onPressed: () => setState(() {
                    showContent ^= true;
                  }),
                  padding: EdgeInsets.zero,
                  material: (_, __) => MaterialTextButtonData(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.square(iconSize),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  cupertino: (_, __) =>
                      CupertinoTextButtonData(minSize: iconSize),
                  child: Icon(
                    showContent ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                    size: iconSize,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 4,
            bottom: 0,
            child: Text(
              DateFormat.Hm().format(dateTime),
              style: TextStyle(color: colorScheme.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> soundContent(Message msg) {
    final file = File(
      p.join(MyDB().appDirectory, 'audio', '${msg.timeStamp}.wav'),
    );
    if (file.existsSync()) {
      return file.readAsBytes().then((bytes) => bytesPlay(bytes, 'audio/wav'));
    }
    final accent = AppSettings.of(context).accent;
    final voicer = AppSettings.of(context).voicer;
    return soundAzure(
      widget.message.content,
      lang: accent.azure.lang,
      sound: voicer,
    ).onError(
      (e, _) => mounted
          ? showToast(context: context, child: Text(messageExceptions(e)))
          : null,
    );
  }
}

class ClickableText extends StatefulWidget {
  final String text;
  final Iterable<String> patterns;
  const ClickableText(
    this.text, {
    super.key,
    this.patterns = const Iterable.empty(),
  });

  @override
  State<ClickableText> createState() => _ClickableTextState();
}

class _ClickableTextState extends State<ClickableText>
    with ClickableTextStateMixin {
  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              children: clickableWords(widget.text, patterns: widget.patterns),
            ),
          ],
        ),
      ),
    );
  }
}

mixin ShowContentMixin<T extends StatefulWidget> on State<T> {
  var showContent = ChatBubble.showContents.value;
  @override
  void initState() {
    super.initState();
    ChatBubble.showContents.addListener(globalShow);
  }

  @override
  void dispose() {
    ChatBubble.showContents.removeListener(globalShow);
    super.dispose();
  }

  void globalShow() {
    setState(() {
      showContent = ChatBubble.showContents.value;
    });
  }
}
