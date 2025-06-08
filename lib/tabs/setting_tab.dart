import 'dart:math' show pi;

import 'package:ai_vocabulary/api/dict_api.dart';
import 'package:ai_vocabulary/app_route.dart';
import 'package:ai_vocabulary/firebase/authorization.dart' show signOutFirebase;
import 'package:ai_vocabulary/pages/payment_page.dart';
import 'package:ai_vocabulary/pages/punch_out_page.dart';
import 'package:ai_vocabulary/provider/user_provider.dart';
import 'package:ai_vocabulary/utils/function.dart';
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:ai_vocabulary/widgets/action_button.dart';
import 'package:ai_vocabulary/widgets/segment_explanation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:vector_math/vector_math.dart' show Matrix2;

import '../app_settings.dart';
import '../pages/color_select_page.dart';
import '../utils/enums.dart';
import '../widgets/count_picker_tile.dart';

part 'setting_tab2.dart';

class SettingTab extends StatelessWidget {
  const SettingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = CupertinoTheme.of(context).textTheme;
    final headStyle = TextStyle(fontSize: textTheme.navTitleTextStyle.fontSize);
    return PlatformScaffold(
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            stretch: true,
            expandedHeight: kExpandedSliverAppBarHeight,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: kStretchModes,
              background: SafeArea(bottom: false, child: ProfileHeader()),
            ),
          ),
          SliverToBoxAdapter(
            child: CupertinoFormSection.insetGrouped(
              header: Text(""),
              backgroundColor: const Color(0x00000000),
              children: [
                PlatformListTile(
                  leading: Icon(CupertinoIcons.heart),
                  title: const Text('Rate AI Vocabulary'),
                ),
                PlatformListTile(
                  leading: Icon(CupertinoIcons.share),
                  title: const Text('Share App'),
                  onTap: shareApp,
                ),
                PlatformListTile(
                  leading: Icon(CupertinoIcons.doc_text),
                  title: const Text('Privacy Policy'),
                  onTap: () => launchUrlString(
                    "https://github.com/cia1099/ai_vocabulary_web/blob/main/README.md",
                  ),
                ),
                PlatformListTile(
                  leading: Icon(CupertinoIcons.refresh_bold),
                  title: const Text('Restore Purchases'),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: CupertinoFormSection(
              header: Text('Study', style: headStyle),
              children: [
                PlatformListTile(
                  title: const Text('Does hide vocabulary title in sliders?'),
                  trailing: PlatformSwitch(
                    value: AppSettings.of(context).hideSliderTitle,
                    onChanged: (value) =>
                        AppSettings.of(context).hideSliderTitle = value,
                  ),
                ),
                PlatformListTile(
                  title: Text("Quiz"),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      for (final q in Quiz.values)
                        Row(
                          children: [
                            Radio.adaptive(
                              value: q,
                              activeColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              groupValue: AppSettings.of(context).quiz,
                              onChanged: (value) =>
                                  AppSettings.of(context).quiz = value!,
                            ),
                            Text(q.name.capitalize()),
                          ],
                        ),
                    ],
                  ),
                ),
                PlatformListTile(
                  title: Text("Default inquired sheet"),
                  trailing: SegmentExplanation(),
                ),
                CountPickerTile(
                  titlePattern: "Default Translator ,?,",
                  initialCount: AppSettings.of(context).translator.index,
                  itemText: (index, value) =>
                      TranslateLocate.values[index].native,
                  itemCount: TranslateLocate.values.length,
                  onPickDone: (index) {
                    AppSettings.of(context).translator =
                        TranslateLocate.values[index];
                  },
                ),
                CountPickerTile(
                  titlePattern: "Voicer ,?,",
                  initialCount: AppSettings.of(context).voicer.index,
                  itemText: (index, value) =>
                      '${AzureVoicer.values[index].name} ${AzureVoicer.values[index].gender == 'Male' ? '🙎‍♂️' : '🙎‍♀️'}',
                  itemCount: AzureVoicer.values.length,
                  onPickDone: (index) {
                    AppSettings.of(context).voicer = AzureVoicer.values[index];
                  },
                ),
                PlatformListTile(
                  title: Text("Accent"),
                  trailing: StatefulBuilder(
                    builder: (context, setState) => Wrap(
                      spacing: 8,
                      children: [
                        for (final accent in Accent.values)
                          Row(
                            children: [
                              Radio.adaptive(
                                value: accent,
                                activeColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                groupValue: AppSettings.of(context).accent,
                                onChanged: (accent) => setState(() {
                                  AppSettings.of(context).accent = accent!;
                                }),
                              ),
                              Text(
                                accent.flag,
                                textScaler: TextScaler.linear(2),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                CountPickerTile(
                  titlePattern: 'Review ,?, words, a, day',
                  initialCount: AppSettings.of(context).reviewCount,
                  itemText: (index, value) => value.toString(),
                  itemCount: 40,
                  onPickDone: (count) {
                    AppSettings.of(context).reviewCount = count;
                  },
                  transform: Matrix2(5, 0, 5, 1),
                ),
                CountPickerTile(
                  titlePattern: 'Learn, new ,?, words, a, day',
                  initialCount: AppSettings.of(context).learnCount,
                  itemText: (index, value) => value.toString(),
                  itemCount: 40,
                  onPickDone: (count) {
                    AppSettings.of(context).learnCount = count;
                  },
                  transform: Matrix2(5, 0, 5, 1),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: ValueListenableBuilder(
              valueListenable: AppSettings.of(context).studyStateListener,
              builder: (context, studyState, child) {
                final canPunchOut =
                    studyState.index >= StudyStatus.onTarget.index;
                return PlatformTextButton(
                  onPressed: !canPunchOut
                      ? null
                      : () => Navigator.push(
                          context,
                          platformPageRoute(
                            context: context,
                            fullscreenDialog: true,
                            builder: (context) => const PunchOutPage(),
                          ),
                        ),
                  child: child,
                );
              },
              child: const Text('Make up Punch Out'),
            ),
          ),
          SliverToBoxAdapter(
            child: CupertinoFormSection.insetGrouped(
              header: Text('Theme', style: headStyle),
              children: [
                PlatformListTile(
                  title: const Text('Dark mode'),
                  trailing: PlatformSwitch(
                    value:
                        AppSettings.of(context).brightness == Brightness.dark,
                    onChanged: (value) => AppSettings.of(context).brightness =
                        value ? Brightness.dark : Brightness.light,
                  ),
                ),
                PlatformListTile(
                  title: const Text('Application Color Theme'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => Navigator.of(context).push(
                    CupertinoDialogRoute(
                      builder: (context) => const ColorSelectPage(),
                      barrierColor: Theme.of(
                        context,
                      ).colorScheme.inverseSurface.withValues(alpha: .4),
                      context: context,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: CupertinoFormSection.insetGrouped(
              header: Text("Account", style: headStyle),
              children: [
                ActionButton(
                  child: Text("Sign Out"),
                  onPressed: () => signOutFirebase().whenComplete(
                    () => context.mounted && signOut(context),
                  ),
                ),
                ActionButton(
                  isDestructiveAction: true,
                  onPressed: () => deleteAccount(context),
                  child: Text("Delete Account"),
                ),
              ],
            ),
          ),
          SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }
}
