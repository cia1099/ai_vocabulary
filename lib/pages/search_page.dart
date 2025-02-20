import 'dart:async';

import 'package:ai_vocabulary/effects/dot3indicator.dart';
import 'package:ai_vocabulary/mock_data.dart';
import 'package:ai_vocabulary/utils/handle_except.dart';
import 'package:ai_vocabulary/utils/load_more_listview.dart';
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../api/dict_api.dart';
import '../model/vocabulary.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
  });

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
        backgroundColor: kCupertinoSheetColor.resolveFrom(context),
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
                    }));
          },
          onSubmitted: (p0) {
            preventQuickChange?.cancel();
            setState(() {
              searchFuture = requireMoreWords(p0, 0);
            });
          },
          cupertino: (_, __) => CupertinoTextFieldData(
            decoration: BoxDecoration(
                border: Border.all(color: colorScheme.primary, width: 2),
                borderRadius: BorderRadius.circular(kRadialReactionRadius)),
            prefix: const SizedBox.square(dimension: 4),
            suffix: suffixIcon,
          ),
          material: (_, __) => MaterialTextFieldData(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(kRadialReactionRadius),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2)),
              prefix: const SizedBox.square(dimension: 4),
              suffixIcon: suffixIcon,
            ),
          ),
        ),
        trailingActions: [
          PlatformTextButton(
              onPressed: Navigator.of(context).pop,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: const Text('Cancel'))
        ],
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
                    color: CupertinoColors.destructiveRed.resolveFrom(context)),
              ));
            }
            return AnimatedSwitcher(
              duration: Durations.short4,
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: textController.text.isEmpty
                  ? fetchHistorySearch(colorScheme, textTheme, hPadding)
                  : LoadMoreListView.builder(
                      itemCount: searchWords.length,
                      itemBuilder: (context, index) {
                        if (index >= searchWords.length) {
                          return const SizedBox.shrink();
                        }
                        return vocabularyItemBuilder(
                          word: searchWords[index],
                          context: context,
                          isTop: index == 0,
                          hPadding: hPadding,
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        );
                      },
                      bottomPadding: 25,
                      indicator: DotDotDotIndicator(
                          size: 16,
                          color: colorScheme.secondary,
                          duration: Durations.long2),
                      onLoadMore: (atTop) async {
                        preventQuickChange?.cancel();
                        final text = textController.text;
                        return requireMoreWords(
                            text, atTop ? 0 : requiredPage + 1);
                      },
                      onErrorDisplayText: messageExceptions,
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget vocabularyItemBuilder({
    required Vocabulary word,
    required BuildContext context,
    Widget? leading,
    bool isTop = false,
    double? hPadding,
    ColorScheme? colorScheme,
    TextTheme? textTheme,
  }) {
    textTheme ??= Theme.of(context).textTheme;
    hPadding ??= MediaQuery.sizeOf(context).width / 32;
    colorScheme ??= Theme.of(context).colorScheme;
    return Container(
      height: 40,
      margin: EdgeInsets.symmetric(horizontal: hPadding),
      decoration: BoxDecoration(
          border: Border(
              top: !isTop
                  ? BorderSide(
                      color: CupertinoColors.secondarySystemFill
                          .resolveFrom(context))
                  : BorderSide.none)),
      child: Row(
        spacing: hPadding.scale(.5)!,
        children: [
          if (leading != null) LimitedBox(maxHeight: 40, child: leading),
          Text(word.word, style: textTheme.titleSmall),
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

  Widget fetchHistorySearch(
      [ColorScheme? colorScheme, TextTheme? textTheme, double? hPadding]) {
    final word = Vocabulary.fromRawJson(apple_json);
    return ListView.builder(
      prototypeItem: vocabularyItemBuilder(word: word, context: context),
      itemBuilder: (context, index) => vocabularyItemBuilder(
        word: word,
        context: context,
        isTop: index == 0,
        leading: Icon(CupertinoIcons.time,
            color: colorScheme?.outline,
            size: textTheme?.titleSmall?.fontSize
                .scale(textTheme.titleSmall?.height)
                .scale(.85)),
        colorScheme: colorScheme,
        textTheme: textTheme,
        hPadding: hPadding,
      ),
    );
  }
}
