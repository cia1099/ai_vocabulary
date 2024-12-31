import 'package:ai_vocabulary/pages/collection_page.dart';
import 'package:ai_vocabulary/provider/word_provider.dart';
import 'package:ai_vocabulary/app_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class VocabularyTab extends StatelessWidget {
  const VocabularyTab({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height -
        kToolbarHeight -
        kBottomNavigationBarHeight;
    final hPadding = MediaQuery.of(context).size.width / 32;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Already checked days:', style: textTheme.titleLarge),
        Text('255', style: textTheme.headlineMedium),
        Container(
          height: 150,
          alignment: Alignment.center,
          width: double.maxFinite,
          margin: EdgeInsets.symmetric(horizontal: hPadding),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(),
              color: Theme.of(context).colorScheme.surfaceBright),
          child: PlatformTextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoute.todayWords),
              child: const Text("Today's study")),
        ),
        MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: Container(
            // color: Colors.red,
            height: maxHeight / 4,
            padding: EdgeInsets.all(hPadding),
            child: GridView.count(
              primary: false,
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                Card.outlined(
                  child: StreamBuilder(
                      stream: WordProvider().provideWord,
                      builder: (context, snapshot) {
                        return AbsorbPointer(
                          absorbing: snapshot.data == null,
                          child: InkWell(
                            onTap: () =>
                                Navigator.of(context).pushNamed(AppRoute.entry),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.square_stack),
                                Text("study")
                              ],
                            ),
                          ),
                        );
                      }),
                ),
                Card.outlined(
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(platformPageRoute(
                        context: context,
                        builder: (context) => const CollectionPage())),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(CupertinoIcons.star), Text("favorite")],
                    ),
                  ),
                ),
                const Card.outlined(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(CupertinoIcons.hand_draw), Text("game")],
                  ),
                ),
                const Card.outlined(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.photo),
                      Text(
                        "guess picture",
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
