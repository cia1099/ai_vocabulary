import 'dart:async';

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
        requireMoreWords('', 0);
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
    final hPadding = MediaQuery.sizeOf(context).width / 32;
    return PlatformScaffold(
      appBar: PlatformAppBar(
        leading: const SizedBox.shrink(),
        backgroundColor: kCupertinoSheetColor.resolveFrom(context),
        title: Row(
          children: [
            Expanded(
              child: PlatformTextField(
                autofocus: true,
                hintText: 'find it',
                controller: textController,
                textInputAction: TextInputAction.search,
                onChanged: (text) {
                  preventQuickChange?.cancel();
                  preventQuickChange =
                      Timer(Durations.medium4, () => requireMoreWords(text, 0));
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
                      borderRadius:
                          BorderRadius.circular(kRadialReactionRadius)),
                  prefix: const SizedBox.square(dimension: 4),
                  suffix: suffixIcon,
                ),
                material: (_, __) => MaterialTextFieldData(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(kRadialReactionRadius),
                        borderSide:
                            BorderSide(color: colorScheme.primary, width: 2)),
                    prefix: const SizedBox.square(dimension: 4),
                    suffixIcon: suffixIcon,
                  ),
                ),
              ),
            ),
            PlatformTextButton(
                onPressed: Navigator.of(context).pop,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: const Text('Cancel'))
          ],
        ),
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
            return LoadMoreListView.builder(
              itemCount: searchWords.length,
              itemBuilder: (context, index) =>
                  itemBuilder(index, context, hPadding, colorScheme),
              onLoadMore: (atTop) async {
                preventQuickChange?.cancel();
                final text = textController.text;
                return requireMoreWords(text, atTop ? 0 : requiredPage + 1);
              },
            );
          },
        ),
      ),
    );
  }

  Widget itemBuilder(int index, BuildContext context, double hPadding,
      ColorScheme colorScheme) {
    if (index > searchWords.length) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    final word = searchWords[index];
    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: hPadding),
      decoration: BoxDecoration(
          border: Border(
              top: index > 0
                  ? BorderSide(
                      color: CupertinoColors.secondarySystemFill
                          .resolveFrom(context))
                  : BorderSide.none)),
      child: Row(
        spacing: hPadding,
        children: [
          Text(word.word, style: textTheme.titleSmall),
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
                        style: TextStyle(color: colorScheme.outline),
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
}
