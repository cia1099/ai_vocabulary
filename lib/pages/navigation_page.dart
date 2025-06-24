import 'package:ai_vocabulary/app_settings.dart';
import 'package:ai_vocabulary/pages/collection_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../tabs/alphabet_list_tab.dart';
import '../tabs/chart_tab.dart';
import '../tabs/setting_tab.dart';
import '../tabs/vocabulary_tab.dart';

class NavigationPage extends StatefulWidget {
  final Function(int index)? onTabChanged;
  const NavigationPage({super.key, this.onTabChanged});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  var _index = 0;
  var editableAlphabet = false;
  final bottomItems = [
    BottomNavigationBarItem(
      icon: PlatformWidget(
        material: (_, __) => const Icon(Icons.book_outlined),
        cupertino: (_, __) => const Icon(CupertinoIcons.book),
      ),
      label: "vocabulary",
    ),
    BottomNavigationBarItem(
      icon: PlatformWidget(
        material: (_, __) => const Icon(Icons.chat_bubble_outline),
        cupertino: (_, __) => const Icon(CupertinoIcons.chat_bubble_2),
      ),
      label: "chats",
    ),
    BottomNavigationBarItem(
      icon: PlatformWidget(
        material: (_, __) => const Icon(Icons.bar_chart),
        cupertino: (_, __) => const Icon(CupertinoIcons.doc_chart),
      ),
      label: "charts",
    ),
    BottomNavigationBarItem(
      icon: PlatformWidget(
        material: (_, __) => const Icon(Icons.settings),
        cupertino: (_, __) => const Icon(CupertinoIcons.gear),
      ),
      label: "setting",
    ),
  ];
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body:
          // PageView.builder(
          //   controller: widget.tabController,
          //   itemBuilder: (context, index) => switch (index) {
          //     1 => const AlphabetListTab(),
          //     2 => const ChartTab(),
          //     3 => const SettingTab(),
          //     _ => const VocabularyTab(),
          //   },
          //   itemCount: 4,
          //   physics: const NeverScrollableScrollPhysics(),
          // ),
          IndexedStack(
            index: _index,
            children: [
              MediaQuery.removeViewInsets(
                context: context,
                removeBottom: true,
                child: VocabularyTab(onTabChanged: widget.onTabChanged),
              ),
              MediaQuery.removeViewInsets(
                context: context,
                removeBottom: true,
                child: const AlphabetListTab(),
              ),
              ChartTab(key: _index == 2 ? ValueKey(_index) : null),
              const SettingTab(),
            ],
          ),
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        height: kBottomNavigationBarHeight,
        notchMargin: 2,
        shape: const CircularNotchedRectangle(),
        // color: Colors.red,
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Row(
            // crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(bottomItems.length + 1, (i) {
              var index = i;
              if (i == 2)
                return const SizedBox(width: 32);
              else if (i > 2) {
                index -= 1;
              }

              return PlatformIconButton(
                padding: EdgeInsets.zero,
                onPressed: _index == index
                    ? index != 0
                          ? null
                          : () => AppSettings.of(context)
                                .wordProvider
                                ?.pageController
                                .animateToPage(
                                  0,
                                  duration: Durations.medium3,
                                  curve: Curves.easeIn,
                                )
                    : () => setState(() {
                        _index = index;
                        widget.onTabChanged?.call(index);
                        // widget.tabController.jumpToPage(index);
                      }),
                icon: Column(
                  children: [
                    Theme(
                      data: ThemeData(
                        iconTheme: IconThemeData(
                          color: colorScheme.primary.withValues(
                            alpha: _index == index ? 1 : .4,
                          ),
                        ),
                      ),
                      child: bottomItems[index].icon,
                    ),
                    // _index == index
                    //     ? Expanded(
                    //         child: Lottie.asset('assets/lottie/chart.json'))
                    //     : bottomItems[index].icon,
                    Expanded(
                      child: FittedBox(
                        child: Text(
                          '${bottomItems[index].label}',
                          style: TextStyle(
                            color: colorScheme.primary.withValues(
                              alpha: _index == index ? 1 : .4,
                            ),
                            fontWeight: _index == index
                                ? FontWeight.w600
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                material: (_, __) => MaterialIconButtonData(
                  tooltip: bottomItems[index].tooltip,
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    // minimumSize: const Size.square(50),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                // cupertino: (_, __) => CupertinoIconButtonData(minSize: 50),
              );
            }),
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          platformPageRoute(
            context: context,
            fullscreenDialog: true,
            builder: (context) => const CollectionPage(),
          ),
        ),
        mini: true,
        shape: const CircleBorder(),
        elevation: 1,
        child: const Icon(CupertinoIcons.add),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
    );
  }
}
