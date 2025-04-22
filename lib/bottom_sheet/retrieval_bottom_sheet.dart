import 'dart:async';

import 'package:ai_vocabulary/api/dict_api.dart';
import 'package:ai_vocabulary/utils/handle_except.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../model/vocabulary.dart';
import '../pages/views/matching_word_view.dart';
import '../widgets/definition_tile.dart';
import '../widgets/example_paragraph.dart';

class RetrievalBottomSheet extends StatefulWidget {
  final String queryWord;
  const RetrievalBottomSheet({super.key, required this.queryWord});

  @override
  State<RetrievalBottomSheet> createState() => _RetrievalBottomSheetState();
}

class _RetrievalBottomSheetState extends State<RetrievalBottomSheet>
    with TickerProviderStateMixin {
  late var futureWords = fetchWords();
  TabController? tabController;

  Future<List<Vocabulary>> fetchWords() async {
    return await retrievalWord(widget.queryWord).then((words) {
      return words..sort(
        (a, b) =>
            a.differ(widget.queryWord).compareTo(b.differ(widget.queryWord)),
      );
    });
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hPadding = MediaQuery.of(context).size.width / 16;
    final screenHeight = MediaQuery.of(context).size.height;
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        if (notification.extent - notification.minExtent < 1e-3) {
          Navigator.maybePop(context); // close when reach minExtent
        }
        return true;
      },
      child: DraggableScrollableSheet(
        expand: false,
        snap: true,
        minChildSize: .12,
        maxChildSize: .9,
        snapSizes: const [.32, .9],
        initialChildSize: .32,
        builder:
            (context, scrollController) => PlatformWidgetBuilder(
              material: (_, child, ___) => child,
              cupertino:
                  (_, child, ___) => CupertinoPopupSurface(child: child!),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final sheetHeight = constraints.maxHeight;
                  final scale = ((sheetHeight - .32 * screenHeight) /
                          (.9 - .32) /
                          screenHeight)
                      .clamp(0.0, 1.0);
                  return Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        controller: scrollController,
                        physics: const ClampingScrollPhysics(),
                        child: Container(
                          height: 32,
                          padding: EdgeInsets.only(
                            top: 16,
                            right: hPadding / 2,
                            left: hPadding / 2,
                          ),
                          child: Stack(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(),
                                  const Icon(
                                    CupertinoIcons.chevron_up_chevron_down,
                                  ),
                                  GestureDetector(
                                    onTap: Navigator.of(context).pop,
                                    child: const Icon(
                                      CupertinoIcons.xmark_circle_fill,
                                    ),
                                  ),
                                ],
                              ),
                              FutureBuilder(
                                future: futureWords,
                                builder: (context, snapshot) {
                                  final words = snapshot.data;
                                  if (words == null || words.length < 2)
                                    return const SizedBox();

                                  tabController ??= TabController(
                                    length: words.length,
                                    vsync: this,
                                  );
                                  return TabPageSelector(
                                    controller: tabController,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: hPadding),
                          child: FutureBuilder(
                            future: futureWords,
                            builder: (context, snapshot) {
                              final words = snapshot.data;
                              if (snapshot.hasError) {
                                final error = snapshot.error;
                                if (error is TimeoutException) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Can't detect network or request has been timeout",
                                      ),
                                      PlatformTextButton(
                                        onPressed:
                                            () => setState(() {
                                              futureWords = fetchWords();
                                            }),
                                        child: const Text("Reload"),
                                      ),
                                    ],
                                  );
                                } else {
                                  return Center(
                                    child: Text(
                                      messageExceptions(error),
                                      style: TextStyle(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onErrorContainer,
                                      ),
                                    ),
                                  );
                                }
                              }
                              if (words == null)
                                return Center(
                                  child: PlatformCircularProgressIndicator(),
                                );

                              return PageView.builder(
                                itemCount: words.length,
                                onPageChanged:
                                    (value) => tabController?.animateTo(value),
                                itemBuilder: (context, index) {
                                  final word = words[index];
                                  return MatchingWordView(
                                    word: word,
                                    hPadding: hPadding,
                                    buildExamples:
                                        (_) => buildExamples(
                                          scale,
                                          word,
                                          hPadding,
                                        ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
      ),
    );
  }

  Widget buildExamples(double scale, Vocabulary word, double hPadding) {
    return SizedBox(
      height: scale < .05 ? 0 : null,
      child: Transform.scale(
        alignment: Alignment.topCenter,
        scaleY: scale,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Offstage(
              offstage: word.getExamples.isEmpty,
              child: Container(
                margin: EdgeInsets.only(bottom: hPadding / 8),
                child: const Text("Examples:"),
              ),
            ),
            for (final definition in word.definitions)
              if (definition.hasExample()) ...[
                PartOfSpeechTitle(definition: definition, word: word.word),
                const Divider(height: 4),
                for (int i = 0; i < definition.explanations.length; i++)
                  ...definition.explanations[i].examples.map(
                    (example) => ExampleParagraph(
                      mark: Text(
                        '${i + 1}.',
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      example: example,
                      patterns: word.getMatchingPatterns,
                    ),
                  ),
              ],
          ],
        ),
      ),
    );
  }
}
