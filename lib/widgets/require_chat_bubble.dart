import 'dart:async';

import 'package:ai_vocabulary/app_settings.dart';
import 'package:ai_vocabulary/effects/show_toast.dart';
import 'package:ai_vocabulary/utils/handle_except.dart';
import 'package:flutter/material.dart';

import '../api/dict_api.dart';
import '../database/my_db.dart';
import '../effects/dot3indicator.dart';
import '../model/message.dart';
import '../painters/chat_bubble.dart';
import 'chat_bubble.dart';

class RequireChatBubble extends StatelessWidget {
  final RequireMessage message;
  final Widget? leading;
  final void Function(TextMessage) upgradeMessage;
  const RequireChatBubble({
    super.key,
    required this.message,
    this.leading,
    required this.upgradeMessage,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final colorScheme = Theme.of(context).colorScheme;
    final accent = AppSettings.of(context).accent;
    final voicer = AppSettings.of(context).voicer;
    final leadingWidth = screenWidth * .1;
    final contentWidth = screenWidth * (.75 + (leading == null ? .1 : 0));
    final req = message;
    final future = chatVocabulary(
      req.vocabulary.split(', ').first,
      req.content,
      req.srcMsg.userID == null,
    ).then((ans) async {
      if (!ChatBubble.showContents.value)
        await soundAzure(ans.answer, lang: accent.azure.lang, sound: voicer);
      return ans;
    });
    return ListenableBuilder(
      listenable: req.srcMsg,
      builder: (context, child) {
        return Wrap(
          alignment:
              req.srcMsg.hasError ? WrapAlignment.center : WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 8,
          children: [
            if (leading != null)
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: leadingWidth),
                child: req.srcMsg.hasError ? null : leading,
              ),
            child!,
          ],
        );
      },
      child: FutureBuilder(
        future: future,
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
          if (snapshot.hasError) {
            Future.microtask(() => message.srcMsg.hasError = true);
            return Container(
              constraints: BoxConstraints(maxWidth: contentWidth),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(kRadialReactionRadius),
              ),
              child: Text(
                messageExceptions(snapshot.error),
                style: TextStyle(color: colorScheme.onErrorContainer),
              ),
            );
          }
          final ans = snapshot.data!;
          final responseMsg = TextMessage(
            content: ans.answer,
            timeStamp: ans.created,
            patterns: message.vocabulary.split(', '),
            wordID: message.wordID,
            userID: ans.userId,
          );
          upgradeMessage(responseMsg);
          if (ans.quiz) {
            Timer(const Duration(seconds: 2), () {
              final acquaint = MyDB().getAcquaintance(message.wordID).acquaint;
              MyDB().upsertAcquaintance(
                wordId: message.wordID,
                acquaint: acquaint + 1,
                isCorrect: ans.quiz,
              );
              appearAward(context, message.vocabulary.split(', ').firstOrNull);
            });
          }
          return ChatBubble(
            message: responseMsg,
            maxWidth: contentWidth,
            child: StreamBuilder(
              stream:
                  (String text) async* {
                    if (ChatBubble.showContents.value) {
                      await soundAzure(
                        text,
                        lang: accent.azure.lang,
                        sound: voicer,
                      );
                      for (int s = 1; s <= text.length; s++) {
                        yield Text(text.substring(0, s));
                        await Future.delayed(
                          s <= 4 ? Durations.short2 : Durations.short1,
                        );
                      }
                    }
                  }(ans.answer).asBroadcastStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return ClickableText(
                    ans.answer,
                    patterns: responseMsg.patterns,
                  );
                }
                return snapshot.data ?? waitingContent(contentWidth);
              },
            ),
          );
        },
      ),
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
