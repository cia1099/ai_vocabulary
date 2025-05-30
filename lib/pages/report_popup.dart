import 'package:ai_vocabulary/pages/report_page.dart';
import 'package:ai_vocabulary/utils/load_word_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../app_route.dart';

class ReportPopUpPage extends StatelessWidget {
  const ReportPopUpPage({
    super.key,
    required this.wordID,
    required this.anchorPoint,
  });
  final int wordID;
  final Offset anchorPoint;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    const width = 200.0;
    final x = anchorPoint.dx + width / 2;
    final left = x > screenWidth
        ? screenWidth - width - screenWidth / 32
        : anchorPoint.dx - width / 2;
    return PlatformWidgetBuilder(
      cupertino: (_, child, _) => child,
      material: (_, child, _) =>
          Material(type: MaterialType.transparency, child: child),
      child: Stack(
        children: [
          Positioned(
            left: left,
            top: anchorPoint.dy * 1.5,
            width: width,
            child: CupertinoPopupSurface(
              child: Wrap(
                children: [
                  // PlatformListTile(
                  //   title: const Text('Study Setting'),
                  //   leading: const Icon(CupertinoIcons.gear),
                  //   cupertino: (_, __) =>
                  //       CupertinoListTileData(leadingToTitle: 4),
                  // ),
                  PlatformListTile(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        WordRoute(
                          wordID: wordID,
                          builder: (context, word) => ReportPage(word: word),
                          settings: const RouteSettings(name: AppRoute.report),
                        ),
                      );
                    },
                    title: const Text('Report Issue'),
                    leading: const Icon(
                      CupertinoIcons.exclamationmark_triangle,
                    ),
                    cupertino: (_, __) =>
                        CupertinoListTileData(leadingToTitle: 4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
