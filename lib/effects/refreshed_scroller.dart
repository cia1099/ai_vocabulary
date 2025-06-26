import 'dart:async';

import 'package:ai_vocabulary/effects/dot2loader.dart';
import 'package:ai_vocabulary/utils/handle_except.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RefreshedScroller extends StatefulWidget {
  final double thresholdExtent;
  final ScrollController controller;
  final Widget child;
  final Future<void> Function(bool atTop) refresh;
  final Alignment? bottomAlignment, topAlignment;
  const RefreshedScroller({
    super.key,
    required this.controller,
    required this.child,
    required this.refresh,
    this.thresholdExtent = 125,
    this.bottomAlignment,
    this.topAlignment,
  });

  @override
  State<RefreshedScroller> createState() => _RefreshedScrollerState();
}

class _RefreshedScrollerState extends State<RefreshedScroller> {
  late final scrollController = widget.controller;
  final streamFuture = StreamController<Future?>();
  late final stream = streamFuture.stream.asBroadcastStream();
  _RefreshAt? refreshAt;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: widget.child),
        Align(
          alignment: widget.topAlignment ?? Alignment(0, -1),
          child: StreamBuilder(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.hasData && refreshAt == _RefreshAt.top) {
                return createLoader(snapshot.data!);
              }
              return SizedBox.shrink();
            },
          ),
        ),
        Align(
          alignment: widget.bottomAlignment ?? Alignment(0, 1),
          child: StreamBuilder(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.hasData && refreshAt == _RefreshAt.bottom) {
                return createLoader(snapshot.data!);
              }
              return SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget createLoader(Future loadFuture) {
    return FutureBuilder(
      future: loadFuture,
      builder: (context, snapshot) {
        final colorScheme = Theme.of(context).colorScheme;
        if (snapshot.hasError) {
          return Text(
            messageExceptions(snapshot.error),
            style: TextStyle(color: colorScheme.error),
          );
        }
        return TwoDotLoader();
      },
    );
  }

  void scrollNotification() {
    if (refreshAt != null) return;
    final maxExtent = scrollController.position.maxScrollExtent;
    final pixel = scrollController.position.pixels;
    if (pixel < -widget.thresholdExtent) {
      streamFuture.addStream(loading(_RefreshAt.top));
    } else if (pixel - maxExtent > widget.thresholdExtent) {
      streamFuture.addStream(loading(_RefreshAt.bottom));
    }
  }

  Stream<Future?> loading(_RefreshAt at) async* {
    refreshAt = at;
    final loadFuture = widget.refresh(at == _RefreshAt.top);
    yield loadFuture;
    //Avoid bounce to next page, I don't know why the bounce can do that
    // if (scrollController.hasClients &&
    //     scrollController.position.pixels.abs() > widget.thresholdExtent) {
    //   scrollController.position.moveTo(
    //     scrollController.offset,
    //     duration: Durations.long1,
    //     curve: Curves.bounceOut,
    //   );
    // }
    await loadFuture.then(
      (_) => Future.value(),
      onError: (_) => Future.delayed(Durations.extralong4),
    );
    yield refreshAt = null;
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(scrollNotification);
  }

  @override
  void dispose() {
    widget.controller.removeListener(scrollNotification);
    streamFuture.close();
    super.dispose();
  }
}

enum _RefreshAt { top, bottom }

void main() {
  runApp(
    CupertinoApp(
      home: CupertinoPageScaffold(child: SafeArea(child: _Example())),
    ),
  );
}

class _Example extends StatelessWidget {
  const _Example();

  @override
  Widget build(BuildContext context) {
    final controller = PageController();
    return RefreshedScroller(
      controller: controller,
      refresh: (atTop) {
        return Future.delayed(
          Durations.extralong4,
          () => throw Exception('error happen'),
        );
      },
      child: PageView.builder(
        controller: controller,
        scrollDirection: Axis.vertical,
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        itemCount: 2,
        itemBuilder: (context, index) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text("Page: $index", textScaler: TextScaler.linear(3))],
        ),
      ),
    );
  }
}
