import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../bottom_sheet/color_selected_sheet.dart';
import '../effects/slide_appear.dart';
import 'vocabulary_page.dart';

class ColorSelectPage extends StatelessWidget {
  const ColorSelectPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const appleJson = '''
{"word_id": 830, "word": "apple", "asset": "https://www.cia1099.cloudns.ch/dict/dictionary/img/thumb/apple.jpg", "definitions": [{"part_of_speech": "noun", "explanations": [{"explain": "a hard, round fruit with a smooth green, red or yellow skin", "subscript": "countable, uncountable", "examples": ["apple juice"]}], "inflection": "apple, apples", "phonetic_uk": "/\\u02c8\\u00e6p.\\u0259l/", "phonetic_us": "/\\u02c8\\u00e6p.\\u0259l/", "audio_uk": "https://www.cia1099.cloudns.ch/dict/dictionary/audio/apple__gb_1.mp3", "audio_us": "https://www.cia1099.cloudns.ch/dict/dictionary/audio/apple__us_1.mp3", "translate": "\\u82f9\\u679c"}]}
''';
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
                        word: Vocabulary.fromRawJson(appleJson),
                      ),
                    ),
                  )),
            )),
        const Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: .25,
            child:
                SlideAppear(isHorizontal: false, child: ColorSelectedSheet()),
          ),
        )
      ],
    );
  }
}
