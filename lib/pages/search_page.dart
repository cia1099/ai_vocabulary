import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_lorem/flutter_lorem.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final textController = TextEditingController();
  late final scrollController = ScrollController()
    ..addListener(scrollNotification);
  late final suffixIcon = Padding(
    padding: const EdgeInsets.only(right: 8),
    child: GestureDetector(
      onTap: textController.clear,
      child: const Icon(CupertinoIcons.delete_left_fill),
    ),
  );
  final refreshKey = GlobalKey<RefreshIndicatorState>();
  var refreshIndex = -1, isRefreshing = false;
  final items = List.filled(5, 0);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hPadding = MediaQuery.sizeOf(context).width / 32;
    return PlatformScaffold(
      appBar: PlatformAppBar(
        leading: const SizedBox.shrink(),
        backgroundColor: kCupertinoSheetColor.resolveFrom(context),
        title: Row(
          children: [
            Expanded(
              child: PlatformTextField(
                autofocus: true,
                hintText: 'find it',
                controller: textController,
                textInputAction: TextInputAction.search,
                cupertino: (_, __) => CupertinoTextFieldData(
                  decoration: BoxDecoration(
                      border: Border.all(color: colorScheme.primary, width: 2),
                      borderRadius:
                          BorderRadius.circular(kRadialReactionRadius)),
                  prefix: const SizedBox.square(dimension: 4),
                  suffix: suffixIcon,
                ),
                material: (_, __) => MaterialTextFieldData(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(kRadialReactionRadius),
                        borderSide:
                            BorderSide(color: colorScheme.primary, width: 2)),
                    prefix: const SizedBox.square(dimension: 4),
                    suffixIcon: suffixIcon,
                  ),
                ),
              ),
            ),
            PlatformTextButton(
                onPressed: Navigator.of(context).pop,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: const Text('Cancel'))
          ],
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator.noSpinner(
          key: refreshKey,
          onRefresh: () async {
            setState(() {
              isRefreshing = true;
            });
            return Future.delayed(Durations.extralong4 * 1.5);
          },
          onStatusChange: (status) {
            if (status == RefreshIndicatorStatus.done) {
              if (refreshIndex > 0) {
                Future.delayed(Durations.extralong4, () {}).whenComplete(() {
                  setState(() {
                    isRefreshing = false;
                    refreshIndex = -1;
                  });
                });
              } else {
                setState(() {
                  isRefreshing = false;
                  refreshIndex = -1;
                });
              }
            }
          },
          notificationPredicate: (notification) => false,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            controller: scrollController,
            slivers: [
              SliverList.builder(
                // prototypeItem: itemBuilder(0, context, hPadding, colorScheme),
                itemCount: items.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0 || index == items.length + 1) {
                    final offstage = !(isRefreshing &&
                        (index == 0 ? refreshIndex == 0 : refreshIndex > 0));
                    return Offstage(
                        offstage: offstage,
                        child: FutureBuilder(
                          future: isRefreshing
                              ? refreshKey.currentState?.show()
                              : null,
                          builder: (context, snapshot) => Center(
                            child: snapshot.connectionState ==
                                    ConnectionState.done
                                ? const Text('No more data')
                                : const CircularProgressIndicator.adaptive(),
                          ),
                        ));
                  }
                  final i = index - 1;
                  return Container(
                    height: 100,
                    alignment: const Alignment(0, 0),
                    color: index.isEven ? Colors.black12 : null,
                    child: Text('$i', textScaler: const TextScaler.linear(5)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget itemBuilder(int index, BuildContext context, double hPadding,
      ColorScheme colorScheme) {
    final textTheme = Theme.of(context).textTheme;
    final i = index - 1;
    return Container(
      height: 40,
      decoration: BoxDecoration(
          border: Border(
              top: i > 0
                  ? BorderSide(
                      color: CupertinoColors.secondarySystemFill
                          .resolveFrom(context))
                  : BorderSide.none)),
      child: Row(
        spacing: hPadding,
        children: [
          Text(lorem(paragraphs: 1, words: 1), style: textTheme.titleSmall),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // print('$index row has max width ${constraints.maxWidth}');
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    LimitedBox(
                      maxWidth: constraints.maxWidth,
                      child: Text(
                        lorem(paragraphs: 1, words: 1),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colorScheme.outline),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void scrollNotification() {
    final dExtent = scrollController.position.extentBefore -
        scrollController.position.extentAfter;
    // print('dExtent: $dExtent');
    final maxExtent = scrollController.position.maxScrollExtent;
    if (dExtent < -maxExtent - 125) {
      refreshKey.currentState?.show();
      refreshIndex = 0;
    } else if (dExtent > maxExtent + 125) {
      refreshKey.currentState?.show(atTop: false);
      refreshIndex = 1;
    }
  }
}
