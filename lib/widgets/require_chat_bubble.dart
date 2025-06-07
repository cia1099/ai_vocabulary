import 'dart:async';

import 'package:ai_vocabulary/app_settings.dart';
import 'package:ai_vocabulary/effects/show_toast.dart';
import 'package:ai_vocabulary/pages/chat_room_page.dart' show ErrorBanner;
import 'package:ai_vocabulary/utils/handle_except.dart';
import 'package:flutter/material.dart';

import '../api/dict_api.dart';
import '../database/my_db.dart';
import '../effects/dot3indicator.dart';
import '../model/message.dart';
import '../painters/chat_bubble.dart';
import 'chat_bubble.dart';

class RequireChatBubble extends StatefulWidget {
  final RequireMessage message;
  final Widget? leading;
  final ScrollController? controller;
  final void Function(Message) updateMessage;
  const RequireChatBubble({
    super.key,
    required this.message,
    this.leading,
    this.controller,
    required this.updateMessage,
  });

  @override
  State<RequireChatBubble> createState() => _RequireChatBubbleState();
}

class _RequireChatBubbleState extends State<RequireChatBubble> {
  late final stream = requireAnswer(widget.message);
  TextMessage? responseMsg;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final colorScheme = Theme.of(context).colorScheme;
    final leadingWidth = screenWidth * .1;
    final contentWidth =
        screenWidth * (.75 + (widget.leading == null ? .1 : 0));
    final req = widget.message;
    return ListenableBuilder(
      listenable: req.srcMsg,
      builder: (context, child) {
        return Wrap(
          alignment: req.srcMsg.hasError
              ? WrapAlignment.center
              : WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 8,
          children: [
            if (widget.leading != null && !req.srcMsg.hasError)
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: leadingWidth),
                child: widget.leading,
              ),
            child!,
          ],
        );
      },
      child: StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CustomPaint(
              painter: ChatBubblePainter(
                color: colorScheme.surfaceContainerHigh,
                isMe: false,
              ),
              child: waitingContent(contentWidth),
            );
          }
          if (snapshot.hasError || responseMsg == null) {
            Future.microtask(() => widget.message.srcMsg.hasError = true);
            final errorMsg = ErrorMessage(
              content: messageExceptions(snapshot.error ?? "No response"),
              srcMsg: widget.message.srcMsg,
            );
            widget.updateMessage(errorMsg);
            return ErrorBanner(message: errorMsg);
          }
          return ChatBubble(
            message: responseMsg!,
            maxWidth: contentWidth,
            child: snapshot.connectionState == ConnectionState.done
                ? ClickableText(
                    responseMsg!.content,
                    patterns: responseMsg!.patterns,
                  )
                : snapshot.hasData
                ? Text(snapshot.data!)
                : waitingContent(contentWidth),
          );
        },
      ),
    );
  }

  Stream<String> requireAnswer(RequireMessage req) async* {
    final ans = await chatVocabulary(
      req.vocabulary.split(', ').first,
      req.content,
      req.srcMsg.userID == null,
    );
    responseMsg = TextMessage(
      content: ans.answer,
      timeStamp: ans.created,
      patterns: widget.message.vocabulary.split(', '),
      wordID: widget.message.wordID,
      userID: ans.userId,
    );
    if (mounted && ChatBubble.showContents.value) {
      final accent = AppSettings.of(context).accent;
      final voicer = AppSettings.of(context).voicer;
      try {
        // await Future.microtask(
        //   () => soundAzure(ans.answer, lang: accent.azure.lang, sound: voicer),
        // );
        await Future.delayed(Durations.short1);
        await soundAzure(ans.answer, lang: accent.azure.lang, sound: voicer);
        for (int s = 4; s <= ans.answer.length; s += 2) {
          yield ans.answer.substring(0, s);
          // await Future.delayed(s <= 4 ? Durations.short2 : Durations.short1);
          if (!(widget.controller?.position.atEdge ?? true)) {
            widget.controller?.animateTo(
              widget.controller!.position.maxScrollExtent,
              duration: Durations.short4,
              curve: Curves.ease,
            );
          }
          await Future.delayed(Durations.short2);
        }
      } catch (e) {
        if (mounted) {
          showToast(context: context, child: Text(messageExceptions(e)));
        }
        print(e);
      }
    }
    widget.updateMessage(responseMsg!);
    if (ans.quiz) {
      Timer(const Duration(seconds: 2), () {
        final acquaint = MyDB().getAcquaintance(widget.message.wordID).acquaint;
        MyDB().upsertAcquaintance(
          wordId: widget.message.wordID,
          acquaint: acquaint + 1,
          isCorrect: ans.quiz,
        );
        appearAward(context, widget.message.vocabulary.split(', ').firstOrNull);
      });
    }
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
