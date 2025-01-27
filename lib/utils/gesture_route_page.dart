import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class GestureRoutePage extends StatefulWidget {
  const GestureRoutePage(
      {super.key,
      required this.child,
      required this.pushPage,
      this.routeName,
      this.draggable = true});

  final Widget child;
  final Widget pushPage;
  final String? routeName;
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
          widget.child,
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final opacity = 4 * _controller.value.clamp(.0, .25);
              return FractionalTranslation(
                  translation: offsetTween.evaluate(_controller),
                  child: Stack(
                    children: [
                      Opacity(
                        opacity: opacity,
                        child: widget.pushPage,
                      ),
                      Opacity(opacity: 1 - opacity, child: child),
                    ],
                  ));
            },
            child: PlatformScaffold(
              appBar: PlatformAppBar(
                title: const Text('Cloze Quiz'),
                cupertino: (_, __) =>
                    CupertinoNavigationBarData(transitionBetweenRoutes: false),
              ),
              body: const Center(
                child: Text(
                  'This is the cloze page!',
                  style: TextStyle(fontSize: 24),
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
      pageBuilder: (context, animation, secondaryAnimation) => widget.pushPage,
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
      settings: RouteSettings(name: widget.routeName),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
