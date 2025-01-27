import 'package:ai_vocabulary/app_settings.dart';
import 'package:ai_vocabulary/pages/cloze_page.dart';
import 'package:ai_vocabulary/pages/navigation_page.dart';
import 'package:ai_vocabulary/utils/gesture_route_page.dart';
import 'package:ai_vocabulary/widgets/entry_actions.dart';
import 'package:flutter/cupertino.dart';
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
        return GestureRoutePage(
            draggable: value == 0,
            primaryPage: child!,
            newPage: const SecondPage(
              hasActions: true,
            ));
        // return PageView(
        //   controller: pageController,
        //   physics: value == 0
        //       ? const ClampingScrollPhysics()
        //       : const NeverScrollableScrollPhysics(),
        //   onPageChanged: (index) {
        //     pageController
        //         .animateToPage(0,
        //             duration: Durations.short2, curve: Curves.ease)
        //         .then((_) {
        //       if (index > 0) {
        //         Navigator.push(
        //             context,
        //             platformPageRoute(
        //                 context: context,
        //                 builder: (context) => SecondPage(
        //                       controller: pageController,
        //                       hasActions: true,
        //                     )));
        //       }
        //     });
        //   },
        //   children: [
        //     child!,
        //     if (value == 0) SecondPage(controller: pageController),
        //   ],
        // );
      },
      child: NavigationPage(onTabChanged: (index) => tabIndex.value = index),
    );
  }
}

class SecondPage extends StatelessWidget {
  final bool hasActions;
  const SecondPage({super.key, this.hasActions = false});

  @override
  Widget build(BuildContext context) {
    final provider = AppSettings.of(context).wordProvider;
    return StreamBuilder(
      stream: provider?.provideWord,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return PlatformScaffold(
            body: Center(
              child: SpinKitFadingCircle(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
          );
        }
        final word = snapshot.data!;
        return ClozePage(
          word: word,
          actions: hasActions ? EntryActions(wordID: word.wordId) : null,
        );
      },
    );
  }
}
