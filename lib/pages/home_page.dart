import 'package:ai_vocabulary/pages/navigation_page.dart';
import 'package:ai_vocabulary/views/vocabulary_tab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final tabController = PageController();
    final pageController = PageController();
    double? tab = .0;
    tabController.addListener(() => tab = tabController.page);
    return ListenableBuilder(
      listenable: tabController,
      builder: (context, child) => PageView(
        controller: pageController,
        physics: const ClampingScrollPhysics(),
        onPageChanged: (index) {
          if (index > 0) {
            Navigator.push(
                context,
                platformPageRoute(
                  context: context,
                  builder: (context) => const SecondPage(),
                ));
          }
          pageController.jumpTo(0);
        },
        children: [child!, if (tab != null && tab! < .25) const SecondPage()],
      ),
      child: NavigationPage(tabController: tabController),
    );
  }
}
