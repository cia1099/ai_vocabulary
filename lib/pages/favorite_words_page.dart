import 'dart:math' as math;
import 'package:ai_vocabulary/app_settings.dart';
import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/model/collections.dart';
import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:ai_vocabulary/utils/handle_except.dart';
import 'package:ai_vocabulary/utils/load_word_route.dart';
import 'package:ai_vocabulary/utils/phonetic.dart' show playPhonetic;
import 'package:ai_vocabulary/utils/regex.dart';
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:ai_vocabulary/widgets/flashcard.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../app_route.dart';
import '../widgets/filter_input_bar.dart';
import 'vocabulary_page.dart';

class FavoriteWordsPage extends StatefulWidget {
  final CollectionMark mark;
  final List<Vocabulary> words;
  const FavoriteWordsPage({super.key, required this.mark, required this.words});

  @override
  State<FavoriteWordsPage> createState() => _FavoriteWordsPageState();
}

class _FavoriteWordsPageState extends State<FavoriteWordsPage> {
  final textController = TextEditingController();
  late var words = widget.words;
  late List<GlobalObjectKey> capitalKeys;
  ColorScheme? markScheme;

  Future<Iterable<Vocabulary>> get fetchDB async {
    final wordIDs = MyDB().fetchWordIDsByMarkID(widget.mark.id);
    return loadWordList(wordIDs).last;
  }

  late VoidCallback filterListener = () => filterWord(textController.text);

  @override
  void initState() {
    super.initState();
    MyDB().addListener(filterListener);
  }

  @override
  void dispose() {
    MyDB().removeListener(filterListener);
    capitalKeys.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hPadding = MediaQuery.of(context).size.width / 32;
    words.sort((a, b) => a.word.compareTo(b.word));
    final capitals = words.map((e) => e.word[0].toUpperCase()).toSet();
    capitalKeys = capitals.map((e) => GlobalObjectKey(e)).toList();
    if (widget.mark.color != null) {
      markScheme = ColorScheme.fromSeed(
        seedColor: Color(widget.mark.color!),
        brightness: Theme.of(context).brightness,
      );
    }
    final title = widget.mark.name.replaceAll(RegExp(r'\n'), ' ');
    final appBarColor =
        markScheme?.primaryContainer.withAlpha(0) ??
        kCupertinoSheetColor.resolveFrom(context);
    // markScheme = markScheme?.copyWith(brightness: Theme.of(context).brightness);
    return Scaffold(
      body: SafeArea(
        top: false,
        child: MediaQuery.removeViewInsets(
          context: context,
          removeBottom: true,
          child: Stack(
            children: [
              CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverStack(
                    insetOnOverlap: true,
                    children: [
                      SliverPositioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color:
                                markScheme?.primaryContainer ??
                                kCupertinoSheetColor.resolveFrom(context),
                            gradient: widget.mark.gradient(
                              context,
                              rotate: -math.pi / 4,
                            ),
                          ),
                        ),
                      ),
                      MultiSliver(
                        children: [
                          PlatformSliverAppBar(
                            stretch: true,
                            backgroundColor: appBarColor,
                            material:
                                (_, __) => MaterialSliverAppBarData(
                                  pinned: true,
                                  expandedHeight: kExpandedSliverAppBarHeight,
                                  flexibleSpace: FlexibleSpaceBar(
                                    title: Text(title),
                                    titlePadding: const EdgeInsets.only(
                                      left: 54,
                                      bottom: 16,
                                    ),
                                    stretchModes: const [
                                      StretchMode.zoomBackground,
                                      StretchMode.blurBackground,
                                      StretchMode.fadeTitle,
                                    ],
                                    background: FittedBox(
                                      fit: BoxFit.contain,
                                      child: ColorFiltered(
                                        colorFilter: ColorFilter.mode(
                                          Theme.of(
                                            context,
                                          ).iconTheme.color!.withAlpha(85),
                                          BlendMode.modulate,
                                        ),
                                        child: Icon(
                                          widget.mark.icon == null
                                              ? Icons.abc
                                              : IconData(
                                                widget.mark.icon!,
                                                fontFamily: 'CupertinoIcons',
                                                fontPackage: 'cupertino_icons',
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            cupertino:
                                (_, __) => CupertinoSliverAppBarData(
                                  title: Text(title),
                                  previousPageTitle: 'Collections',
                                  border: null,
                                  enableBackgroundFilterBlur: false,
                                ),
                          ),
                          SliverResizingHeader(
                            minExtentPrototype: SizedBox.fromSize(
                              size: const Size.fromHeight(
                                kTextTabBarHeight + 10,
                              ),
                            ),
                            maxExtentPrototype: SizedBox.fromSize(
                              size: const Size.fromHeight(
                                kTextTabBarHeight + 10,
                              ),
                            ),
                            child: FilterInputBar(
                              padding: EdgeInsets.only(
                                bottom: 10,
                                right: hPadding,
                                left: hPadding,
                              ),
                              controller: textController,
                              hintText: 'Filter word',
                              onChanged: (p0) => filterWord(p0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ...takeSections(),
                ],
              ),
              Positioned(
                right: hPadding / 2,
                top: kToolbarHeight * 3.6,
                bottom: 0,
                child: indexBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Iterable<Widget> takeSections() {
    final hPadding = MediaQuery.sizeOf(context).width / 32;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Iterable.generate(capitalKeys.length, (i) {
      final capital = capitalKeys[i].value;
      final sectionWords = words.where(
        (w) => w.word[0].toUpperCase() == capital,
      );
      return MultiSliver(
        pushPinnedChildren: true,
        children: [
          SliverPinnedHeader(
            key: capitalKeys[i],
            child: Container(
              height: kTextTabBarHeight * math.sqrt1_2,
              padding: EdgeInsets.symmetric(horizontal: hPadding),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    strokeAlign: -1,
                    color: colorScheme.outlineVariant,
                  ),
                ),
                color: (markScheme?.primaryContainer ??
                        kCupertinoSheetColor.resolveFrom(context))
                    .withAlpha(0xf0),
              ),
              alignment: const Alignment(-1, 1),
              child: Text(
                capital.toString(),
                textScaler: TextScaler.linear((1 + math.sqrt(5)) / 2),
                style: TextStyle(color: markScheme?.onPrimaryContainer),
              ),
            ),
          ),
          SliverList.builder(
            itemBuilder: (context, index) {
              final word = sectionWords.elementAt(index);
              final accent = AppSettings.of(context).accent;
              final locate = AppSettings.of(context).translator;
              var fTranslate = word.requireSpeechAndTranslation(locate);
              final phonetics = word.getPhonetics();
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Offstage(
                    offstage: index == 0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: DottedLine(
                        dashColor: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                  PlatformListTile(
                    title: Text.rich(
                      TextSpan(
                        children: [
                          ...matchFilterTextSpan(
                            text: word.word,
                            style: textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)
                                .apply(fontSizeFactor: math.sqrt2),
                          ),
                          const TextSpan(text: '\n'),
                          TextSpan(
                            text: phonetics.firstOrNull?.phonetic,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          TextSpan(text: '\t' * 4),
                          WidgetSpan(
                            child: PlatformIconButton(
                              onPressed: playPhonetic(
                                null,
                                word: word.word,
                                gTTs: accent.gTTS,
                              ),
                              padding: EdgeInsets.zero,
                              icon: const Icon(CupertinoIcons.volume_up),
                              cupertino:
                                  (_, __) => CupertinoIconButtonData(
                                    minSize: textTheme.bodyMedium?.fontSize,
                                  ),
                              material:
                                  (_, __) => MaterialIconButtonData(
                                    style: IconButton.styleFrom(
                                      minimumSize: Size.square(
                                        textTheme.bodyMedium!.fontSize!,
                                      ),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                            ),
                          ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: textTheme.titleMedium,
                    ),
                    subtitle: StatefulBuilder(
                      builder:
                          (context, setState) => FutureBuilder(
                            future: fTranslate,
                            initialData: word.getSpeechAndTranslation,
                            builder: (context, snapshot) {
                              final isWaiting =
                                  snapshot.connectionState ==
                                  ConnectionState.waiting;
                              return Text.rich(
                                TextSpan(
                                  children: [
                                    if (isWaiting)
                                      WidgetSpan(
                                        child:
                                            CircularProgressIndicator.adaptive(),
                                      ),
                                    if (snapshot.hasError && !isWaiting)
                                      WidgetSpan(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 4,
                                          ),
                                          child: GestureDetector(
                                            onTap:
                                                () => setState(() {
                                                  fTranslate = word
                                                      .requireSpeechAndTranslation(
                                                        locate,
                                                      );
                                                }),
                                            child: Icon(
                                              PlatformIcons(context).refresh,
                                            ),
                                          ),
                                        ),
                                      ),
                                    TextSpan(
                                      text:
                                          snapshot.hasError
                                              ? messageExceptions(
                                                snapshot.error,
                                              )
                                              : snapshot.data,
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodyLarge,
                              );
                            },
                          ),
                    ),
                    // Wrap(
                    //   spacing: 8,
                    //   children: word.definitions
                    //       .map((d) => Text(
                    //             speechShortcut(d.partOfSpeech),
                    //             style: textTheme.bodyLarge,
                    //           ))
                    //       .toList(),
                    // ),
                    trailing: const CupertinoListTileChevron(),
                    onTap:
                        () => Navigator.push(
                          context,
                          platformPageRoute(
                            context: context,
                            builder: (context) => VocabularyPage(word: word),
                            settings: const RouteSettings(
                              name: AppRoute.vocabulary,
                            ),
                          ),
                        ),
                    // cupertino: (_, __) => CupertinoListTileData(
                    //     // backgroundColor:
                    //     //     kCupertinoSheetColor.resolveFrom(context),
                    //     ),
                  ),
                ],
              );
            },
            // prototypeItem: Column(
            //   children: [
            //     const DottedLine(),
            //     PlatformListTile(
            //       title: Text.rich(
            //         TextSpan(
            //           children: [
            //             TextSpan(
            //               text: ' ',
            //               style: textTheme.titleMedium
            //                   ?.copyWith(fontWeight: FontWeight.w600)
            //                   .apply(fontSizeFactor: math.sqrt2),
            //             ),
            //             const TextSpan(text: '\n'),
            //             const TextSpan(text: ' '),
            //           ],
            //         ),
            //         maxLines: 2,
            //         style: textTheme.titleMedium,
            //       ),
            //       subtitle: Text('', style: textTheme.bodyLarge),
            //     ),
            //   ],
            // ),
            itemCount: sectionWords.length,
          ),
        ],
      );
    });
  }

  Iterable<TextSpan> matchFilterTextSpan({
    required String text,
    TextStyle? style,
  }) {
    final pattern = textController.text;
    final matches = text.matchIndexes(pattern);
    if (matches.isEmpty) return [TextSpan(text: text, style: style)];
    return List.generate(
      text.length,
      (i) => TextSpan(
        text: text[i],
        style:
            !matches.contains(i)
                ? style
                : style?.apply(
                  backgroundColor:
                      Theme.of(context).colorScheme.tertiaryContainer,
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                ),
      ),
    );
  }

  void filterWord(String query) async {
    final queryWords = (await fetchDB).where(
      (word) => word.word.contains(query.toLowerCase()),
    );
    setState(() {
      words = queryWords.toList();
    });
  }

  Widget indexBar() {
    final textTheme = Theme.of(context).textTheme;
    return Wrap(
      direction: Axis.vertical,
      alignment: WrapAlignment.center,
      spacing: textTheme.bodyMedium!.fontSize! / 4,
      children:
          capitalKeys
              .map(
                (key) => PlatformTextButton(
                  onPressed: () {
                    Scrollable.ensureVisible(key.currentContext!);
                  },
                  padding: EdgeInsets.zero,
                  material:
                      (_, __) => MaterialTextButtonData(
                        style: TextButton.styleFrom(
                          minimumSize: Size.square(
                            textTheme.bodyMedium!.fontSize!,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                  cupertino:
                      (_, __) => CupertinoTextButtonData(
                        minSize: textTheme.bodyMedium?.fontSize,
                      ),
                  child: Text(key.value.toString()),
                ),
              )
              .toList(),
    );
  }
}
