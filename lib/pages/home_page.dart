import 'package:ai_vocabulary/app_route.dart';
import 'package:ai_vocabulary/app_settings.dart';
import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:ai_vocabulary/pages/navigation_page.dart';
import 'package:ai_vocabulary/pages/quiz_shuttle.dart';
import 'package:ai_vocabulary/provider/word_provider.dart';
import 'package:ai_vocabulary/utils/gesture_route_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final tabIndex = ValueNotifier(0);

    return ValueListenableBuilder(
      valueListenable: tabIndex,
      builder: (context, value, child) {
        final provider = AppSettings.of(context).wordProvider;
        return GestureRoutePage(
          draggable: value == 0 && provider is RecommendProvider,
          pushPage: SecondPage(provider: provider),
          routeName: AppRoute.quiz,
          child: child!,
        );
      },
      child: NavigationPage(onTabChanged: (index) => tabIndex.value = index),
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
            body: Center(
              child: SpinKitFadingCircle(
                color: Theme.of(context).colorScheme.secondary,
              ),
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
