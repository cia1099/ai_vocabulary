import 'dart:io';

import 'package:ai_vocabulary/api/dict_api.dart';
import 'package:ai_vocabulary/model/chat_answer.dart';
import 'package:ai_vocabulary/model/message.dart';
import 'package:ai_vocabulary/utils/handle_except.dart';
import 'package:ai_vocabulary/widgets/action_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:speech_record/speech_record.dart';
import 'package:text2speech/text2speech.dart';
import 'package:path/path.dart' as p;

class SpeechConfirmDialog extends StatefulWidget {
  final String filePath;
  const SpeechConfirmDialog({super.key, required this.filePath});

  @override
  State<SpeechConfirmDialog> createState() => _SpeechConfirmDialogState();
}

class _SpeechConfirmDialogState extends State<SpeechConfirmDialog> {
  final textController = TextEditingController();
  late var futureRecognition =
  // Future.value(
  //   SpeechRecognition(recognize: false, text: ''),
  // );
  recognizeSpeech(widget.filePath)
    ..then((recognition) => textController.text = recognition.text);
  var editMode = false;
  final focusNode = FocusNode();

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = CupertinoTheme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final hPadding = MediaQuery.of(context).size.width / 16;
    final timeStamp = int.parse(
      p.withoutExtension(p.basename(widget.filePath)),
    );
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Align(
        alignment: const Alignment(0, .7),
        child: FractionallySizedBox(
          widthFactor: .9,
          child: CupertinoPopupSurface(
            child: FutureBuilder(
              future: futureRecognition,
              builder: (context, snapshot) {
                final enableRecord =
                    snapshot.connectionState != ConnectionState.waiting &&
                    !editMode;
                return Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: hPadding),
                      child: Text(
                        textController.text.isEmpty
                            ? 'Speech Recognizing...'
                            : 'Did you say this paragraph?',
                        style: textTheme.navTitleTextStyle,
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(minHeight: 128),
                      padding: EdgeInsets.only(
                        left: hPadding,
                        right: hPadding,
                        bottom: hPadding,
                      ),
                      child: IntrinsicHeight(
                        child: Stack(
                          fit: StackFit.passthrough,
                          children: [
                            Card.filled(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: textTheme.navActionTextStyle.color!,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(
                                  kRadialReactionRadius,
                                ),
                              ),
                              child: displaySpeech(snapshot, colorScheme),
                            ),
                            playAlign(),
                          ],
                        ),
                      ),
                    ),
                    ActionButton(
                      onPressed:
                          textController.text.isNotEmpty
                              ? () => Navigator.of(context).pop(
                                InfoMessage(
                                  content: textController.text,
                                  timeStamp: timeStamp,
                                ),
                              )
                              : null,
                      topBorder: true,
                      child: const _ActionSheet(
                        title: 'Confirm',
                        iconData: CupertinoIcons.shift,
                      ),
                    ),
                    ActionButton(
                      onPressed:
                          snapshot.data != null &&
                                  snapshot.connectionState !=
                                      ConnectionState.waiting
                              ? () => setState(() {
                                editMode = true;
                                focusNode.requestFocus();
                              })
                              : null,
                      topBorder: true,
                      child: const _ActionSheet(
                        title: 'Edit',
                        iconData: CupertinoIcons.pencil_ellipsis_rectangle,
                      ),
                    ),
                    AbsorbPointer(
                      absorbing: !enableRecord,
                      child: RecordSpeechButton(
                        appDirectory: p.dirname(p.dirname(widget.filePath)),
                        createWavFileName: () => p.basename(widget.filePath),
                        doneRecord: (outputPath) {
                          if (outputPath == null) return;
                          setState(() {
                            futureRecognition = recognizeSpeech(outputPath)
                              ..then(
                                (recognition) =>
                                    textController.text = recognition.text,
                              );
                          });
                          textController.clear();
                        },
                        startRecordHint:
                            () => immediatelyPlay(
                              'assets/sounds/speech_to_text_listening.m4r',
                            ),
                        child: ActionButton(
                          onPressed: enableRecord ? () {} : null,
                          topBorder: true,
                          child: const _ActionSheet(
                            title: 'Retake',
                            iconData: CupertinoIcons.mic,
                          ),
                        ),
                      ),
                    ),
                    ActionButton(
                      isDestructiveAction: true,
                      topBorder: true,
                      onPressed: () {
                        File(widget.filePath).delete();
                        Navigator.of(context).pop(null);
                      },
                      child: const _ActionSheet(
                        title: 'Dismiss',
                        iconData: CupertinoIcons.delete_simple,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget displaySpeech(
    AsyncSnapshot<SpeechRecognition> snapshot,
    ColorScheme colorScheme,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(
        child: SpinKitWave(size: 36, itemCount: 7, color: colorScheme.tertiary),
      );
    }
    if (snapshot.hasError) {
      return Center(
        child: Text(
          messageExceptions(snapshot.error),
          style: TextStyle(color: colorScheme.error),
        ),
      );
    }
    return CupertinoTextField.borderless(
      focusNode: focusNode,
      autofocus: editMode,
      readOnly: !editMode,
      controller: textController,
      placeholder: "Sorry we can't recognize your speech",
      placeholderStyle: TextStyle(color: colorScheme.onTertiaryContainer),
      maxLines: null,
      textAlignVertical: TextAlignVertical.center,
      textAlign: TextAlign.center,
      textInputAction: TextInputAction.done,
      onChanged: (value) => textController.text = value,
      onEditingComplete:
          () => setState(() {
            editMode = false;
          }),
    );
  }

  Widget playAlign() => Align(
    alignment: const Alignment(-1, 1),
    child: Transform.translate(
      offset: const Offset(-10, 10),
      child: CupertinoButton(
        onPressed: () => immediatelyPlay(widget.filePath, 'audio/wav'),
        padding: EdgeInsets.zero,
        minSize: 36,
        child: const Icon(CupertinoIcons.play_circle_fill, size: 36),
      ),
    ),
  );
}

class _ActionSheet extends StatelessWidget {
  const _ActionSheet({required this.title, required this.iconData});
  final String title;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 250 / 2),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Align(
            alignment: const Alignment(-1, 0),
            child: Icon(
              iconData,
              color: DefaultTextStyle.of(context).style.color,
            ),
          ),
          Center(child: Text(title)),
        ],
      ),
    );
  }
}
