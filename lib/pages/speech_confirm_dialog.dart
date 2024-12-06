import 'dart:io';

import 'package:ai_vocabulary/api/dict_api.dart';
import 'package:ai_vocabulary/model/message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:text2speech/text2speech.dart';
import 'package:path/path.dart' as p;

class SpeechConfirmDialog extends StatefulWidget {
  final String filePath;
  const SpeechConfirmDialog({
    super.key,
    required this.filePath,
  });

  @override
  State<SpeechConfirmDialog> createState() => _SpeechConfirmDialogState();
}

class _SpeechConfirmDialogState extends State<SpeechConfirmDialog> {
  final textController = TextEditingController();
  late final futureRecognition = recognizeSpeech(widget.filePath)
      .then((recognition) => textController.text = recognition.text);
  var editMode = false;
  final focusNode = FocusNode();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = CupertinoTheme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final hPadding = MediaQuery.of(context).size.width / 16;
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Stack(
        children: [
          Align(
            alignment: const Alignment(0, .7),
            child: FractionallySizedBox(
              widthFactor: .9,
              child: CupertinoPopupSurface(
                child: Padding(
                  padding: EdgeInsets.only(top: hPadding),
                  child: FutureBuilder(
                    future: futureRecognition,
                    builder: (context, snapshot) => Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          textController.text.isEmpty
                              ? 'Speech Recognizing...'
                              : 'Did you say this paragraph?',
                          style: textTheme.navTitleTextStyle,
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                              minHeight: 128, minWidth: double.infinity),
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: hPadding,
                                right: hPadding,
                                bottom: hPadding),
                            child: IntrinsicHeight(
                              child: Stack(
                                fit: StackFit.passthrough,
                                children: [
                                  Card.filled(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      shape: ContinuousRectangleBorder(
                                          side: BorderSide(
                                              color: textTheme
                                                  .navActionTextStyle.color!,
                                              width: 2),
                                          borderRadius: BorderRadius.circular(
                                              kRadialReactionRadius)),
                                      child: snapshot.connectionState ==
                                              ConnectionState.waiting
                                          ? Center(
                                              child: SpinKitWave(
                                                  size: 36,
                                                  itemCount: 7,
                                                  color: colorScheme.tertiary))
                                          : snapshot.hasError
                                              ? Center(
                                                  child: Text(
                                                      '${snapshot.error}',
                                                      style: TextStyle(
                                                          color: colorScheme
                                                              .error)))
                                              : CupertinoTextField.borderless(
                                                  focusNode: focusNode,
                                                  autofocus: editMode,
                                                  readOnly: !editMode,
                                                  controller: textController,
                                                  placeholder:
                                                      "Sorry we can't recognize your speech",
                                                  placeholderStyle: TextStyle(
                                                      color: colorScheme
                                                          .onTertiaryContainer),
                                                  maxLines: null,
                                                  textAlignVertical:
                                                      TextAlignVertical.center,
                                                  textAlign: TextAlign.center,
                                                  textInputAction:
                                                      TextInputAction.done,
                                                  onChanged: (value) =>
                                                      textController.text =
                                                          value,
                                                  onEditingComplete: () =>
                                                      setState(() {
                                                    editMode = false;
                                                  }),
                                                )),
                                  playAlign(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        ConstrainedBox(
                          constraints:
                              const BoxConstraints(minWidth: double.infinity),
                          child: createAction(
                            onPressed: snapshot.data != null
                                ? () => Navigator.of(context).pop(InfoMessage(
                                    content: textController.text,
                                    timeStamp: int.parse(p.withoutExtension(
                                        p.basename(widget.filePath)))))
                                : null,
                            action: ConstrainedBox(
                              constraints:
                                  const BoxConstraints(maxWidth: 250 / 2),
                              child: Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                  Align(
                                    alignment: const Alignment(-1, 0),
                                    child: Builder(
                                        builder: (context) => Icon(
                                            CupertinoIcons.shift,
                                            color: DefaultTextStyle.of(context)
                                                .style
                                                .color)),
                                  ),
                                  const Center(child: Text('Confirm')),
                                ],
                              ),
                            ),
                          ),
                        ),
                        ConstrainedBox(
                          constraints:
                              const BoxConstraints(minWidth: double.infinity),
                          child: createAction(
                            onPressed: snapshot.data != null
                                ? () => setState(() {
                                      editMode = true;
                                      focusNode.requestFocus();
                                    })
                                : null,
                            action: ConstrainedBox(
                              constraints:
                                  const BoxConstraints(maxWidth: 250 / 2),
                              child: Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                  Align(
                                    alignment: const Alignment(-1, 0),
                                    child: Builder(
                                        builder: (context) => Icon(
                                            CupertinoIcons
                                                .pencil_ellipsis_rectangle,
                                            color: DefaultTextStyle.of(context)
                                                .style
                                                .color)),
                                  ),
                                  const Center(child: Text('Edit')),
                                ],
                              ),
                            ),
                          ),
                        ),
                        ConstrainedBox(
                          constraints:
                              const BoxConstraints(minWidth: double.infinity),
                          child: createAction(
                            isDestructiveAction: true,
                            onPressed: () {
                              File(widget.filePath).delete();
                              Navigator.of(context).pop(null);
                            },
                            action: ConstrainedBox(
                              constraints:
                                  const BoxConstraints(maxWidth: 250 / 2),
                              child: Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                  Align(
                                    alignment: const Alignment(-1, 0),
                                    child: Builder(builder: (context) {
                                      final color = DefaultTextStyle.of(context)
                                          .style
                                          .color;
                                      return Icon(CupertinoIcons.delete_simple,
                                          color: color);
                                    }),
                                  ),
                                  const Center(child: Text('Destruct')),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget createAction(
      {VoidCallback? onPressed,
      required Widget action,
      bool isDestructiveAction = false}) {
    return Material(
      type: MaterialType.transparency,
      shape: const Border(top: BorderSide(color: CupertinoColors.systemGrey4)),
      child: InkWell(
        onTap: onPressed,
        child: AbsorbPointer(
          child: PlatformDialogAction(
            onPressed: onPressed,
            child: action,
            cupertino: (_, __) => CupertinoDialogActionData(
                isDestructiveAction: isDestructiveAction),
          ),
        ),
      ),
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
      ));
}
