import 'package:ai_vocabulary/app_route.dart';
import 'package:ai_vocabulary/app_settings.dart';
import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:ai_vocabulary/pages/navigation_page.dart';
import 'package:ai_vocabulary/pages/quiz_shuttle.dart';
import 'package:ai_vocabulary/provider/word_provider.dart';
import 'package:ai_vocabulary/utils/gesture_route_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var tabIndex = 0;
  late final Widget child = NavigationPage(
    onTabChanged: (index) => setState(() {
      tabIndex = index;
    }),
  );
  @override
  Widget build(BuildContext context) {
    final provider = AppSettings.of(context).wordProvider;
    return GestureRoutePage(
      draggable: tabIndex == 0 && provider is RecommendProvider,
      pushPage: SecondPage(provider: provider),
      routeName: AppRoute.quiz,
      child: child,
    );
  }
}

class SecondPage extends StatelessWidget {
  final WordProvider? provider;
  const SecondPage({super.key, this.provider});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: provider?.provideWord,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return PlatformScaffold(
            appBar: PlatformAppBar(
              leading: CupertinoNavigationBarBackButton(
                onPressed: Navigator.of(context).pop,
                previousPageTitle: 'Back',
              ),
            ),
            body: Center(
              child: Text(
                "There is no word can be quized",
                style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
              ),
              // SpinKitFadingCircle(
              //   color: Theme.of(context).colorScheme.secondary,
              // ),
            ),
          );
        }
        final word = snapshot.data!;
        return QuizShuttle(
          key: ValueKey(word.wordId),
          word: word,
          entry: word.generateClozeEntry(provider?.clozeSeed),
        );
      },
    );
  }
}
