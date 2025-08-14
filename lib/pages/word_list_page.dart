import 'package:ai_vocabulary/app_route.dart';
import 'package:ai_vocabulary/app_settings.dart';
import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:ai_vocabulary/pages/vocabulary_page.dart';
import 'package:ai_vocabulary/utils/function.dart';
import 'package:ai_vocabulary/utils/phonetic.dart' show playPhonetic;
import 'package:ai_vocabulary/widgets/entry_actions.dart';
import 'package:ai_vocabulary/widgets/translate_request.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class WordListPage extends StatelessWidget {
  const WordListPage({
    super.key,
    required this.words,
    this.nextTap,
    required this.title,
  });

  final List<Vocabulary> words;
  final VoidCallback? nextTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final reachTarget = ModalRoute.of(context)?.settings.arguments as bool?;
    return PlatformScaffold(
      appBar: PlatformAppBar(
        leading: nextTap == null
            ? null
            : CupertinoNavigationBarBackButton(onPressed: nextTap),
        title: Text(title),
        backgroundColor: colorScheme.primaryContainer,
        cupertino: (_, __) =>
            CupertinoNavigationBarData(trailing: const EntryActions()),
        material: (_, __) => MaterialAppBarData(
          backgroundColor: colorScheme.inversePrimary,
          actions: [const EntryActions()],
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverList.builder(
                  // itemExtentBuilder: (index, dimensions) {
                  //   if (words.length < 10 && words.isNotEmpty) {
                  //     return dimensions.viewportMainAxisExtent / kRemindLength;
                  //   }
                  //   return dimensions.viewportMainAxisExtent / 10;
                  // },
                  itemCount: words.length + 1, //+ (words.length < 10 ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= words.length) {
                      return const SizedBox(height: kBottomNavigationBarHeight);
                    }
                    final word = words[index];
                    return itemBuilder(context, index, word);
                  },
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Offstage(
                offstage: nextTap == null,
                child: PlatformElevatedButton(
                  onPressed: nextTap,
                  child: Text(reachTarget != true ? 'Next set' : 'Complete'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget itemBuilder(BuildContext context, int index, Vocabulary word) {
    final hPadding = MediaQuery.sizeOf(context).width / 32;
    final textScaler = MediaQuery.textScalerOf(context);
    final dividerTheme = Theme.of(context).dividerTheme;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final accent = AppSettings.of(context).accent;
    final phonetics = word.getPhonetics(accent);
    return Column(
      children: [
        Offstage(
          offstage: index == 0,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPadding / 2),
            child: DottedLine(
              dashColor: dividerTheme.color ?? Theme.of(context).dividerColor,
            ),
          ),
        ),
        PlatformListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: word.word,
                        // style: textTheme.headlineSmall,
                        style: textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)
                            .apply(fontSizeFactor: 1.414),
                      ),
                      TextSpan(text: '\t' * 2),
                      TextSpan(
                        text: phonetics.firstOrNull?.phonetic,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium,
                ),
              ),
              GestureDetector(
                onTap: playPhonetic(null, word: word.word, gTTs: accent.gTTS),
                child: Icon(
                  CupertinoIcons.volume_up,
                  size: textScaler.scale(
                    textTheme.titleMedium?.fontSize?.scale(
                          textTheme.titleMedium?.height,
                        ) ??
                        1.0,
                  ),
                ),
              ),
            ],
          ),
          subtitle: TranslateRequest(
            request: word.requireSpeechAndTranslation,
            initialData: word.getSpeechAndTranslation,
            maxLines: words.length < 10 ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyLarge,
          ),
          onTap: () => Navigator.of(context).push(
            platformPageRoute(
              context: context,
              builder: (context) => VocabularyPage(word: word),
              settings: const RouteSettings(name: AppRoute.vocabulary),
            ),
          ),
        ),
      ],
    );
  }
}
