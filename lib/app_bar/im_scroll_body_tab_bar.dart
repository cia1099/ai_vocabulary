import 'package:flutter/material.dart';

class ImScrollBodyTabBar extends StatefulWidget {
  final List<String> tabTexts;
  final List<AssetImage> tabImages;
  final Color? color;
  final Widget? child;
  const ImScrollBodyTabBar(
      {super.key,
      required this.tabTexts,
      required this.tabImages,
      this.color,
      this.child});

  @override
  State<ImScrollBodyTabBar> createState() => _ImSliverAppBarState();
}

class _ImSliverAppBarState extends State<ImScrollBodyTabBar>
    with TickerProviderStateMixin {
  late final tabController =
      TabController(length: widget.tabTexts.length, vsync: this);
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 90,
          flexibleSpace: FlexibleSpaceBar(
            expandedTitleScale: 1,
            titlePadding: EdgeInsets.zero,
            title: Container(
              decoration: BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: Colors.grey, width: 2))),
              child: TabBar(
                // padding: EdgeInsets.zero,
                controller: tabController,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.indigoAccent,
                labelColor: Colors.indigoAccent,
                indicatorWeight: 1,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: widget.tabTexts
                    .map((e) => Tab(
                          text: e,
                        ))
                    .toList(),
              ),
            ),
            background: TabBar(
              padding: EdgeInsets.zero,
              controller: tabController,
              tabs: widget.tabImages
                  .map((e) => Container(
                        // color: Colors.green,
                        alignment: Alignment.topCenter,
                        child: Image(
                          image: e,
                          height: 50,
                        ),
                      ))
                  .toList(),
            ),
          ),
          backgroundColor: widget.color ?? Theme.of(context).primaryColor,
          foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        SliverAppBar(
          expandedHeight: 200,
          flexibleSpace: FlexibleSpaceBar(
              background: TabBarView(
            controller: tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(
                widget.tabImages.length,
                (i) => Image(
                      image: widget.tabImages[i],
                    )),
          )),
          backgroundColor:
              widget.color ?? Theme.of(context).scaffoldBackgroundColor,
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: widget.child,
        ),
      ],
    );
  }
}
