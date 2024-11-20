import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ReportPopUpPage extends StatelessWidget {
  const ReportPopUpPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: const Alignment(.8, -.7),
      widthFactor: .5,
      heightFactor: .12,
      child: Card(
        child: Column(
          children: [
            PlatformListTile(
              title: const Text('Study Setting'),
              leading: const Icon(CupertinoIcons.gear),
              cupertino: (_, __) => CupertinoListTileData(leadingToTitle: 4),
            ),
            PlatformListTile(
              title: const Text('Report Issue'),
              leading: const Icon(CupertinoIcons.exclamationmark_triangle),
              cupertino: (_, __) => CupertinoListTileData(leadingToTitle: 4),
            ),
          ],
        ),
      ),
    );
  }
}
