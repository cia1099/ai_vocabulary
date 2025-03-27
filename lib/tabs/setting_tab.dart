import 'dart:math' show Random;

import 'package:ai_vocabulary/app_route.dart';
import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/pages/punch_out_page.dart';
import 'package:ai_vocabulary/provider/user_provider.dart';
import 'package:ai_vocabulary/utils/function.dart';
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:ai_vocabulary/widgets/action_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:ai_vocabulary/firebase/authorization.dart' show signOutFirebase;

import '../app_settings.dart';
import '../pages/color_select_page.dart';
import '../widgets/count_picker_tile.dart';

class SettingTab extends StatelessWidget {
  const SettingTab({super.key});

  @override
  Widget build(BuildContext context) {
    // final maxHeight =
    //     MediaQuery.sizeOf(context).height -
    //     kToolbarHeight -
    //     kBottomNavigationBarHeight -
    //     34;
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
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
                StretchMode.fadeTitle,
              ],
              background: SafeArea(bottom: false, child: ProfileHeader()),
            ),
          ),
          SliverToBoxAdapter(
            child: StatefulBuilder(
              builder: (context, setState) {
                final switches = List.generate(7, (_) => Random().nextBool());
                return Wrap(
                  children: [
                    PlatformListTile(
                      title: const Text('Send me marketing emails'),
                      // The Material switch has a platform adaptive constructor.
                      trailing: PlatformSwitch(
                        value: switches[0],
                        onChanged:
                            (value) => setState(() => switches[0] = value),
                      ),
                    ),
                    PlatformListTile(
                      title: const Text('Enable notifications'),
                      trailing: PlatformSwitch(
                        value: switches[1],
                        onChanged:
                            (value) => setState(() => switches[1] = value),
                      ),
                    ),
                    PlatformListTile(
                      title: const Text('Remind me to rate this app'),
                      trailing: PlatformSwitch(
                        value: switches[2],
                        onChanged:
                            (value) => setState(() => switches[2] = value),
                      ),
                    ),
                    PlatformListTile(
                      title: const Text('Background song refresh'),
                      trailing: PlatformSwitch(
                        value: switches[3],
                        onChanged:
                            (value) => setState(() => switches[3] = value),
                      ),
                    ),
                    PlatformListTile(
                      title: const Text(
                        'Recommend me songs based on my location',
                      ),
                      trailing: PlatformSwitch(
                        value: switches[4],
                        onChanged:
                            (value) => setState(() => switches[4] = value),
                      ),
                    ),
                    PlatformListTile(
                      title: const Text(
                        'Auto-transition playback to cast devices',
                      ),
                      trailing: PlatformSwitch(
                        value: switches[5],
                        onChanged:
                            (value) => setState(() => switches[5] = value),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: CupertinoFormSection(
              header: const Text('Study'),
              children: [
                PlatformListTile(
                  title: const Text('Does hide vocabulary title in sliders?'),
                  trailing: PlatformSwitch(
                    value: AppSettings.of(context).hideSliderTitle,
                    onChanged:
                        (value) =>
                            AppSettings.of(context).hideSliderTitle = value,
                  ),
                ),
                CountPickerTile(
                  titlePattern: 'Review ,?, words, a, day',
                  initialCount: AppSettings.of(context).reviewCount,
                  onPickDone: (count) {
                    AppSettings.of(context).reviewCount = count;
                  },
                ),
                CountPickerTile(
                  titlePattern: 'Learn, new ,?, words, a, day',
                  initialCount: AppSettings.of(context).learnCount,
                  onPickDone: (count) {
                    AppSettings.of(context).learnCount = count;
                  },
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: CupertinoFormSection(
              header: const Text('Theme'),
              children: [
                PlatformListTile(
                  title: const Text('Dark mode'),
                  trailing: PlatformSwitch(
                    value:
                        AppSettings.of(context).brightness == Brightness.dark,
                    onChanged:
                        (value) =>
                            AppSettings.of(context).brightness =
                                value ? Brightness.dark : Brightness.light,
                  ),
                ),
                PlatformListTile(
                  title: const Text('Application Color Theme'),
                  trailing: const CupertinoListTileChevron(),
                  onTap:
                      () => Navigator.of(context).push(
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
            child: ListenableBuilder(
              listenable: MyDB(),
              builder:
                  (context, child) => FutureBuilder(
                    future: MyDB().isReady,
                    builder: (context, snapshot) {
                      final canPunchOut =
                          snapshot.data == true &&
                          AppSettings.of(context).studyState.index >=
                              StudyStatus.onTarget.index;
                      return PlatformTextButton(
                        onPressed:
                            !canPunchOut
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
                  ),
              child: const Text('Make up Punch Out'),
            ),
          ),
          SliverToBoxAdapter(
            child: CupertinoFormSection(
              header: Text("Account"),
              children: [
                ActionButton(
                  // isDestructiveAction: true,
                  child: Text("Sign Out"),
                  onPressed: () {
                    UserProvider().currentUser = null;
                    AppSettings.of(context).resetCacheOrSignOut(signOut: true);
                    signOutFirebase().then(
                      (_) =>
                          context.mounted
                              ? Navigator.pushReplacementNamed(
                                context,
                                AppRoute.login,
                              )
                              : null,
                    );
                  },
                ),
                ActionButton(
                  isDestructiveAction: true,
                  onPressed: () {},
                  child: Text("Shit man"),
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

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hPadding = MediaQuery.sizeOf(context).width / 32;
    return Container(
      alignment: Alignment(0, 0),
      // color: Colors.green,
      // height: 100, // minus SafeAre remains 100
      padding: EdgeInsets.symmetric(horizontal: hPadding),
      child: StreamBuilder(
        stream: UserProvider().userStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator.adaptive();
          }
          final user = snapshot.data!;
          return InkWell(
            child: Row(
              spacing: hPadding,
              children: [
                CircleAvatar(
                  minRadius: 0,
                  maxRadius: 50,
                  child: FractionallySizedBox(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Icon(CupertinoIcons.person_crop_circle),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium,
                    ),
                    Wrap(
                      children: [
                        LimitedBox(
                          maxWidth: 100,
                          child: Text(
                            "ID: ${user.uid}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: user.uid));
                          },
                          child: RotatedBox(
                            quarterTurns: -1,
                            child: Icon(
                              CupertinoIcons.square_on_square,
                              size: textTheme.bodyMedium?.fontSize?.scale(
                                textTheme.bodyMedium?.height,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Expanded(child: SizedBox()),
                Icon(
                  CupertinoIcons.right_chevron,
                  size: CupertinoTheme.of(
                    context,
                  ).textTheme.textStyle.fontSize?.scale(1.5),
                  color: CupertinoColors.systemGrey2.resolveFrom(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
