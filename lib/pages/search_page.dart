import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/effects/dot3indicator.dart';
import 'package:ai_vocabulary/utils/handle_except.dart';
import 'package:ai_vocabulary/utils/load_more_listview.dart';
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:ai_vocabulary/utils/function.dart';
import 'package:ai_vocabulary/widgets/align_paragraph.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../api/dict_api.dart';
import '../app_route.dart';
import '../effects/transient.dart';
import '../model/vocabulary.dart';
import 'vocabulary_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final textController = TextEditingController();
  late final suffixIcon = Padding(
    padding: const EdgeInsets.only(right: 8),
    child: GestureDetector(
      onTap: () {
        textController.clear();
        preventQuickChange?.cancel();
        requireMoreWords('', 0).catchError((_) => false);
      },
      child: const Icon(CupertinoIcons.delete_left_fill),
    ),
  );
  var searchWords = <Vocabulary>[], requiredPage = 0;
  var searchFuture = Future.value(false);
  Timer? preventQuickChange;

  @override
  void dispose() {
    preventQuickChange?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hPadding = MediaQuery.sizeOf(context).width / 32;
    return PlatformScaffold(
      appBar: PlatformAppBar(
        leading: const SizedBox.shrink(),
        title: PlatformTextField(
          autofocus: true,
          hintText: 'find it',
          controller: textController,
          textInputAction: TextInputAction.search,
          onChanged: (text) {
            preventQuickChange?.cancel();
            preventQuickChange = Timer(
              Durations.medium4,
              () => requireMoreWords(text, 0).catchError((e) {
                setState(() {
                  searchFuture = Future.error(e);
                });
                return false;
              }),
            );
          },
          onSubmitted: (p0) {
            preventQuickChange?.cancel();
            setState(() {
              searchFuture = requireMoreWords(p0, 0);
            });
          },
          cupertino:
              (_, __) => CupertinoTextFieldData(
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.primary, width: 2),
                  borderRadius: BorderRadius.circular(kRadialReactionRadius),
                ),
                prefix: const SizedBox.square(dimension: 4),
                suffix: suffixIcon,
              ),
          material:
              (_, __) => MaterialTextFieldData(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(kRadialReactionRadius),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  prefix: const SizedBox.square(dimension: 4),
                  suffixIcon: suffixIcon,
                ),
              ),
        ),
        trailingActions: [
          PlatformTextButton(
            onPressed: Navigator.of(context).pop,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: const Text('Cancel'),
          ),
        ],
        cupertino:
            (_, _) => CupertinoNavigationBarData(
              backgroundColor: kCupertinoSheetColor.resolveFrom(context),
            ),
        material:
            (_, _) =>
                MaterialAppBarData(titleSpacing: 0, leadingWidth: hPadding),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: searchFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SpinKitFadingCircle(color: colorScheme.secondary),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  messageExceptions(snapshot.error),
                  style: TextStyle(
                    color: CupertinoColors.destructiveRed.resolveFrom(context),
                  ),
                ),
              );
            }
            return AnimatedSwitcher(
              duration: Durations.short3,
              transitionBuilder:
                  (child, animation) => CupertinoDialogTransition(
                    animation: animation,
                    scale: .9,
                    child: child,
                  ),
              child:
                  textController.text.isEmpty
                      ? fetchHistorySearch(colorScheme, textTheme, hPadding)
                      : searchResults(colorScheme, textTheme, hPadding),
            );
          },
        ),
      ),
    );
  }

  Widget vocabularyItemBuilder({
    required Vocabulary word,
    required BuildContext context,
    required void Function(Vocabulary word) onTap,
    Widget? leading,
    bool isTop = false,
    double? hPadding,
    ColorScheme? colorScheme,
    TextTheme? textTheme,
  }) {
    textTheme ??= Theme.of(context).textTheme;
    hPadding ??= MediaQuery.sizeOf(context).width / 32;
    colorScheme ??= Theme.of(context).colorScheme;
    final minInteractiveDimension =
        Platform.isIOS || Platform.isMacOS
            ? kMinInteractiveDimensionCupertino
            : kMinInteractiveDimension;
    return Container(
      height: minInteractiveDimension,
      margin: EdgeInsets.symmetric(horizontal: hPadding),
      decoration: BoxDecoration(
        border: Border(
          top:
              !isTop
                  ? BorderSide(
                    color: CupertinoColors.secondarySystemFill.resolveFrom(
                      context,
                    ),
                  )
                  : BorderSide.none,
        ),
      ),
      child: InkWell(
        onTap: () {
          onTap(word);
          Navigator.push(
            context,
            platformPageRoute(
              context: context,
              builder: (context) => VocabularyPage(word: word),
              settings: const RouteSettings(name: AppRoute.vocabulary),
            ),
          );
        },
        child: Row(
          spacing: hPadding.scale(.5)!,
          children: [
            if (leading != null)
              LimitedBox(maxHeight: minInteractiveDimension, child: leading),
            Text(word.word, style: textTheme.titleMedium),
            const SizedBox.shrink(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // print('$index row has max width ${constraints.maxWidth}');
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      LimitedBox(
                        maxWidth: constraints.maxWidth,
                        child: Text(
                          word.getSpeechAndTranslation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: colorScheme?.outline),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> requireMoreWords(String text, int page) async {
    final words = await searchWord(word: text, page: page);
    final hasMore = words.isNotEmpty;
    // print('text = $text, page = $page, words = ${words.length}');
    if (page == 0 || hasMore) {
      requiredPage = page;
    }
    if (page == 0) {
      searchWords = words;
    } else {
      searchWords.addAll(words);
    }
    //update data(searchWords) must setState every time
    if (hasMore || page == 0 && mounted) setState(() {});
    return hasMore;
  }

  Widget searchResults([
    ColorScheme? colorScheme,
    TextTheme? textTheme,
    double? hPadding,
  ]) {
    hPadding ??= MediaQuery.sizeOf(context).width / 32;
    textTheme ??= Theme.of(context).textTheme;
    if (searchWords.isEmpty) {
      return _SearchNotFound(typing: textController.text);
    }
    return LoadMoreListView.builder(
      itemCount: searchWords.length,
      itemBuilder: (context, index) {
        if (index >= searchWords.length) {
          return const SizedBox.shrink();
        }
        return vocabularyItemBuilder(
          word: searchWords[index],
          context: context,
          onTap:
              (word) => MyDB().insertWords(Stream.value(word)).then((_) {
                MyDB().insertSearchHistory(word.wordId);
              }),
          isTop: index == 0,
          hPadding: hPadding,
          colorScheme: colorScheme,
          textTheme: textTheme,
        );
      },
      bottomPadding: 25,
      indicator: DotDotDotIndicator(
        size: 16,
        color: colorScheme?.secondary,
        duration: Durations.long2,
      ),
      onLoadMore: (atTop) async {
        preventQuickChange?.cancel();
        final text = textController.text;
        return requireMoreWords(text, atTop ? 0 : requiredPage + 1);
      },
      onErrorDisplayText: messageExceptions,
    );
  }

  Widget fetchHistorySearch([
    ColorScheme? colorScheme,
    TextTheme? textTheme,
    double? hPadding,
  ]) {
    final prototype = Vocabulary.fromRawJson(
      r'{"word_id": 830, "word": "apple", "asset": "http://www.cia1099.cloudns.ch/dict/dictionary/img/thumb/apple.jpg", "definitions": [{"part_of_speech": "noun", "explanations": [{"explain": "a hard, round fruit with a smooth green, red or yellow skin", "subscript": "countable, uncountable", "examples": ["apple juice"]}], "inflection": "apple, apples", "phonetic_uk": "/\\u02c8\\u00e6p.\\u0259l/", "phonetic_us": "/\\u02c8\\u00e6p.\\u0259l/", "audio_uk": "https://www.cia1099.cloudns.ch/dict/dictionary/audio/apple__gb_1.mp3", "audio_us": "https://www.cia1099.cloudns.ch/dict/dictionary/audio/apple__us_1.mp3", "translate": "\\u82f9\\u679c"}]}',
    );
    final historyWords = MyDB().fetchHistorySearches();
    return ListView.builder(
      prototypeItem: vocabularyItemBuilder(
        word: prototype,
        context: context,
        onTap: (word) {},
      ),
      itemCount: historyWords.length,
      itemBuilder:
          (context, index) => vocabularyItemBuilder(
            word: historyWords[index],
            context: context,
            onTap: (word) => MyDB().updateHistory(word.wordId),
            isTop: index == 0,
            leading: Icon(
              CupertinoIcons.time,
              color: colorScheme?.outline,
              size: textTheme?.bodyMedium?.fontSize.scale(
                textTheme.bodyMedium?.height,
              ),
            ),
            colorScheme: colorScheme,
            textTheme: textTheme,
            hPadding: hPadding,
          ),
    );
  }
}

class _SearchNotFound extends StatelessWidget {
  const _SearchNotFound({
    // super.key,
    this.typing = '',
  });
  final String typing;

  @override
  Widget build(BuildContext context) {
    final cupertinoTextTheme = CupertinoTheme.of(context).textTheme;
    final hPadding = MediaQuery.sizeOf(context).width / 32;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      // color: Colors.red,
      margin: EdgeInsets.symmetric(
        horizontal: hPadding,
        vertical: hPadding * 2,
      ),
      child: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(sqrt2)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sorry no related results found',
              style: cupertinoTextTheme.navTitleTextStyle,
            ),
            Text(
              typing,
              style: cupertinoTextTheme.dateTimePickerTextStyle.apply(
                color: colorScheme.onTertiaryContainer,
              ),
            ),
            AlignParagraph(
              mark: Icon(CupertinoIcons.circle_fill, size: hPadding / 2),
              paragraph: Text(
                'Please verify the input text for any errors.',
                style: cupertinoTextTheme.textStyle,
              ),
              xInterval: hPadding / 2,
              paragraphStyle: textTheme.bodyMedium?.apply(heightFactor: sqrt2),
            ),
            AlignParagraph(
              mark: Icon(CupertinoIcons.circle_fill, size: hPadding / 2),
              paragraph: Text(
                'Please attempt a different search term.',
                style: cupertinoTextTheme.textStyle,
              ),
              xInterval: hPadding / 2,
              paragraphStyle: textTheme.bodyMedium?.apply(heightFactor: sqrt2),
            ),
            AlignParagraph(
              mark: Icon(CupertinoIcons.circle_fill, size: hPadding / 2),
              paragraph: Text(
                'Please consider a more common text.',
                style: cupertinoTextTheme.textStyle,
              ),
              xInterval: hPadding / 2,
              paragraphStyle: textTheme.bodyMedium?.apply(heightFactor: sqrt2),
            ),
          ],
        ),
      ),
    );
  }
}
