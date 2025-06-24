import 'package:flutter/material.dart';

import '../bottom_sheet/color_selected_sheet.dart';
import '../effects/slide_appear.dart';
import '../model/vocabulary.dart';
import '../utils/shortcut.dart' show kAppleJson;
import 'vocabulary_page.dart';

class ColorSelectPage extends StatelessWidget {
  const ColorSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: const Alignment(0, -.45),
          child: FractionallySizedBox(
            widthFactor: .75,
            heightFactor: .6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(kRadialReactionRadius),
              child: AbsorbPointer(
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  removeBottom: true,
                  child: VocabularyPage(
                    word: Vocabulary.fromRawJson(kAppleJson),
                  ),
                ),
              ),
            ),
          ),
        ),
        const Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: .25,
            child: SlideAppear(
              isHorizontal: false,
              child: ColorSelectedSheet(),
            ),
          ),
        ),
      ],
    );
  }
}
