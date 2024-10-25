import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class SettingTab extends StatelessWidget {
  const SettingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height -
        kToolbarHeight -
        kBottomNavigationBarHeight -
        34;
    final switches = List.generate(7, (_) => Random().nextBool());
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          // color: CupertinoColors.systemGrey2,
          height: maxHeight,
          child: SingleChildScrollView(
            physics:
                AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: Column(
              children: [
                const Padding(padding: EdgeInsets.only(top: 24)),
                PlatformListTile(
                  title: const Text('Send me marketing emails'),
                  // The Material switch has a platform adaptive constructor.
                  trailing: PlatformSwitch(
                    value: switches[0],
                    onChanged: (value) => setState(() => switches[0] = value),
                  ),
                ),
                PlatformListTile(
                  title: const Text('Enable notifications'),
                  trailing: PlatformSwitch(
                    value: switches[1],
                    onChanged: (value) => setState(() => switches[1] = value),
                  ),
                ),
                PlatformListTile(
                  title: const Text('Remind me to rate this app'),
                  trailing: PlatformSwitch(
                    value: switches[2],
                    onChanged: (value) => setState(() => switches[2] = value),
                  ),
                ),
                PlatformListTile(
                  title: const Text('Background song refresh'),
                  trailing: PlatformSwitch(
                    value: switches[3],
                    onChanged: (value) => setState(() => switches[3] = value),
                  ),
                ),
                PlatformListTile(
                  title: const Text('Recommend me songs based on my location'),
                  trailing: PlatformSwitch(
                    value: switches[4],
                    onChanged: (value) => setState(() => switches[4] = value),
                  ),
                ),
                PlatformListTile(
                  title: const Text('Auto-transition playback to cast devices'),
                  trailing: PlatformSwitch(
                    value: switches[5],
                    onChanged: (value) => setState(() => switches[5] = value),
                  ),
                ),
                PlatformListTile(
                  title: const Text('Find friends from my contact list'),
                  trailing: PlatformSwitch(
                    value: switches[6],
                    onChanged: (value) => setState(() => switches[6] = value),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}