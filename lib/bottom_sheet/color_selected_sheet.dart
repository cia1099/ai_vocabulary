import 'dart:io';

import 'package:ai_vocabulary/main.dart';
import 'package:ai_vocabulary/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ColorSelectedSheet extends StatefulWidget {
  const ColorSelectedSheet({
    super.key,
  });

  @override
  State<ColorSelectedSheet> createState() => _ColorSelectedSheetState();
}

class _ColorSelectedSheetState extends State<ColorSelectedSheet> {
  int? colorSeed, colorImage;
  @override
  void initState() {
    super.initState();
    updateColorIndex();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.only(top: 16),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(kRadialReactionRadius)),
          color: CupertinoColors.systemBackground),
      width: double.maxFinite,
      height: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text('Color',
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              itemCount: ColorSeed.values.length,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, index) => GestureDetector(
                onTap: () {
                  MyApp.colorSelectedIndex.value = index;
                  setState(updateColorIndex);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 40,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorSeed.values[index].color,
                      border: Border.all(
                        color: colorSeed != index
                            ? CupertinoColors.inactiveGray
                            : colorScheme.onPrimary,
                      )),
                  child: colorSeed != index
                      ? null
                      : Icon(CupertinoIcons.checkmark_alt,
                          color: colorScheme.onPrimary),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text('Color Image',
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
          Container(
            height: 100,
            padding: const EdgeInsets.only(top: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  ColorImageProvider.values.length,
                  (index) => GestureDetector(
                    onTap: () {
                      MyApp.colorSelectedIndex.value =
                          index + ColorSeed.values.length;
                      setState(updateColorIndex);
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          foregroundDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: colorImage != index
                                    ? CupertinoColors.inactiveGray
                                    : colorScheme.primary,
                                width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              ColorImageProvider.values[index].url,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                final progress =
                                    loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!;
                                if (Platform.isIOS || Platform.isMacOS) {
                                  return CupertinoActivityIndicator
                                      .partiallyRevealed(progress: progress);
                                }
                                return CircularProgressIndicator(
                                    value: progress);
                              },
                            ),
                          ),
                        ),
                        if (colorImage == index)
                          Positioned(
                              top: 0,
                              right: 0,
                              child: Icon(
                                CupertinoIcons.check_mark_circled_solid,
                                color: colorScheme.primary,
                              ))
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void updateColorIndex() {
    final colorIndex = MyApp.colorSelectedIndex.value;
    if (colorIndex < ColorSeed.values.length) {
      colorSeed = colorIndex;
      colorImage = null;
    } else if (colorIndex - ColorSeed.values.length <
        ColorImageProvider.values.length) {
      colorSeed = null;
      colorImage = colorIndex - ColorSeed.values.length;
    }
  }
}
