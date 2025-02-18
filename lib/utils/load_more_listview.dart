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
    this.onLoadDone,
  });
  final int itemCount;
  final Widget? Function(BuildContext context, int index) itemBuilder;
  final ScrollController? controller;
  final Widget? indicator;
  final double thresholdExtent;
  final Future<T> Function(bool atTop)? onLoadMore;
  final VoidCallback? onLoadDone;

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
        await loadFuture;
      },
      onStatusChange: (status) {
        if (status == RefreshIndicatorStatus.done) {
          if (refreshIndex > 0) {
            loadFuture?.then((hasMore) {
              if (hasMore! || hasMore == false) {
                return Future.delayed(Durations.extralong4, () => hasMore);
              }
              return hasMore;
            }).whenComplete(() {
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
          loadFuture = null;
          Future.delayed(Durations.extralong4, widget.onLoadDone);
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
                return Offstage(
                    offstage: offstage,
                    child: FutureBuilder(
                      initialData: false,
                      future: loadFuture,
                      builder: (context, snapshot) {
                        // if (snapshot.data == true) {
                        //   WidgetsBinding.instance.addPostFrameCallback((_) {
                        //     widget.onLoadDone?.call();
                        //   });
                        // }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child: widget.indicator ??
                                  const CircularProgressIndicator.adaptive());
                        }
                        // loadFuture = null;
                        return Center(
                            child: snapshot.connectionState ==
                                        ConnectionState.done &&
                                    snapshot.data == false
                                ? Text('No more data',
                                    style:
                                        TextStyle(color: colorScheme.outline))
                                : null);
                      },
                    ));
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
    final visibleH = scrollController.position.extentTotal -
        scrollController.position.extentInside;
    // print(
    //     'total = ${scrollController.position.extentTotal}, inside = ${scrollController.position.extentInside}');
    // print('Before = ${scrollController.position.extentBefore}');
    // print('After = ${scrollController.position.extentAfter}');
    if (scrollController.position.extentAfter > 1e-2 &&
        visibleH > widget.thresholdExtent) {
      refreshKey.currentState?.show();
      refreshIndex = 0;
    } else if (scrollController.position.extentBefore > 1e-2 &&
        visibleH > widget.thresholdExtent) {
      refreshKey.currentState?.show(atTop: false);
      refreshIndex = 1;
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollNotification);
    super.dispose();
  }
}
