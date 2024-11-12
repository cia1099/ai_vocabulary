import 'package:ai_vocabulary/api/dict_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:transparent_image/transparent_image.dart';

class ImagenDialog extends StatefulWidget {
  const ImagenDialog(this.prompt, {super.key});
  final String prompt;

  @override
  State<ImagenDialog> createState() => _ImagenDialogState();
}

class _ImagenDialogState extends State<ImagenDialog> {
  late final url =
      Uri.https(baseURL, '/dict/imagen/256', {'prompt': widget.prompt});
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
                  color: CupertinoColors.systemBackground,
                  width: width * .85,
                  height: height - 80,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                              height: height * .65,
                              alignment: Alignment.center,
                              child: Wrap(
                                direction: Axis.vertical,
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                children: [
                                  PlatformCircularProgressIndicator(),
                                  const Text(
                                      'Image is generating, please wait...')
                                ],
                              )),
                          FadeInImage(
                              key: ValueKey(DateTime.now()),
                              placeholder: MemoryImage(kTransparentImage),
                              width: width * .85,
                              height: height * .65,
                              fit: BoxFit.cover,
                              image: imageProvider),
                        ],
                      ),
                      Expanded(
                          child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        alignment: Alignment.centerLeft,
                        color: colorScheme.primaryContainer,
                        child: SelectableText(
                          widget.prompt,
                          style: textTheme.titleLarge!
                            ..apply(color: colorScheme.onPrimaryContainer),
                        ),
                      ))
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0, 1.1),
              child: PlatformIconButton(
                  onPressed: () =>
                      imageProvider.evict().then((_) => setState(() {})),
                  material: (_, __) => MaterialIconButtonData(iconSize: 48),
                  cupertino: (_, __) => CupertinoIconButtonData(minSize: 48),
                  cupertinoIcon: const Icon(
                    CupertinoIcons.refresh_circled_solid,
                    size: 48,
                  ),
                  icon: const Icon(
                    CupertinoIcons.refresh_circled_solid,
                  )),
            ),
            Align(
              alignment: const FractionalOffset(1, 0),
              child: PlatformIconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  material: (_, __) => MaterialIconButtonData(iconSize: 48),
                  cupertino: (_, __) => CupertinoIconButtonData(minSize: 48),
                  cupertinoIcon: const Icon(
                    CupertinoIcons.xmark_circle_fill,
                    size: 48,
                  ),
                  icon: const Icon(
                    CupertinoIcons.xmark_circle_fill,
                  )),
            )
          ],
        ),
      ),
    );
  }
}
