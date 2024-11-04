import 'package:ai_vocabulary/main.dart';
import 'package:ai_vocabulary/provider/word_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VocabularyTab extends StatelessWidget {
  const VocabularyTab({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height -
        kToolbarHeight -
        kBottomNavigationBarHeight;
    final maxWidth = MediaQuery.of(context).size.width;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Already checked days:', style: textTheme.titleLarge),
        Text('255', style: textTheme.headlineMedium),
        Container(
          height: 150,
          width: double.maxFinite,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              color: CupertinoColors.white),
          child: const Text('Learning progress'),
        ),
        SizedBox(
          // color: CupertinoColors.systemGrey,
          height: maxHeight / 4,
          child: GridView.count(
            primary: false,
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              SizedBox(
                height: 80,
                width: maxWidth / 4 - 8,
                // color: CupertinoColors.systemRed,
                child: StreamBuilder(
                    stream: WordProvider().provideWord,
                    builder: (context, snapshot) {
                      return AbsorbPointer(
                        absorbing: snapshot.data == null,
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.of(context).pushNamed(AppRoute.entry),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.app),
                              Text("normal")
                            ],
                          ),
                        ),
                      );
                    }),
              ),
              SizedBox(
                height: 80,
                width: maxWidth / 4 - 8,
                // color: CupertinoColors.systemRed,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(CupertinoIcons.hand_draw), Text("game")],
                ),
              ),
              SizedBox(
                height: 80,
                width: maxWidth / 4 - 8,
                // color: CupertinoColors.systemRed,
                child: const Column(
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
        )
      ],
    );
  }
}
