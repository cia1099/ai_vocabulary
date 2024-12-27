import 'package:ai_vocabulary/model/collection_mark.dart';
import 'package:ai_vocabulary/widgets/flashcard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../theme.dart';

class EditFlashcardSheet extends StatefulWidget {
  final CollectionMark mark;
  const EditFlashcardSheet({
    super.key,
    required this.mark,
  });

  @override
  State<EditFlashcardSheet> createState() => _EditFlashcardSheetState();
}

class _EditFlashcardSheetState extends State<EditFlashcardSheet> {
  late int? color = widget.mark.color, icon = widget.mark.icon;
  final cardState = GlobalKey<State>();
  @override
  Widget build(BuildContext context) {
    final hPadding = MediaQuery.of(context).size.width / 32;
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: CupertinoPopupSurface(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
                pinned: true,
                floating: true,
                snap: true,
                expandedHeight: 200 + kToolbarHeight,
                foregroundColor: colorScheme.primary,
                backgroundColor: Colors.transparent,
                flexibleSpace: Column(
                  children: [
                    Container(
                        height: kToolbarHeight,
                        decoration: BoxDecoration(
                            color:
                                colorScheme.onInverseSurface.withOpacity(.95),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(kRadialReactionRadius),
                            )),
                        child: Stack(
                          children: [
                            Center(
                                child: Text(
                              'Collection Mark',
                              style: Theme.of(context).textTheme.titleMedium,
                            )),
                            Align(
                              alignment: const Alignment(.9, 0),
                              child: PlatformTextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(CollectionMark(
                                      name: widget.mark.name,
                                      color: color,
                                      icon: icon,
                                      index: widget.mark.index));
                                },
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
                      child: Container(
                        width: double.maxFinite,
                        margin: EdgeInsets.symmetric(
                            horizontal: hPadding, vertical: hPadding / 2),
                        child: CupertinoPopupSurface(
                          child: FractionallySizedBox(
                            heightFactor: 1,
                            widthFactor: 200 / hPadding / 32,
                            child: StatefulBuilder(
                              key: cardState,
                              builder: (context, setState) {
                                final mark = CollectionMark(
                                    icon: icon,
                                    color: color,
                                    name: widget.mark.name,
                                    index: widget.mark.index);
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
              child: Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: hPadding, vertical: hPadding / 2),
                  child: CupertinoPopupSurface(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: List.generate(
                          ColorSeed.values.length + 1,
                          (index) => GestureDetector(
                            onTap: () {
                              cardState.currentState?.setState(() {
                                color = index == 0
                                    ? null
                                    : ColorSeed.values[index - 1].color.value;
                              });
                            },
                            child: CircleAvatar(
                                backgroundColor: index == 0
                                    ? null
                                    : ColorSeed.values[index - 1].color,
                                radius: 36 / 2,
                                backgroundImage: index == 0
                                    ? const AssetImage(
                                        'assets/do-disturb-alt.png')
                                    : null),
                          ),
                        ),
                      ),
                    ),
                  )),
            ),
            SliverToBoxAdapter(
              child: Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: hPadding, vertical: hPadding / 2),
                  child: CupertinoPopupSurface(
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: List.generate(
                            0xf8ae - 0xf4d4 + 1 + 1,
                            (index) => GestureDetector(
                              onTap: () {
                                cardState.currentState?.setState(() {
                                  icon = index == 0 ? null : index - 1 + 0xf4d4;
                                });
                              },
                              child: Icon(
                                index == 0
                                    ? Icons.abc
                                    : IconData(index - 1 + 0xf4d4,
                                        fontFamily: 'CupertinoIcons',
                                        fontPackage: 'cupertino_icons'),
                                size: 36,
                              ),
                            ),
                          ),
                        )),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
