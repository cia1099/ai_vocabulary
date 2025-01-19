import 'package:ai_vocabulary/pages/navigation_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();
    final tabIndex = ValueNotifier(0);
    return ValueListenableBuilder(
      valueListenable: tabIndex,
      builder: (context, value, child) => PageView(
        controller: pageController,
        physics: value == 0
            ? const ClampingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        // onPageChanged: (index) {
        //   if (index > 0) {
        //     Navigator.push(
        //         context,
        //         platformPageRoute(
        //           context: context,
        //           builder: (context) => const SecondPage(),
        //         ));
        //   }
        //   pageController.jumpTo(0);
        // },
        children: [
          child!,
          if (value == 0) SecondPage(controller: pageController)
        ],
      ),
      child: NavigationPage(onTabChanged: (index) => tabIndex.value = index),
    );
  }
}

class SecondPage extends StatelessWidget {
  final PageController controller;
  const SecondPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: PlatformAppBar(
          title: const Text('第二页'),
          leading: CupertinoNavigationBarBackButton(
            onPressed: () {
              controller.previousPage(
                  duration: Durations.short4, curve: Curves.ease);
            },
          ),
        ),
      ),
      body: Container(
        // color: Colors.blueGrey,
        alignment: const Alignment(0, 0),
        child: const Text(
          '这是第二页',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
