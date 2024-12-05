import 'package:ai_vocabulary/api/dict_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:text2speech/text2speech.dart';

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
  late final futureRecognition = recognizeSpeech(widget.filePath);
  final textController = TextEditingController();
  var editMode = false;

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
                    builder: (context, snapshot) {
                      final recognition = snapshot.data;
                      textController.text = recognition?.text ?? '';
                      return Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            textController.text.isEmpty
                                ? 'Speech Recognize...'
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
                                                    color:
                                                        colorScheme.tertiary))
                                            : snapshot.hasError
                                                ? Center(
                                                    child: Text(
                                                        '${snapshot.error}',
                                                        style: TextStyle(
                                                            color: colorScheme
                                                                .error)))
                                                : CupertinoTextField.borderless(
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
                                                        TextAlignVertical
                                                            .center,
                                                    textAlign: TextAlign.center,
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
                                              CupertinoIcons.hand_thumbsup,
                                              color:
                                                  DefaultTextStyle.of(context)
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
                              isDestructiveAction: true,
                              onPressed: () {},
                              action: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 250 / 2),
                                child: Stack(
                                  alignment: AlignmentDirectional.center,
                                  children: [
                                    Align(
                                      alignment: const Alignment(1, 0),
                                      child: Builder(builder: (context) {
                                        final color =
                                            DefaultTextStyle.of(context)
                                                .style
                                                .color;
                                        return Icon(
                                            CupertinoIcons.delete_simple,
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
                      );
                    },
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

  Widget cupertinoSheet(BuildContext context) {
    final textTheme = CupertinoTheme.of(context).textTheme;
    return Transform.translate(
      offset: const Offset(0, -60),
      child: CupertinoActionSheet(
        title: Text('Did you say this paragraph?',
            style: textTheme.navTitleTextStyle),
        message: ConstrainedBox(
          constraints:
              const BoxConstraints(minHeight: 100, minWidth: double.infinity),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              Card.filled(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                      1, (_) => const Text('Did you say this paragraph?')),
                ),
              ),
              Align(
                  alignment: const Alignment(-1, 1),
                  child: Transform.translate(
                    offset: const Offset(-10, 10),
                    child: PlatformTextButton(
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      material: (_, __) => MaterialTextButtonData(
                          style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size.square(36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )),
                      cupertino: (_, __) =>
                          CupertinoTextButtonData(minSize: 36),
                      child:
                          const Icon(CupertinoIcons.play_circle_fill, size: 36),
                    ),
                  ))
            ],
          ),
        ),
        actions: [
          PlatformDialogAction(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 250),
              child: const Row(
                // spacing: 8,
                // crossAxisAlignment: WrapCrossAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(CupertinoIcons.hand_thumbsup),
                  Text('Confirm'),
                ],
              ),
            ),
          ),
          PlatformDialogAction(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 250 / 2),
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Align(
                    alignment: const Alignment(-1, 0),
                    child: Builder(builder: (context) {
                      final color = DefaultTextStyle.of(context).style.color;
                      return Icon(CupertinoIcons.hand_thumbsup, color: color);
                    }),
                  ),
                  const Center(child: Text('Confirm')),
                ],
              ),
            ),
          ),
          PlatformDialogAction(
            cupertino: (_, __) => CupertinoDialogActionData(
                isDestructiveAction: true, isDefaultAction: true),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 250 / 2),
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  const Center(child: Text('Destruct')),
                  Align(
                    alignment: const Alignment(1, 0),
                    child: Builder(builder: (context) {
                      final color = DefaultTextStyle.of(context).style.color;
                      return Icon(CupertinoIcons.delete_simple, color: color);
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
