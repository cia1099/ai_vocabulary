import 'dart:math' as math;
import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:ai_vocabulary/provider/word_provider.dart';
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../app_route.dart';
import '../widgets/definition_tile.dart';
import '../widgets/filter_input_bar.dart';
import 'vocabulary_page.dart';

class FavoriteWordsPage extends StatefulWidget {
  const FavoriteWordsPage({super.key});

  @override
  State<FavoriteWordsPage> createState() => _FavoriteWordsPageState();
}

class _FavoriteWordsPageState extends State<FavoriteWordsPage> {
  late var words = fetchDB.toList();
  late List<GlobalObjectKey> capitalKeys;

  Iterable<Vocabulary> get fetchDB => WordProvider().subList();

  @override
  Widget build(BuildContext context) {
    final hPadding = MediaQuery.of(context).size.width / 32;
    words.sort((a, b) => a.word.compareTo(b.word));
    final capitals = words.map((e) => e.word[0]).toSet();
    capitalKeys = capitals.map((e) => GlobalObjectKey(e)).toList();
    return PlatformScaffold(
      body: SafeArea(
        top: false,
        child: MediaQuery.removeViewInsets(
          context: context,
          removeBottom: true,
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  PlatformSliverAppBar(
                    stretch: true,
                    title: const Text("Collected words"),
                    backgroundColor: kCupertinoSheetColor.resolveFrom(context),
                    material: (_, __) => MaterialSliverAppBarData(
                        pinned: true,
                        flexibleSpace: const FlexibleSpaceBar(
                          stretchModes: [
                            StretchMode.zoomBackground,
                            StretchMode.blurBackground,
                            StretchMode.fadeTitle,
                          ],
                        )),
                    // cupertino: (_, __) => CupertinoSliverAppBarData(),
                  ),
                  SliverResizingHeader(
                      minExtentPrototype: SizedBox.fromSize(
                          size: const Size.fromHeight(kTextTabBarHeight + 10)),
                      maxExtentPrototype: SizedBox.fromSize(
                          size: const Size.fromHeight(kTextTabBarHeight + 10)),
                      child: FilterInputBar(
                        padding: EdgeInsets.only(
                            bottom: 10, right: hPadding, left: hPadding),
                        backgroundColor:
                            kCupertinoSheetColor.resolveFrom(context),
                        // focusNode: focusNode,
                        // controller: textController,
                        hintText: 'find it',
                        // onChanged: (p0) {
                        //   preventQuicklyChanged?.cancel();
                        //   preventQuicklyChanged =
                        //       Timer(Durations.medium4, () => filterMark(p0));
                        // },
                      )),
                  ...takeSections(),
                ],
              ),
              Positioned(
                  right: hPadding / 2,
                  top: kToolbarHeight * 3.6,
                  bottom: 0,
                  child: indexBar()),
            ],
          ),
        ),
      ),
    );
  }

  Iterable<Widget> takeSections() {
    final hPadding = MediaQuery.of(context).size.width / 32;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Iterable.generate(capitalKeys.length, (i) {
      final capital = capitalKeys[i].value;
      final sectionWords = words.where((w) => w.word[0] == capital);
      return MultiSliver(
        pushPinnedChildren: true,
        children: [
          SliverPinnedHeader(
            key: capitalKeys[i],
            child: Container(
              height: kTextTabBarHeight, //* math.sqrt2,
              padding: EdgeInsets.symmetric(horizontal: hPadding),
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        strokeAlign: -1, color: colorScheme.outlineVariant)),
                color:
                    kCupertinoSheetColor.resolveFrom(context).withAlpha(0xf0),
              ),
              alignment: const Alignment(-1, 1),
              child: Text(
                capital.toString().toUpperCase(),
                textScaler: const TextScaler.linear(2.5),
              ),
            ),
          ),
          SliverFixedExtentList.builder(
              itemBuilder: (context, index) {
                final word = sectionWords.elementAt(index);
                final phonetics = word.getPhonetics();
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Offstage(
                      offstage: index == 0,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: DottedLine(
                            dashColor: Theme.of(context).dividerColor),
                      ),
                    ),
                    PlatformListTile(
                      title: Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: word.word,
                            style: textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)
                                .apply(fontSizeFactor: math.sqrt2),
                          ),
                          TextSpan(text: '\t' * 4),
                          TextSpan(
                              text: phonetics.firstOrNull?.phonetic,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              )),
                          TextSpan(text: '\t' * 2),
                          WidgetSpan(
                              child: PlatformIconButton(
                            onPressed: playPhonetic(null, word: word.word),
                            padding: EdgeInsets.zero,
                            icon: const Icon(CupertinoIcons.volume_up),
                            cupertino: (_, __) => CupertinoIconButtonData(
                                minSize: textTheme.bodyMedium?.fontSize),
                            material: (_, __) => MaterialIconButtonData(
                                style: IconButton.styleFrom(
                                    minimumSize: Size.square(
                                        textTheme.bodyMedium!.fontSize!),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap)),
                          )),
                        ]),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: textTheme.titleMedium,
                      ),
                      subtitle: Wrap(
                        spacing: 8,
                        children: word.definitions
                            .map((d) => Text(
                                  speechShortcut(d.partOfSpeech),
                                  style: textTheme.bodyLarge,
                                ))
                            .toList(),
                      ),
                      onTap: () => Navigator.push(
                          context,
                          platformPageRoute(
                            context: context,
                            builder: (context) => VocabularyPage(word: word),
                            settings:
                                const RouteSettings(name: AppRoute.vocabulary),
                          )),
                      // cupertino: (_, __) => CupertinoListTileData(
                      //     // backgroundColor:
                      //     //     kCupertinoSheetColor.resolveFrom(context),
                      //     ),
                    )
                  ],
                );
              },
              itemExtent: 76,
              itemCount: sectionWords.length),
        ],
      );
    });
  }

  Widget indexBar() {
    final textTheme = Theme.of(context).textTheme;
    return Wrap(
      direction: Axis.vertical,
      alignment: WrapAlignment.center,
      spacing: textTheme.bodyMedium!.fontSize! / 4,
      children: capitalKeys
          .map((key) => PlatformTextButton(
                onPressed: () {
                  Scrollable.ensureVisible(key.currentContext!);
                },
                padding: EdgeInsets.zero,
                material: (_, __) => MaterialTextButtonData(
                    style: TextButton.styleFrom(
                        minimumSize:
                            Size.square(textTheme.bodyMedium!.fontSize!),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap)),
                cupertino: (_, __) => CupertinoTextButtonData(
                    minSize: textTheme.bodyMedium?.fontSize),
                child: Text(
                  key.value.toString().toUpperCase(),
                ),
              ))
          .toList(),
    );
  }
}

String createName() {
  final rng = math.Random();
  final lowerChars = String.fromCharCodes(
      Iterable.generate(5 + rng.nextInt(6), (_) => rng.nextInt(26) + 97));
  return lowerChars[0].toUpperCase() + lowerChars.substring(1);
}
