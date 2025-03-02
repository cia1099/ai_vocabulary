import 'package:ai_vocabulary/api/dict_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../effects/transient.dart';

class ImagenDialog extends StatefulWidget {
  const ImagenDialog(this.prompt, {super.key});
  final String prompt;

  @override
  State<ImagenDialog> createState() => _ImagenDialogState();
}

class _ImagenDialogState extends State<ImagenDialog> {
  late final url = Uri.http(baseURL, '/dict/imagen/256', {
    'prompt': widget.prompt,
  });
  late final imageProvider = NetworkImage(url.toString());
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * .95;
    final height = width * 1.2;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: SizedBox(
        height: height,
        width: width,
        child: Stack(
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(kRadialReactionRadius),
                child: Container(
                  color: CupertinoColors.systemBackground.resolveFrom(context),
                  width: width * .85,
                  height: height - 80,
                  child: Column(
                    children: [
                      Image(
                        key: ValueKey(DateTime.now()),
                        image: imageProvider,
                        fit: BoxFit.cover,
                        width: width * .85,
                        height: height * .65,
                        frameBuilder: (
                          context,
                          child,
                          frame,
                          wasSynchronouslyLoaded,
                        ) {
                          if (wasSynchronouslyLoaded) return child;
                          return Container(
                            height: height * .65,
                            alignment: Alignment.center,
                            child: generateImageLoader(
                              context,
                              child,
                              frame,
                              wasSynchronouslyLoaded,
                            ),
                          );
                        },
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          alignment: Alignment.centerLeft,
                          color: colorScheme.primaryContainer,
                          child: SelectableText(
                            widget.prompt,
                            style:
                                textTheme.titleLarge!..apply(
                                  color: colorScheme.onPrimaryContainer,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0, 1.1),
              child: PlatformIconButton(
                onPressed:
                    () => imageProvider.evict().then((_) => setState(() {})),
                material: (_, __) => MaterialIconButtonData(iconSize: 48),
                cupertino: (_, __) => CupertinoIconButtonData(minSize: 48),
                cupertinoIcon: const Icon(
                  CupertinoIcons.refresh_circled_solid,
                  size: 48,
                ),
                icon: const Icon(CupertinoIcons.refresh_circled_solid),
              ),
            ),
            Align(
              alignment: const FractionalOffset(1, 0),
              child: PlatformIconButton(
                onPressed: Navigator.of(context).pop,
                material: (_, __) => MaterialIconButtonData(iconSize: 48),
                cupertino: (_, __) => CupertinoIconButtonData(minSize: 48),
                cupertinoIcon: const Icon(
                  CupertinoIcons.xmark_circle_fill,
                  size: 48,
                ),
                icon: const Icon(CupertinoIcons.xmark_circle_fill),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
