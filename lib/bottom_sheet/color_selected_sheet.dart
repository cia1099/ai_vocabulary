import 'package:ai_vocabulary/effects/transient.dart';
import 'package:ai_vocabulary/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../app_settings.dart';

class ColorSelectedSheet extends StatefulWidget {
  const ColorSelectedSheet({super.key});

  @override
  State<ColorSelectedSheet> createState() => _ColorSelectedSheetState();
}

class _ColorSelectedSheetState extends State<ColorSelectedSheet> {
  int? colorSeed, colorImage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateColorIndex();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;
        return CupertinoPopupSurface(
          child: Container(
            padding: EdgeInsets.only(top: maxHeight * 16 / 220),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(kRadialReactionRadius),
              ),
              // color: CupertinoDynamicColor.resolve(
              //   kCupertinoSheetColor,
              //   context,
              // ),
            ),
            width: double.maxFinite,
            height: maxHeight, //220,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Color',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textScaler: TextScaler.noScaling,
                  ),
                ),
                SizedBox(
                  height: maxHeight * 50 / 220,
                  child: ListView.builder(
                    itemCount: ColorSeed.values.length,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () {
                        AppSettings.of(context).colorIndex = index;
                        setState(updateColorIndex);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: maxHeight * 40 / 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorSeed.values[index].color,
                          border: Border.all(
                            color: colorSeed != index
                                ? CupertinoColors.inactiveGray.resolveFrom(
                                    context,
                                  )
                                : colorScheme.onPrimary,
                          ),
                        ),
                        child: colorSeed != index
                            ? null
                            : Icon(
                                CupertinoIcons.checkmark_alt,
                                color: colorScheme.onPrimary,
                              ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    'Color Image',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textScaler: TextScaler.noScaling,
                  ),
                ),
                Container(
                  height: maxHeight * 100 / 220,
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
                            AppSettings.of(context).colorIndex =
                                index + ColorSeed.values.length;
                            setState(updateColorIndex);
                          },
                          child: Stack(
                            children: [
                              Container(
                                width: maxHeight * 64 / 220,
                                height: maxHeight * 64 / 220,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                foregroundDecoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: colorImage != index
                                        ? CupertinoColors.inactiveGray
                                              .resolveFrom(context)
                                        : colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    ColorImageProvider.values[index].url,
                                    loadingBuilder: loadingBuilder,
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
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void updateColorIndex() {
    final colorIndex = AppSettings.of(context).colorIndex;
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
