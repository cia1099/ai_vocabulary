import 'dart:io';

import 'package:ai_vocabulary/database/my_db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../mock_data.dart';

class PunchOutPage extends StatelessWidget {
  const PunchOutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    const aspect = 16 / 9;
    return PlatformScaffold(
      body: Stack(
        alignment: const Alignment(0, 0),
        children: [
          FractionallySizedBox(
              heightFactor: 2 / 3,
              child: ColoredBox(
                color: colorScheme.surfaceContainer,
                child: RotatedBox(
                  quarterTurns: -1,
                  child: ListWheelScrollView.useDelegate(
                    // onSelectedItemChanged: (value) => print(value),
                    physics: const FixedExtentScrollPhysics(),
                    overAndUnderCenterOpacity: .9,
                    itemExtent: screenWidth * .75,
                    childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 4,
                        builder: (context, index) => AspectRatio(
                              aspectRatio: aspect,
                              child: RotatedBox(
                                quarterTurns: 1,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          kRadialReactionRadius),
                                      image: DecorationImage(
                                        fit: BoxFit.fill,
                                        image: AssetImage(
                                            'assets/punch${index.toString().padLeft(2, '0')}.png'),
                                      )),
                                  child: const Align(
                                    alignment: Alignment(0, .8),
                                    child: Text('Shit man'),
                                  ),
                                ),
                              ),
                            )),
                  ),
                ),
              )),
          Align(
            alignment: const FractionalOffset(.5, .9),
            child: FutureBuilder(
              future: MyDB().isReady,
              builder: (context, snapshot) => PlatformElevatedButton(
                onPressed: snapshot.data != true ? null : punchOut,
                child: Text.rich(
                    TextSpan(
                      text: 'Get 6 shells for sharing',
                      children: [
                        TextSpan(
                          text:
                              '\nGet shells only when returning to the app after sharing',
                          style: TextStyle(
                              fontSize: textTheme.labelSmall?.fontSize,
                              height: textTheme.labelSmall?.height,
                              color: CupertinoColors.systemGrey4
                                  .resolveFrom(context)),
                        )
                      ],
                    ),
                    textAlign: TextAlign.center),
                cupertino: (ctx, _) {
                  final h = (ctx.findRenderObject() as RenderBox?)?.size.height;
                  return CupertinoElevatedButtonData(
                      borderRadius:
                          h != null ? BorderRadius.circular(h / 2) : null);
                },
                material: (ctx, _) {
                  final h = (ctx.findRenderObject() as RenderBox?)?.size.height;
                  return MaterialElevatedButtonData(
                    style: h != null
                        ? ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(h / 2)))
                        : null,
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  void punchOut() async {
    final url = Uri.parse(apple.asset!);
    final res = await http.get(url);
    final imgPath = p.join(MyDB().appDirectory, 'punch_out.jpg');
    final img = await File(imgPath).writeAsBytes(res.bodyBytes);
    const text = '''
#AI Vocabulary Punch Card# Day
Memorize words ✅
I'm memorizing words with AI Vocabulary, punch with me! https://www.cia1099.cloudns.ch
''';
    final share = await Share.shareXFiles(
      [XFile(img.path)],
      text: text,
      subject: 'I am studying in AI vocabulary',
    );
    switch (share.status) {
      case ShareResultStatus.success:
        print('Thanks your sharing');
      case ShareResultStatus.unavailable:
        print('There is something wrong');
      default:
        print('Dismiss punch out');
    }
    img.delete();
  }
}
