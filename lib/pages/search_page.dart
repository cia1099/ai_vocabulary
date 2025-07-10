import 'dart:async';
import 'dart:math';

import 'package:ai_vocabulary/app_route.dart';
import 'package:ai_vocabulary/app_settings.dart';
import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/effects/dot3indicator.dart';
import 'package:ai_vocabulary/mock_data.dart';
import 'package:ai_vocabulary/utils/enums.dart';
import 'package:ai_vocabulary/utils/formatter.dart';
import 'package:ai_vocabulary/utils/function.dart';
import 'package:ai_vocabulary/utils/handle_except.dart';
import 'package:ai_vocabulary/utils/load_more_listview.dart';
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:ai_vocabulary/widgets/align_paragraph.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart' show SpinKitFadingCircle;

import '../api/dict_api.dart';
import '../effects/transient.dart';
import '../model/vocabulary.dart';
import 'vocabulary_page.dart';

part 'search_page2.dart';

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
        setState(() {
          searchFuture = requireMoreWords('', 0);
        });
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
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hPadding = MediaQuery.sizeOf(context).width / 32;
    final locate = AppSettings.of(context).translator;
    return PlatformScaffold(
      appBar: PlatformAppBar(
        leading: const SizedBox.shrink(),
        title: PlatformTextField(
          autofocus: true,
          hintText: locate != TranslateLocate.none
              ? 'support ${locate.native} input'
              : 'find it',
          controller: textController,
          textInputAction: TextInputAction.search,
          inputFormatters: [EnglishLowerCaseConstraintFormatter()],
          onChanged: (text) {
            preventQuickChange?.cancel();
            preventQuickChange = Timer(Durations.medium4, () {
              setState(() {
                searchFuture = requireMoreWords(text, 0);
              });
            });
          },
          onSubmitted: (p0) {
            if (searchWords.isNotEmpty) return;
            preventQuickChange?.cancel();
            setState(() {
              searchFuture = requireMoreWords(p0, 0);
            });
          },
          cupertino: (_, __) => CupertinoTextFieldData(
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.primary, width: 2),
              borderRadius: BorderRadius.circular(kRadialReactionRadius),
            ),
            prefix: const SizedBox.square(dimension: 4),
            suffix: suffixIcon,
          ),
          material: (_, __) => MaterialTextFieldData(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kRadialReactionRadius),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              prefix: const SizedBox.square(dimension: 4),
              suffixIcon: suffixIcon,
            ),
          ),
        ),
        trailingActions: [
          PlatformTextButton(
            onPressed: Navigator.of(context).maybePop,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: const Text('Cancel'),
          ),
        ],
        cupertino: (_, _) => CupertinoNavigationBarData(
          backgroundColor: kCupertinoSheetColor.resolveFrom(context),
        ),
        material: (_, _) =>
            MaterialAppBarData(titleSpacing: 0, leadingWidth: hPadding),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: searchFuture,
          builder: (context, snapshot) {
            final isWaiting =
                snapshot.connectionState == ConnectionState.waiting;
            if (isWaiting && searchWords.isEmpty) {
              return Center(
                child: SpinKitFadingCircle(color: colorScheme.secondary),
              );
            }
            if (snapshot.hasError) {
              return Stack(
                children: [
                  Center(
                    child: Text(
                      messageExceptions(snapshot.error),
                      style: TextStyle(
                        color: CupertinoColors.destructiveRed.resolveFrom(
                          context,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: _WaitingCurtain(
                      isWaiting: isWaiting,
                      duration: Durations.long4,
                    ),
                  ),
                ],
              );
            }

            return Stack(
              children: [
                AnimatedSwitcher(
                  duration: Durations.short3,
                  transitionBuilder: (child, animation) =>
                      CupertinoDialogTransition(
                        animation: animation,
                        scale: .9,
                        child: child,
                      ),
                  child: textController.text.isEmpty
                      ? fetchHistorySearch(colorScheme, textTheme, hPadding)
                      : searchResults(
                          snapshot.data!,
                          colorScheme,
                          textTheme,
                          hPadding,
                        ),
                ),
                Positioned.fill(
                  child: _WaitingCurtain(
                    isWaiting: isWaiting,
                    duration: Durations.short3 * 2,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget vocabularyItemBuilder({
    required Vocabulary word,
    required BuildContext context,
    required Future<void> Function(Vocabulary word) onTap,
    Widget? leading,
    bool isTop = false,
    double? hPadding,
    ColorScheme? colorScheme,
    TextTheme? textTheme,
  }) {
    textTheme ??= Theme.of(context).textTheme;
    hPadding ??= MediaQuery.sizeOf(context).width / 32;
    colorScheme ??= Theme.of(context).colorScheme;
    final minInteractiveDimension = isCupertino(context)
        ? kMinInteractiveDimensionCupertino
        : kMinInteractiveDimension;
    return Container(
      height: minInteractiveDimension,
      margin: EdgeInsets.symmetric(horizontal: hPadding),
      decoration: BoxDecoration(
        border: Border(
          top: !isTop
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
          Navigator.push(
            context,
            platformPageRoute(
              context: context,
              builder: (context) => VocabularyPage(word: word),
              settings: const RouteSettings(name: AppRoute.vocabulary),
            ),
          );
          onTap(word);
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
    if (text.isEmpty) {
      requiredPage = 0;
      searchWords.clear();
      return false;
    }
    final locate = AppSettings.of(context).translator;
    final words = await searchWord(word: text, locate: locate, page: page);
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

  Widget searchResults(
    bool hasResults, [
    ColorScheme? colorScheme,
    TextTheme? textTheme,
    double? hPadding,
  ]) {
    hPadding ??= MediaQuery.sizeOf(context).width / 32;
    textTheme ??= Theme.of(context).textTheme;
    if (!hasResults) {
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
          onTap: (word) => MyDB().insertWords(Stream.value(word)).then((_) {
            MyDB().upsertSearchHistory(word.wordId);
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
    final prototype = Vocabulary.fromRawJson(apple_json);
    final historyWords = MyDB().fetchHistorySearches();
    return ListView.builder(
      prototypeItem: vocabularyItemBuilder(
        word: prototype,
        context: context,
        onTap: (word) async {},
      ),
      itemCount: historyWords.length,
      itemBuilder: (context, index) => vocabularyItemBuilder(
        word: historyWords[index],
        context: context,
        onTap: (word) async => MyDB().upsertSearchHistory(word.wordId),
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
