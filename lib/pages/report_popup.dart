import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ReportPopUpPage extends StatelessWidget {
  const ReportPopUpPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            top: kToolbarHeight * 2,
            right: 16,
            child: SizedBox(
              height: 100,
              width: 180,
              child: Card(
                child: Column(
                  children: [
                    PlatformListTile(
                      title: const Text('Study Setting'),
                      leading: const Icon(CupertinoIcons.gear),
                      cupertino: (_, __) =>
                          CupertinoListTileData(leadingToTitle: 4),
                    ),
                    PlatformListTile(
                      title: const Text('Report Issue'),
                      leading:
                          const Icon(CupertinoIcons.exclamationmark_triangle),
                      cupertino: (_, __) =>
                          CupertinoListTileData(leadingToTitle: 4),
                    ),
                  ],
                ),
              ),
            ))
      ],
    );
  }
}
