import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:speech_record/speech_record.dart';

import '../database/my_db.dart';
import '../model/message.dart';

abstract interface class ChatInput {
  void doneRecord(String? output);
  void tipsButtonCallBack();
  void onSubmit(Message? msg);
}

class ChatInputPanel extends StatefulWidget {
  final ChatInput delegate;
  final double minHeight;
  const ChatInputPanel(
      {super.key, required this.delegate, required this.minHeight});

  @override
  State<ChatInputPanel> createState() => _ChatInputPanelState();
}

class _ChatInputPanelState extends State<ChatInputPanel> {
  final textController = TextEditingController();
  var isKeyboard = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedSwitcher(
      duration: Durations.medium1,
      transitionBuilder: (child, animation) {
        final offset = Tween(begin: const Offset(0, 1), end: Offset.zero)
            .animate(animation);
        return SlideTransition(
          position: offset,
          child: child,
        );
      },
      child: Container(
        key: Key(isKeyboard ? 'keyboard' : 'speech'),
        constraints: BoxConstraints(
            minHeight: widget.minHeight, minWidth: double.infinity),
        color: colorScheme.onInverseSurface,
        child: isKeyboard
            ? keyboardInputs(colorScheme)
            : speechInputs(colorScheme),
      ),
    );
  }

  Widget speechInputs(ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlatformIconButton(
          onPressed: () => setState(() {
            isKeyboard ^= true;
          }),
          icon: const Icon(CupertinoIcons.keyboard),
        ),
        FutureBuilder(
          //TODO: remove this futureBuilder
          future: MyDB().futureAppDirectory,
          builder: (context, snapshot) => snapshot.data == null
              ? Placeholder(
                  fallbackHeight: widget.minHeight * 5 / 8, //screenHeight / 16,
                  fallbackWidth: 200,
                )
              : Expanded(
                  child: Container(
                    height: widget.minHeight * 5 / 8,
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
                      doneRecord: widget.delegate.doneRecord,
                      blinkShape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(kRadialReactionRadius)),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: colorScheme.primary, width: 2),
                            borderRadius:
                                BorderRadius.circular(kRadialReactionRadius)),
                        child: Stack(
                          children: [
                            Center(
                                child: Text('Press to speak',
                                    style:
                                        TextStyle(color: colorScheme.primary),
                                    textScaler: const TextScaler.linear(1.15))),
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
          onPressed: widget.delegate.tipsButtonCallBack,
          icon: const Icon(CupertinoIcons.exclamationmark_bubble),
        ),
      ],
    );
  }

  Widget keyboardInputs(ColorScheme colorScheme) {
    final suffixIcon = Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: textController.clear,
        child: const Icon(CupertinoIcons.delete_left),
      ),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlatformIconButton(
          onPressed: () => setState(() {
            textController.clear();
            isKeyboard ^= true;
          }),
          icon: const Icon(Icons.record_voice_over_outlined),
        ),
        Expanded(
            child: Container(
          constraints: BoxConstraints(minHeight: widget.minHeight * 5 / 8),
          margin: const EdgeInsets.only(top: 4),
          child: PlatformTextField(
            autofocus: true,
            maxLines: null,
            controller: textController,
            cupertino: (_, __) => CupertinoTextFieldData(
              decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.primary, width: 2),
                  borderRadius: BorderRadius.circular(kRadialReactionRadius)),
              suffix: suffixIcon,
            ),
            material: (_, __) => MaterialTextFieldData(
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(kRadialReactionRadius),
                    borderSide:
                        BorderSide(color: colorScheme.primary, width: 2)),
                suffixIcon: suffixIcon,
              ),
            ),
          ),
        )),
        AnimatedBuilder(
          animation: textController,
          builder: (context, icon) => PlatformIconButton(
            onPressed: textController.text.isEmpty
                ? null
                : () {
                    widget.delegate.onSubmit(InfoMessage(
                        content: textController.text,
                        timeStamp: DateTime.now().millisecondsSinceEpoch));
                    textController.clear();
                  },
            icon: icon,
          ),
          child: const Icon(CupertinoIcons.paperplane),
        ),
      ],
    );
  }
}
