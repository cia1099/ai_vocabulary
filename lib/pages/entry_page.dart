import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class EntryPage extends StatelessWidget {
  const EntryPage({super.key, required this.word});
  final Vocabulary word;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final hPadding = screenWidth / 16;
    return PlatformScaffold(
      appBar: PlatformAppBar(
        material: (_, __) => MaterialAppBarData(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPadding),
          child: Column(
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6.withOpacity(.8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Review today"),
                        Text("0/120", style: textTheme.headlineSmall),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("New today"),
                        Text("0/40", style: textTheme.headlineSmall),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Learning today"),
                        Text("1min", style: textTheme.headlineSmall),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                // color: Colors.green,
                height: 250,
                width: double.maxFinite,
                margin: EdgeInsets.only(top: 16),
                child: Column(
                  children: [
                    Container(
                      height: 250 - 80,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            padding: EdgeInsets.all(4),
                            child: Text("Learned 3 month ago"),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: CupertinoColors.black)),
                          ),
                          Text(word.word, style: textTheme.displayMedium),
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(text: '\t' * 4),
                              TextSpan(
                                  text: word.definitions
                                      .map((d) => d.phoneticUs ?? '')
                                      .reduce((p1, p2) =>
                                          p1.length < p2.length ? p1 : p2)),
                              TextSpan(text: '\t' * 4),
                              WidgetSpan(
                                  child: GestureDetector(
                                      onTap: () {},
                                      child: Icon(CupertinoIcons.volume_up)))
                            ], style: textTheme.titleLarge),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        height: 80,
                        // color: colorScheme.secondaryContainer,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Wrap(
                          spacing: 8,
                          children: word.getInflection
                              .map((e) => Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    decoration: BoxDecoration(
                                        color: colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(
                                            textTheme.bodyMedium!.fontSize!)),
                                    child: Text(e,
                                        style: TextStyle(
                                            color: colorScheme
                                                .onPrimaryContainer)),
                                  ))
                              .toList(),
                        )),
                  ],
                ),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  // foregroundColor: colorScheme.onSurfaceVariant,
                  backgroundColor: colorScheme.surfaceContainer,
                ),
                onPressed: () {},
                icon: Icon(CupertinoIcons.trash,
                    color: colorScheme.onSurfaceVariant),
                label: Text('Mark as too easy',
                    style: TextStyle(color: colorScheme.onSurfaceVariant)),
              ),
              Expanded(child: SizedBox()),
              Wrap(
                spacing: screenWidth / 12,
                children: [
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                        fixedSize: Size.square(screenWidth / 3),
                        backgroundColor:
                            CupertinoColors.systemGrey6.withOpacity(.8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                    child: Text(
                      "Unknown",
                      style:
                          textTheme.titleLarge!.apply(color: colorScheme.error),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                        fixedSize: Size.square(screenWidth / 3),
                        backgroundColor:
                            CupertinoColors.systemGrey6.withOpacity(.8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                    child: Text(
                      "Recognize",
                      style: textTheme.titleLarge!
                          .apply(color: colorScheme.primary),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
