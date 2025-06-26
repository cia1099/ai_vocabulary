import 'dart:ui' as ui;

import 'package:ai_vocabulary/api/dict_api.dart';
import 'package:ai_vocabulary/app_settings.dart';
import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/effects/show_toast.dart';
import 'package:ai_vocabulary/effects/tip_overlay.dart';
import 'package:ai_vocabulary/effects/transient.dart';
import 'package:ai_vocabulary/model/acquaintance.dart';
import 'package:ai_vocabulary/model/collections.dart';
import 'package:ai_vocabulary/utils/function.dart';
import 'package:ai_vocabulary/utils/handle_except.dart';
import 'package:ai_vocabulary/widgets/align_paragraph.dart';
import 'package:ai_vocabulary/widgets/flashcard.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:image/image.dart' as image;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';

class PunchOutPage extends StatefulWidget {
  const PunchOutPage({super.key});

  @override
  State<PunchOutPage> createState() => _PunchOutPageState();
}

class _PunchOutPageState extends State<PunchOutPage> {
  final paintKey = ValueNotifier(const GlobalObjectKey(0));
  var myToken = getConsumeTokens();
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final colorScheme = Theme.of(context).colorScheme;
    const aspect = 16 / 9;
    return ValueListenableBuilder(
      valueListenable: paintKey,
      builder: (context, key, child) {
        final colorFuture = ColorScheme.fromImageProvider(
          provider: NetworkImage('$punchCardUrl/${key.value}'),
          brightness: Theme.of(context).brightness,
          dynamicSchemeVariant: DynamicSchemeVariant.content,
        );
        return FutureBuilder(
          future: colorFuture,
          builder: (context, snapshot) => PlatformScaffold(
            backgroundColor: snapshot.data?.surfaceContainer,
            appBar: PlatformAppBar(
              backgroundColor: snapshot.data?.inversePrimary,
            ),
            body: child,
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: screenWidth / 32,
        children: [
          Flexible(
            flex: 2,
            child: ColoredBox(
              color: const Color(0x00000000), //colorScheme.surfaceContainer,
              child: RotatedBox(
                quarterTurns: -1,
                child: ListWheelScrollView.useDelegate(
                  onSelectedItemChanged: (index) =>
                      paintKey.value = GlobalObjectKey(index),
                  physics: const FixedExtentScrollPhysics(),
                  overAndUnderCenterOpacity: .9,
                  itemExtent: screenWidth * .75,
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 7,
                    builder: (context, index) => AspectRatio(
                      aspectRatio: aspect,
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: ValueListenableBuilder(
                          valueListenable: paintKey,
                          builder: (context, key, child) => index == key.value
                              ? RepaintBoundary(key: key, child: child)
                              : child!,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              kRadialReactionRadius,
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Image.network(
                                    width: double.infinity,
                                    '$punchCardUrl/$index',
                                    fit: BoxFit.fill,
                                    loadingBuilder: loadingBuilder,
                                    frameBuilder: generateImageLoader,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: MediaQuery(
                                    data: MediaQueryData(
                                      textScaler: TextScaler.noScaling,
                                    ),
                                    child: cardPanel(colorScheme),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Flexible(flex: 1, child: buildBottomButtons(colorScheme)),
        ],
      ),
    );
  }

  Widget cardPanel(ColorScheme colorScheme) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      color: CupertinoColors.tertiarySystemBackground.resolveFrom(context),
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Wrap(
            spacing: 8,
            children: [
              const Icon(CupertinoIcons.person),
              Text.rich(
                TextSpan(
                  text: 'Keep punch ',
                  children: [
                    TextSpan(
                      text: '${MyDB().getPastPunchDays() + 1}',
                      style: TextStyle(
                        fontSize: textTheme.titleMedium?.fontSize.scale(1.2),
                        fontWeight: textTheme.titleMedium?.fontWeight,
                        // color: colorScheme.primary,
                      ),
                    ),
                    const TextSpan(text: ' days'),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  text: 'Study ',
                  children: [
                    TextSpan(
                      text: MyDB().fetchStudyCounts().totalStudy,
                      style: TextStyle(
                        fontSize: textTheme.titleMedium?.fontSize.scale(1.2),
                        fontWeight: textTheme.titleMedium?.fontWeight,
                        // color: colorScheme.primary,
                      ),
                    ),
                    const TextSpan(text: ' words'),
                  ],
                ),
              ),
            ],
          ),
          DottedLine(dashColor: colorScheme.outline),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Wrap(
                  children: [
                    Text(
                      'AI Vocabulary Punch Card',
                      style: textTheme.titleMedium,
                    ),
                    const Text('Help you to memorize vocabulary'),
                  ],
                ),
              ),
              Image.network(
                height: kMinInteractiveDimension,
                '$punchCardUrl/qr_code',
                fit: BoxFit.contain,
                loadingBuilder: loadingBuilder,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildBottomButtons(ColorScheme colorScheme) {
    final textTheme = Theme.of(context).textTheme;
    final cupertinoTextTheme = CupertinoTheme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final textScaler = MediaQuery.textScalerOf(context);
    return Wrap(
      direction: Axis.vertical,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        GestureDetector(
          onTap: punchOut,
          child: Container(
            width: 300,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kRadialReactionRadius * 2),
              gradient: CollectionMark(
                id: 0,
                name: '',
                index: -1,
                color: colorScheme.primary.toARGB32(),
              ).gradient(context),
            ),
            child: FutureBuilder(
              future: getTodayShares().onError(
                (_, __) => "Get tokens for sharing",
              ),
              initialData: "Get tokens for sharing",
              builder: (context, snapshot) {
                final msg = snapshot.data!;
                return Text.rich(
                  TextSpan(
                    text: msg,
                    children: [
                      TextSpan(
                        text:
                            '\nGet tokens only when returning to the app after sharing',
                        style: cupertinoTextTheme.textStyle.copyWith(
                          fontSize: textTheme.labelSmall?.fontSize,
                          // height: textTheme.labelSmall?.height,
                          color: CupertinoColors.systemGrey4.resolveFrom(
                            context,
                          ),
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: textTheme.titleMedium?.fontSize,
                    height: textTheme.titleMedium?.height,
                    fontWeight: textTheme.titleMedium?.fontWeight,
                  ),
                );
              },
            ),
          ),
        ),
        Container(
          height: 64,
          width: 300,
          decoration: BoxDecoration(
            color: colorScheme.inverseSurface.withAlpha(0x80),
            borderRadius: BorderRadius.circular(kRadialReactionRadius / 2),
          ),
          child: Row(
            children: [
              LottieBuilder.asset('assets/lottie/coin1.json'),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'My token',
                          style: TextStyle(color: colorScheme.onInverseSurface),
                        ),
                        TipOverlay(
                          tipBuilder: (context) => Container(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              children: [
                                Text(
                                  "What can token do?",
                                  style: cupertinoTextTheme.textStyle.copyWith(
                                    height: 1.618,
                                  ),
                                ),
                                for (final canDo in _tokenListDo)
                                  AlignParagraph.text(
                                    paragraph: canDo,
                                    mark: Icon(
                                      CupertinoIcons.circle_fill,
                                      size: 10,
                                    ),
                                    xInterval: 4,
                                  ),
                              ],
                            ),
                          ),
                          child: Icon(
                            CupertinoIcons.question_circle,
                            size: textScaler.scale(20),
                            color: colorScheme.onInverseSurface,
                          ),
                        ),
                      ],
                    ),
                    FutureBuilder(
                      future: myToken,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator.adaptive(
                            backgroundColor: colorScheme.onInverseSurface,
                          );
                        }
                        final consumeTokens = snapshot.data;
                        if (consumeTokens == null) {
                          return Text(
                            "You are invalid for tokens, please register",
                            style: TextStyle(color: colorScheme.error),
                          );
                        }
                        return RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: NumberFormat.decimalPattern(
                                  locale,
                                ).format(consumeTokens),
                                style: TextStyle(
                                  fontSize: textTheme.titleMedium?.fontSize
                                      .scale(1.2),
                                  fontWeight: textTheme.titleMedium?.fontWeight,
                                ),
                              ),
                              TextSpan(
                                text:
                                    ' = ${NumberFormat.simpleCurrency(locale: locale).format(consumeTokens * 2e-2)}',
                              ),
                            ],
                            style: TextStyle(
                              color: colorScheme.onInverseSurface,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // TipOverlay(
              //   tipBuilder: (context) => Text("Shit man"),
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(
              //       vertical: 4,
              //       horizontal: 12,
              //     ),
              //     margin: const EdgeInsets.only(right: 8),
              //     decoration: BoxDecoration(
              //       color: colorScheme.onSurfaceVariant.withAlpha(0x80),
              //       borderRadius: BorderRadius.circular(16),
              //     ),
              //     child: Text(
              //       "What is token?",
              //       style: textTheme.bodySmall?.apply(
              //         color: colorScheme.onInverseSurface,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ],
    );
  }

  void punchOut() async {
    MyDB().upsertPunch(AppSettings.of(context).studyMinute);
    final boundary =
        paintKey.value.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    final paintData = await boundary?.toImage(pixelRatio: .5).then((img) async {
      final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
      final decode = image.decodePng(bytes!.buffer.asUint8List());
      return image.encodeJpg(decode!, quality: 90);
    });
    if (paintData == null) return debugPrint("Can't paint boundary");

    // final imgPath = p.join(MyDB().appDirectory, 'punch_out.jpg');
    // final img = await File(imgPath).writeAsBytes(paintData.buffer.asInt8List());
    const text = '''
#AI Vocabulary Punch Card# Day
Memorize words ✅
I'm memorizing words with AI Vocabulary, punch with me! https://ai-vocabulary.com
''';
    final share = await SharePlus.instance.share(
      ShareParams(
        text: text,
        files: [
          XFile.fromData(
            paintData,
            mimeType: "image/jpg",
            name: "punch_card.jpg",
          ),
        ],
        //[XFile(img.path, bytes: await img.readAsBytes())],
        subject: 'I am studying in AI vocabulary',
      ),
    );
    switch (share.status) {
      case ShareResultStatus.success:
        final msg = await putSharedApp(share.raw).onError(messageExceptions);
        if (mounted) {
          setState(() {
            myToken = getConsumeTokens();
          });
          showToast(
            context: context,
            alignment: const Alignment(0, .5),
            stay: Durations.extralong4 * 1.5,
            child: Text(msg),
          );
        }
      case ShareResultStatus.unavailable:
        print('There is something wrong');
      default:
        print('Dismiss punch out');
    }
    // img.delete();
  }
}

extension on StudyCount {
  String get totalStudy => '${newCount + reviewCount}';
}

const _tokenListDo = [
  "Engage in conversations with AI to practice using words by constructing sentences.",
  "Visualize examples into vivid pictures to impress yourself.",
  "Purchase supplementary and educational resources to enhance your learning experience.",
];
