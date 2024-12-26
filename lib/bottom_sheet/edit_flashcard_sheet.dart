import 'package:ai_vocabulary/model/collection_mark.dart';
import 'package:ai_vocabulary/widgets/flashcard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../theme.dart';

class EditFlashcardSheet extends StatefulWidget {
  const EditFlashcardSheet({
    super.key,
  });

  @override
  State<EditFlashcardSheet> createState() => _EditFlashcardSheetState();
}

class _EditFlashcardSheetState extends State<EditFlashcardSheet> {
  int? color, icon;
  final cardState = GlobalKey<State>();
  @override
  Widget build(BuildContext context) {
    final hPadding = MediaQuery.of(context).size.width / 32;
    final colorScheme = Theme.of(context).colorScheme;
    color = colorScheme.surface.value;
    return Scaffold(
      appBar: const CupertinoNavigationBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: hPadding),
        child: SafeArea(
          top: false,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                  pinned: true,
                  floating: true,
                  snap: true,
                  expandedHeight: 200 + kTextTabBarHeight,
                  flexibleSpace: Column(
                    children: [
                      Container(
                          height: kToolbarHeight,
                          color: colorScheme.surface.withOpacity(.85),
                          child: Stack(
                            children: [
                              Center(
                                  child: Text(
                                'Collection Mark',
                                style: Theme.of(context).textTheme.titleMedium,
                              )),
                              Align(
                                alignment: const Alignment(1, 0),
                                child: PlatformTextButton(
                                  padding: EdgeInsets.zero,
                                  material: (_, __) => MaterialTextButtonData(
                                    style: TextButton.styleFrom(
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                  child: const Text('Done'),
                                ),
                              ),
                            ],
                          )),
                      Expanded(
                        child: SizedBox(
                          width: double.maxFinite,
                          child: Card.filled(
                            margin: EdgeInsets.zero,
                            child: FractionallySizedBox(
                              widthFactor: 200 / hPadding / 32,
                              child: StatefulBuilder(
                                key: cardState,
                                builder: (context, setState) {
                                  final mark = CollectionMark(
                                      icon: icon,
                                      color: color,
                                      name: 'test\ntest\ntest',
                                      index: 0);
                                  return Flashcard(mark: mark);
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
              SliverToBoxAdapter(
                child: Card.filled(
                    margin: EdgeInsets.only(top: hPadding),
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: List.generate(
                            ColorSeed.values.length,
                            (index) => GestureDetector(
                              onTap: () {
                                cardState.currentState?.setState(() {
                                  color = ColorSeed.values[index].color.value;
                                });
                              },
                              child: CircleAvatar(
                                backgroundColor: ColorSeed.values[index].color,
                                radius: 36 / 2,
                              ),
                            ),
                          ),
                        ))),
              ),
              SliverToBoxAdapter(
                child: Card.filled(
                    margin: EdgeInsets.symmetric(vertical: hPadding),
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: List.generate(
                            0xf8ae - 0xf4d4 + 1,
                            (index) => GestureDetector(
                              onTap: () {
                                cardState.currentState?.setState(() {
                                  icon = index + 0xf4d4;
                                });
                              },
                              child: Icon(
                                IconData(index + 0xf4d4,
                                    fontFamily: 'CupertinoIcons',
                                    fontPackage: 'cupertino_icons'),
                                size: 36,
                              ),
                            ),
                          ),
                        ))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
