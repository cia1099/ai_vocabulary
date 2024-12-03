import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class SpeechConfirmDialog extends StatelessWidget {
  const SpeechConfirmDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformAlertDialog(
      title: const Text('Did you say this paragraph?'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 100),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            SizedBox(
              width: double.maxFinite,
              child: Card.filled(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                      1, (_) => const Text('Did you say this paragraph?')),
                ),
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
                    cupertino: (_, __) => CupertinoTextButtonData(minSize: 36),
                    child:
                        const Icon(CupertinoIcons.play_circle_fill, size: 36),
                  ),
                ))
          ],
        ),
      ),
      actions: [
        // PlatformDialogAction(
        //   child: ConstrainedBox(
        //     constraints: const BoxConstraints(maxWidth: 250),
        //     child: const Row(
        //       // spacing: 8,
        //       // crossAxisAlignment: WrapCrossAlignment.center,
        //       mainAxisAlignment:
        //           MainAxisAlignment.spaceBetween,
        //       children: [
        //         Icon(CupertinoIcons.hand_thumbsup),
        //         Text('Confirm'),
        //       ],
        //     ),
        //   ),
        // ),
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
    );
  }
}
