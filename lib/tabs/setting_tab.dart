import 'dart:math' show Random, pi;

import 'package:ai_vocabulary/app_route.dart';
import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/pages/payment_page.dart';
import 'package:ai_vocabulary/pages/punch_out_page.dart';
import 'package:ai_vocabulary/provider/user_provider.dart';
import 'package:ai_vocabulary/utils/function.dart';
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:ai_vocabulary/widgets/action_button.dart';
import 'package:ai_vocabulary/widgets/segment_explanation.dart';
import 'package:ai_vocabulary/firebase/authorization.dart' show signOutFirebase;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:vector_math/vector_math.dart' show Matrix2;

import '../api/dict_api.dart' show deleteFirebaseAccount;
import '../app_settings.dart';
import '../pages/color_select_page.dart';
import '../utils/enums.dart';
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
              stretchModes: kStretchModes,
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
                              activeColor:
                                  Theme.of(context).colorScheme.primary,
                              groupValue: AppSettings.of(context).quiz,
                              onChanged:
                                  (value) =>
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
                  itemText:
                      (index, value) => TranslateLocate.values[index].native,
                  itemCount: TranslateLocate.values.length,
                  onPickDone: (index) {
                    AppSettings.of(context).translator =
                        TranslateLocate.values[index];
                  },
                ),
                CountPickerTile(
                  titlePattern: "Voicer ,?,",
                  initialCount: AppSettings.of(context).voicer.index,
                  itemText:
                      (index, value) =>
                          '${AzureVoicer.values[index].name} ${AzureVoicer.values[index].gender == 'Male' ? '🙎‍♂️' : '🙎‍♀️'}',
                  itemCount: AzureVoicer.values.length,
                  onPickDone: (index) {
                    AppSettings.of(context).voicer = AzureVoicer.values[index];
                  },
                ),
                PlatformListTile(
                  title: Text("Accent"),
                  trailing: StatefulBuilder(
                    builder:
                        (context, setState) => Wrap(
                          spacing: 8,
                          children: [
                            for (final accent in Accent.values)
                              Row(
                                children: [
                                  Radio.adaptive(
                                    value: accent,
                                    activeColor:
                                        Theme.of(context).colorScheme.primary,
                                    groupValue: AppSettings.of(context).accent,
                                    onChanged:
                                        (accent) => setState(() {
                                          AppSettings.of(context).accent =
                                              accent!;
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
            child: CupertinoFormSection(
              header: Text("Account"),
              children: [
                ActionButton(
                  child: Text("Sign Out"),
                  onPressed:
                      () => signOutFirebase().whenComplete(
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

  void deleteAccount(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showPlatformDialog<bool?>(
      context: context,
      builder:
          (context) => PlatformAlertDialog(
            title: const Text('Delete Account'),
            content: const Text(
              'Are you sure you want to delete this account?',
            ),
            actions: [
              PlatformDialogAction(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
                cupertino:
                    (_, __) => CupertinoDialogActionData(isDefaultAction: true),
              ),
              PlatformDialogAction(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes'),
                material:
                    (_, __) => MaterialDialogActionData(
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.error,
                      ),
                    ),
                cupertino:
                    (_, __) =>
                        CupertinoDialogActionData(isDestructiveAction: true),
              ),
            ],
          ),
    ).then((isDelete) {
      if (isDelete != true) return;
      signOutFirebase()
          .then((_) => deleteFirebaseAccount())
          .whenComplete(() => context.mounted && signOut(context));
    });
  }

  bool signOut(BuildContext context) {
    UserProvider().currentUser = null;
    AppSettings.of(context).resetCacheOrSignOut(signOut: true);
    Navigator.pushReplacementNamed(context, AppRoute.login);
    return true;
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
                  foregroundImage:
                      user.photoURL == null
                          ? null
                          : NetworkImage(user.photoURL!),
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
                      user.name ?? "Anonymous",
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
                          child: Transform(
                            transform: Matrix4.rotationX(pi),
                            alignment: Alignment(0, 0),
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
                    PlatformTextButton(
                      onPressed:
                          () => Navigator.push(
                            context,
                            platformPageRoute(
                              context: context,
                              fullscreenDialog: true,
                              builder: (context) => PaymentPage(),
                            ),
                          ),
                      padding: EdgeInsets.zero,
                      child: Text(user.role.capitalize()),
                      material:
                          (_, __) => MaterialTextButtonData(
                            style: TextButton.styleFrom(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
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
