import 'package:ai_vocabulary/utils/regex.dart';
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../model/vocabulary.dart';
import '../utils/clickable_text_mixin.dart';

class DefinitionSliders extends StatefulWidget {
  const DefinitionSliders({
    super.key,
    required this.definitions,
    required this.getMore,
  });

  final List<Definition> definitions;
  final void Function(double requiredHeight) getMore;
  static const double kDefaultHeight = 100.0;

  @override
  State<DefinitionSliders> createState() => _DefinitionSlidersState();
}

class _DefinitionSlidersState extends State<DefinitionSliders>
    with TickerProviderStateMixin, ClickableTextStateMixin {
  late final tabController = widget.definitions.length > 1
      ? TabController(length: widget.definitions.length, vsync: this)
      : null;
  final controller = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final topColor = CupertinoDynamicColor.withBrightness(
      color: colorScheme.surfaceBright,
      darkColor: colorScheme.surfaceDim,
    ).resolveFrom(context);
    final hsvTop = HSVColor.fromColor(topColor);
    final bottomColor = CupertinoDynamicColor.withBrightness(
      color: hsvTop.withValue(.975).toColor(),
      darkColor: hsvTop.withSaturation(1).toColor(),
    ).resolveFrom(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [topColor.withValues(alpha: .9), bottomColor],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(kRadialReactionRadius / 2),
      ),
      child: Row(
        spacing: 4,
        children: [
          tabController != null
              ? RotatedBox(
                  quarterTurns: 1,
                  child: TabPageSelector(
                    controller: tabController,
                    selectedColor: colorScheme.primary,
                  ),
                )
              : const SizedBox.square(dimension: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final titleStyle = textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                );
                final remainHeight =
                    constraints.maxHeight -
                    (titleStyle.fontSize! * titleStyle.height!);
                final style = textTheme.bodyLarge!;
                final maxLines =
                    remainHeight ~/ (style.fontSize! * style.height!);
                return PageView.builder(
                  scrollDirection: Axis.vertical,
                  controller: controller,
                  onPageChanged: (value) {
                    tabController?.animateTo(value);
                    widget.getMore(DefinitionSliders.kDefaultHeight);
                  },
                  itemBuilder: (context, index) {
                    final definition = widget.definitions[index];
                    final text = definition.index2Explanation();
                    final textPainter = TextPainter(
                      text: TextSpan(text: text, style: style),
                      maxLines: maxLines,
                      textDirection: TextDirection.ltr,
                    )..layout(maxWidth: constraints.maxWidth);
                    final overflowIndex = textPainter.overflowIndex(
                      constraints.maxWidth,
                    );
                    // print('overflow index = $overflowIndex');
                    // print('paint: ${textPainter.plainText}');
                    var splitText = textPainter.plainText;
                    var remainText = '';
                    if (overflowIndex > 0) {
                      splitText = splitText.substring(0, overflowIndex - 10);
                      final lastSpace = splitText.lastIndexOf(' ');
                      remainText = splitText.substring(lastSpace);
                      splitText = splitText.substring(0, lastSpace);
                    }
                    return MediaQuery(
                      //prevent system scale
                      data: MediaQueryData(textScaler: TextScaler.noScaling),
                      child: Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                definition.partOfSpeech,
                                style: titleStyle,
                              ).coloredSpeech(context: context),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    ...clickableWords(splitText),
                                    if (overflowIndex > 0) ...[
                                      TextSpan(text: '$remainText...'),
                                      TextSpan(
                                        text: 'more',
                                        style: style.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.primary,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            requireFittingHeight(
                                              TextSpan(
                                                text: text,
                                                style: style,
                                              ),
                                              constraints.maxWidth,
                                            );
                                          },
                                      ),
                                    ],
                                  ],
                                ),
                                style: style,
                                maxLines: maxLines,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          if (overflowIndex < 0 &&
                              constraints.maxHeight >
                                  DefinitionSliders.kDefaultHeight)
                            Align(
                              alignment: const Alignment(1, 1),
                              child: PlatformTextButton(
                                onPressed: () {
                                  widget.getMore(
                                    DefinitionSliders.kDefaultHeight,
                                  );
                                },
                                alignment: const Alignment(1, 1),
                                padding: EdgeInsets.zero,
                                child: Text(
                                  'hide',
                                  style: style.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                material: (_, __) => MaterialTextButtonData(
                                  style: TextButton.styleFrom(
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                  itemCount: widget.definitions.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void requireFittingHeight(TextSpan text, double maxWidth) {
    final textPainter = TextPainter(
      text: text,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    final titleStyle = Theme.of(
      context,
    ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600);
    widget.getMore(
      textPainter.height * 1.025 + titleStyle.fontSize! * titleStyle.height!,
    );
  }

  @override
  void initState() {
    super.initState();
    //Flutter's bug, it will display last page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.hasClients &&
          controller.page != null &&
          controller.page! > 1e-1) {
        debugPrint('shit bug fluter pageview at: ${controller.page}');
        controller.jumpToPage(0);
      }
    });
  }
}

// class DebugOverflow extends StatelessWidget {
//   const DebugOverflow({super.key});

//   @override
//   Widget build(BuildContext context) {
//     var defSliderHeight = DefinitionSliders.kDefaultHeight;
//     final screenWidth = MediaQuery.sizeOf(context).width;
//     final word = stage;
//     return PlatformScaffold(
//       appBar: PlatformAppBar(title: Text('overflow')),
//       body: Stack(
//         children: [
//           StatefulBuilder(
//             builder: (context, setState) {
//               return AnimatedPositioned(
//                 bottom: kFloatingActionButtonMargin * 5,
//                 duration: Durations.short2,
//                 height: defSliderHeight,
//                 width: screenWidth * .85,
//                 child: DefinitionSliders(
//                   definitions: word.definitions,
//                   getMore:
//                       (h) => setState(() {
//                         defSliderHeight = h;
//                       }),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
