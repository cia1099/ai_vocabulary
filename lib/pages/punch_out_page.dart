import 'dart:io';

import 'package:ai_vocabulary/database/my_db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../mock_data.dart';

class PunchOutPage extends StatelessWidget {
  const PunchOutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      body: Stack(
        children: [
          Align(
            alignment: const FractionalOffset(.5, .85),
            child: FutureBuilder(
              future: MyDB().isReady,
              builder: (context, snapshot) => PlatformElevatedButton(
                onPressed: snapshot.data != true ? null : punchOut,
                child: const Text('Punch Out'),
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
    final share = await Share.shareXFiles(
      [XFile(img.path)],
      text: 'Welcome AI vocabulary',
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
