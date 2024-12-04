import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class SpeechConfirmDialog extends StatelessWidget {
  const SpeechConfirmDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = CupertinoTheme.of(context).textTheme;
    final hPadding = MediaQuery.of(context).size.width / 16;
    return Stack(
      children: [
        Align(
          alignment: const Alignment(0, .7),
          child: FractionallySizedBox(
            widthFactor: .9,
            child: CupertinoPopupSurface(
              child: Padding(
                padding: EdgeInsets.only(top: hPadding),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Text(
                      'Did you say this paragraph?',
                      style: textTheme.navTitleTextStyle,
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                          minHeight: 100, minWidth: double.infinity),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: hPadding),
                        child: IntrinsicHeight(
                          child: Stack(
                            fit: StackFit.passthrough,
                            children: [
                              Card.filled(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List<Widget>.generate(
                                      1,
                                      (_) => const Text(
                                          'Did you say this paragraph?')),
                                ),
                              ),
                              playAlign(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: hPadding, width: double.infinity),
                    ConstrainedBox(
                      constraints:
                          const BoxConstraints(minWidth: double.infinity),
                      child: Material(
                        type: MaterialType.transparency,
                        shape: const Border(
                            top:
                                BorderSide(color: CupertinoColors.systemGrey4)),
                        child: InkWell(
                          onTap: () => print('inkwell call'),
                          child: AbsorbPointer(
                            child: PlatformDialogAction(
                              onPressed: () => print('action'),
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 250 / 2),
                                child: Stack(
                                  alignment: AlignmentDirectional.center,
                                  children: [
                                    Align(
                                      alignment: const Alignment(-1, 0),
                                      child: Builder(builder: (context) {
                                        final color =
                                            DefaultTextStyle.of(context)
                                                .style
                                                .color;
                                        return Icon(
                                            CupertinoIcons.hand_thumbsup,
                                            color: color);
                                      }),
                                    ),
                                    const Center(child: Text('Confirm')),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ConstrainedBox(
                      constraints:
                          const BoxConstraints(minWidth: double.infinity),
                      child: Material(
                        type: MaterialType.transparency,
                        shape: const Border(
                            top:
                                BorderSide(color: CupertinoColors.systemGrey4)),
                        child: InkWell(
                          onTap: () {},
                          child: PlatformDialogAction(
                            cupertino: (_, __) => CupertinoDialogActionData(
                                isDestructiveAction: true),
                            child: ConstrainedBox(
                              constraints:
                                  const BoxConstraints(maxWidth: 250 / 2),
                              child: Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                  const Center(child: Text('Destruct')),
                                  Align(
                                    alignment: const Alignment(1, 0),
                                    child: Builder(builder: (context) {
                                      final color = DefaultTextStyle.of(context)
                                          .style
                                          .color;
                                      return Icon(CupertinoIcons.delete_simple,
                                          color: color);
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget playAlign() => Align(
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
          cupertino: (_, __) => CupertinoTextButtonData(minSize: 36),
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
