import 'dart:async';

import 'package:ai_vocabulary/utils/handle_except.dart';
import 'package:flutter/material.dart';

class LoadMoreListView<T> extends StatefulWidget {
  const LoadMoreListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.indicator,
    this.thresholdExtent = 125,
    this.onLoadMore,
    this.bottomPadding,
  });
  final int itemCount;
  final Widget? Function(BuildContext context, int index) itemBuilder;
  final ScrollController? controller;
  final Widget? indicator;
  final double thresholdExtent;
  final double? bottomPadding;
  final Future<T> Function(bool atTop)? onLoadMore;

  factory LoadMoreListView.builder({
    Key? key,
    required int itemCount,
    required Widget Function(BuildContext context, int index) itemBuilder,
    ScrollController? controller,
    Widget? indicator,
    double thresholdExtent = 125,
    double? bottomPadding,
    Future<T> Function(bool atTop)? onLoadMore,
  }) =>
      LoadMoreListView(
        key: key,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        controller: controller,
        indicator: indicator,
        thresholdExtent: thresholdExtent,
        bottomPadding: bottomPadding,
        onLoadMore: onLoadMore,
      );

  @override
  State<LoadMoreListView> createState() => _LoadMoreListViewState();
}

class _LoadMoreListViewState extends State<LoadMoreListView> {
  final refreshKey = GlobalKey<RefreshIndicatorState>();
  late final scrollController = (widget.controller ?? ScrollController())
    ..addListener(scrollNotification);
  var refreshIndex = -1, isRefreshing = false;
  Future? loadFuture;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return RefreshIndicator.noSpinner(
      key: refreshKey,
      onRefresh: () async {
        setState(() {
          isRefreshing = true;
          loadFuture ??= widget.onLoadMore?.call(refreshIndex == 0);
        });
        await loadFuture?.catchError((_) => false);
      },
      onStatusChange: (status) {
        if (status == RefreshIndicatorStatus.done) {
          loadFuture?.onError((e, _) => Exception(e)).then((hasMore) {
            if (hasMore is Exception ||
                refreshIndex > 0 && (hasMore! || hasMore == false)) {
              return Future.delayed(Durations.extralong4);
            }
          }).whenComplete(() {
            setState(() {
              isRefreshing = false;
              refreshIndex = -1;
              loadFuture = null;
            });
          });
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
            itemCount: widget.itemCount + 2,
            itemBuilder: (context, index) {
              if (index == 0 || index == widget.itemCount + 1) {
                final offstage = !(isRefreshing &&
                    (index == 0 ? refreshIndex == 0 : refreshIndex > 0));
                return Container(
                  height: index == 0 ? null : widget.bottomPadding,
                  alignment: const Alignment(0, -.85),
                  child: Offstage(
                      offstage: offstage,
                      child: FutureBuilder(
                        initialData: false,
                        future: loadFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return widget.indicator ??
                                const CircularProgressIndicator.adaptive();
                          }
                          if (snapshot.hasError) {
                            return Text(messageExceptions(snapshot.error),
                                style: TextStyle(color: colorScheme.error));
                          }

                          return snapshot.connectionState ==
                                      ConnectionState.done &&
                                  snapshot.data == false
                              ? Text('No more data',
                                  style: TextStyle(color: colorScheme.outline))
                              : const SizedBox.shrink();
                        },
                      )),
                );
              }
              return widget.itemBuilder(context, index - 1);
            },
          ),
        ],
      ),
    );
  }

  void scrollNotification() {
    if (loadFuture != null) return;
    // print(
    //     'total = ${scrollController.position.extentTotal}, inside = ${scrollController.position.extentInside}');
    // print(
    //     'pixel = ${scrollController.position.pixels}, max = ${scrollController.position.maxScrollExtent}');
    // print('Before = ${scrollController.position.extentBefore}');
    // print('After = ${scrollController.position.extentAfter}');
    final maxExtent = scrollController.position.maxScrollExtent;
    final pixel = scrollController.position.pixels;
    if (pixel < -widget.thresholdExtent) {
      refreshKey.currentState?.show();
      refreshIndex = 0;
    } else if (pixel - maxExtent > widget.thresholdExtent) {
      refreshKey.currentState?.show(atTop: false);
      refreshIndex = 1;
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollNotification);
    refreshKey.currentState?.deactivate();
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    theme: ThemeData(brightness: Brightness.light),
    home: const Example(),
  ));
}

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  var items = List.filled(5, 0, growable: true);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // navigationBar: const CupertinoNavigationBar(
        //   middle: Text('Load more Example'),
        // ),
        appBar: AppBar(
          title: const Text('Load more Example'),
        ),
        body: LoadMoreListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) => Container(
            height: 100,
            alignment: const Alignment(0, 0),
            color: index.isEven ? Colors.black12 : null,
            child: Text('$index', textScaler: const TextScaler.linear(5)),
          ),
          bottomPadding: 100,
          onLoadMore: (atTop) async {
            var hasMore = true; //rng.nextBool();
            // print('has more? $hasMore');
            await Future.delayed(Durations.extralong4 * 1.5);
            // throw Exception('error happen');
            if (!atTop && hasMore) {
              hasMore = true;
              items.addAll(List.filled(5, 0));
              // items.add(1);
              // Future.delayed(
              //     Durations.long3,
              //     () => setState(() {
              //           items.addAll(List.filled(5, 0));
              //           // items.add(1);
              //         }));
            } else if (atTop) {
              items = [1, 1, 1, 1, 1];
            }
            setState(() {});
            return hasMore;
          },
        ));
  }
}
