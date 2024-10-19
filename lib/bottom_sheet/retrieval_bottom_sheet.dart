import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../mock_data.dart';
import '../widgets/align_paragraph.dart';

class RetrievalBottomSheet extends StatefulWidget {
  const RetrievalBottomSheet({
    super.key,
  });

  @override
  State<RetrievalBottomSheet> createState() => _RetrievalBottomSheetState();
}

class _RetrievalBottomSheetState extends State<RetrievalBottomSheet> {
  late final futureWords = Future.delayed(
    Duration(milliseconds: 500),
    () => record,
  );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final hPadding = MediaQuery.of(context).size.width / 16;
    return DraggableScrollableSheet(
      expand: false,
      snap: true,
      minChildSize: .1,
      maxChildSize: .95,
      snapSizes: const [.32, .9],
      initialChildSize: .32,
      builder: (context, scrollController) => PlatformWidgetBuilder(
        material: (_, child, ___) => child,
        cupertino: (_, child, ___) => Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16)),
            child: child),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              controller: scrollController,
              physics: const ClampingScrollPhysics(),
              child: Container(
                height: 32,
                padding: EdgeInsets.only(
                    top: 16, right: hPadding / 2, left: hPadding / 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(),
                    Icon(CupertinoIcons.chevron_up_chevron_down),
                    GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(CupertinoIcons.xmark_circle_fill)),
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
                    if (words == null)
                      return Center(child: PlatformCircularProgressIndicator());
                    final inflections = words.definitions
                        .map((d) => (d.inflection ?? '').split(', '))
                        .reduce((d1, d2) => d1 + d2)
                        .toSet();
                    return SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(words.word,
                                  style: textTheme.titleLarge!
                                      .copyWith(fontWeight: FontWeight.bold)),
                              Wrap(
                                spacing: hPadding / 4,
                                children: inflections
                                    .map((e) => Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2, horizontal: 4),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: colorScheme.secondary),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      textTheme.labelMedium!
                                                          .fontSize!)),
                                          child: Text(e,
                                              style: textTheme.labelMedium!
                                                  .apply(
                                                      color: colorScheme
                                                          .secondary)),
                                        ))
                                    .toList(),
                              ),
                              Wrap(
                                spacing: hPadding,
                                children: [
                                  Text("translation"),
                                  Text("explanation"),
                                ],
                              ),
                              SizedBox(height: hPadding / 2),
                              for (final definition in words.definitions)
                                if (definition.translate != null)
                                  AlignParagraph(
                                    markWidget: Text(
                                      speechShortcut[definition.partOfSpeech] ??
                                          '',
                                      style: textTheme.titleMedium!.copyWith(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    paragraph: Text(definition.translate!),
                                    xInterval: hPadding / 4,
                                  ),
                              for (final definition in words.definitions)
                                AlignParagraph(
                                  markWidget: Text(
                                    speechShortcut[definition.partOfSpeech] ??
                                        '',
                                    style: textTheme.titleMedium!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  paragraph: Text(definition.explanations
                                      .map((e) => e.explain)
                                      .reduce((e1, e2) =>
                                          e1.length < e2.length ? e1 : e2)),
                                  xInterval: hPadding / 4,
                                ),
                            ]));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
