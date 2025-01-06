import 'package:flutter/material.dart';

class IslandZoomOut extends StatefulWidget {
  const IslandZoomOut({
    super.key,
    this.duration = Durations.long2,
    this.top,
    this.bottom,
    required this.child,
    required this.stay,
  });

  final double? top, bottom;
  final Widget child;
  final Duration duration, stay;

  @override
  State<IslandZoomOut> createState() => _ShowOverlayEntryState();
}

class _ShowOverlayEntryState extends State<IslandZoomOut> {
  var show = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        show = true;
      });
      Future.delayed(widget.stay, () {
        setState(() {
          show = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final hPadding = MediaQuery.of(context).size.width / 32;
    return AnimatedPositioned(
        left: hPadding,
        right: hPadding,
        top: show ? widget.top : (widget.top != null ? -widget.top! / 2 : null),
        bottom: show
            ? widget.bottom
            : (widget.bottom != null ? -widget.bottom! / 2 : null),
        duration: widget.duration,
        curve: show ? Curves.linearToEaseOut : Curves.fastOutSlowIn,
        child: AnimatedScale(
            curve: show ? Curves.linearToEaseOut : Curves.fastOutSlowIn,
            duration: widget.duration,
            scale: show ? 1 : 0.1,
            child: widget.child));
  }
}

void showOverlay({
  required BuildContext context,
  required Widget child,
  double? top,
  double? bottom,
  Duration stay = Durations.extralong4,
}) {
  if (top == null && bottom == null) return;
  if (top != null && bottom != null) return;
  const duration = Durations.long2;
  final overlayEntry = OverlayEntry(
      // opaque: true,
      builder: (context) => IslandZoomOut(
          stay: stay,
          top: top,
          bottom: bottom,
          duration: duration,
          child: child));
  Overlay.of(context).insert(overlayEntry);
  Future.delayed(stay + duration, () {
    overlayEntry.remove();
    overlayEntry.dispose();
  });
}
