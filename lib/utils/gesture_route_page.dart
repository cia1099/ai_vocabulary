import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class GestureRoutePage extends StatefulWidget {
  const GestureRoutePage(
      {super.key,
      required this.primaryPage,
      required this.newPage,
      this.draggable = true});

  final Widget primaryPage;
  final Widget newPage;
  final bool draggable;

  @override
  State<GestureRoutePage> createState() => _GestureRoutePageState();
}

class _GestureRoutePageState extends State<GestureRoutePage>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );
  final offsetTween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: widget.draggable ? handleDragUpdate : null,
      onHorizontalDragEnd: handleDragEnd,
      child: Stack(
        children: [
          widget.primaryPage,
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final page = _controller.isDismissed ? child! : widget.newPage;
              return FractionalTranslation(
                translation: offsetTween.evaluate(_controller),
                child: AnimatedSwitcher(
                    key: ObjectKey(page),
                    duration: Durations.short2,
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: page),
              );
            },
            child: Scaffold(
              appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: PlatformAppBar(
                    cupertino: (_, __) => CupertinoNavigationBarData(
                        transitionBetweenRoutes: false),
                  )),
              backgroundColor: Colors.green,
              body: const Center(
                child: Text(
                  'This is the new page!',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void handleDragUpdate(DragUpdateDetails details) {
    // Update the controller's value based on the drag position
    final dx = details.primaryDelta! / MediaQuery.of(context).size.width;
    _controller.value -= dx;
  }

  void handleDragEnd(DragEndDetails details) {
    if (_controller.value > 0.5) {
      // Complete the transition
      Navigator.of(context).push(createRoute()).then((_) {
        _controller.animateBack(.0);
      });
    } else {
      // Revert the transition
      _controller.reverse();
    }
  }

  Route createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget.newPage,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = offsetTween.chain(CurveTween(curve: Curves.ease));

        final offsetAnimation = !animation.isForwardOrCompleted
            ? animation.drive(tween)
            : (_controller..forward()).drive(tween);
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
