import 'dart:math' show sqrt2;

import 'package:ai_vocabulary/api/dict_api.dart';
import 'package:ai_vocabulary/app_settings.dart';
import 'package:ai_vocabulary/effects/show_toast.dart';
import 'package:ai_vocabulary/utils/function.dart';
import 'package:ai_vocabulary/utils/handle_except.dart';
import 'package:ai_vocabulary/widgets/align_paragraph.dart';
import 'package:ai_vocabulary/widgets/imagen_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../utils/clickable_text_mixin.dart';

class ExampleParagraph extends StatefulWidget {
  const ExampleParagraph({
    super.key,
    required this.example,
    required this.patterns,
    this.mark,
  });

  final String example;
  final Iterable<String> patterns;
  final Widget? mark;

  @override
  State<ExampleParagraph> createState() => _ExampleParagraphState();
}

class _ExampleParagraphState extends State<ExampleParagraph>
    with ClickableTextStateMixin {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final style = textTheme.bodyMedium?.apply(
      color: colorScheme.onPrimaryContainer,
      fontSizeFactor: sqrt2,
    );
    final accent = AppSettings.of(context).accent;
    final voicer = AppSettings.of(context).voicer;
    final textScaler = MediaQuery.textScalerOf(context);
    return AlignParagraph(
      xInterval: 4,
      mark: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: GestureDetector(
          onTap: () => showPlatformDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => ImagenDialog(widget.example),
          ),
          child:
              widget.mark ??
              CircleAvatar(
                backgroundColor: colorScheme.primary,
                radius: textScaler.scale(
                  textTheme.bodySmall?.fontSize
                          .scale(textTheme.bodySmall?.height)
                          .scale(.4) ??
                      .0,
                ),
              ),
        ),
      ),
      paragraph: SelectionArea(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                children: clickableWords(
                  widget.example,
                  patterns: widget.patterns,
                ),
              ),
              // const TextSpan(text: '\t\t'),
              WidgetSpan(
                child: PlatformWidgetBuilder(
                  material: (_, child, __) => InkWell(
                    onTap: () =>
                        soundAzure(
                          widget.example,
                          lang: accent.azure.lang,
                          sound: voicer,
                        ).onError(
                          (e, _) => context.mounted
                              ? showToast(
                                  context: context,
                                  child: Text(messageExceptions(e)),
                                )
                              : null,
                        ),
                    child: child,
                  ),
                  cupertino: (_, child, __) => GestureDetector(
                    onTap: () =>
                        soundAzure(
                          widget.example,
                          lang: accent.azure.lang,
                          sound: voicer,
                        ).onError(
                          (e, _) => context.mounted
                              ? showToast(
                                  context: context,
                                  child: Text(messageExceptions(e)),
                                )
                              : null,
                        ),
                    child: child,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: style?.fontSize?.scale(.5) ?? 0,
                    ),
                    child: Icon(
                      CupertinoIcons.volume_up,
                      size: textTheme.bodyLarge?.fontSize.scale(
                        textTheme.bodyLarge?.height,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          style: style,
        ),
      ),
      paragraphStyle: style,
    );
  }
}
