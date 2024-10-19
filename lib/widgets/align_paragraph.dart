import 'package:flutter/material.dart';

class AlignParagraph extends StatefulWidget {
  const AlignParagraph({
    super.key,
    required this.markWidget,
    required this.paragraph,
    required this.xInterval,
    this.paragraphStyle,
  });

  final Widget markWidget;
  final Widget paragraph;
  final double xInterval;
  final TextStyle? paragraphStyle;

  @override
  State<AlignParagraph> createState() => _AlignParagraphState();
}

class _AlignParagraphState extends State<AlignParagraph> {
  final paragraphExpanded = GlobalKey();
  double? leftSideHeight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => setState(() {
        final renderBox =
            paragraphExpanded.currentContext?.findRenderObject() as RenderBox;
        leftSideHeight = renderBox.size.height;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bodyText =
        widget.paragraphStyle ?? Theme.of(context).textTheme.bodyMedium!;
    final padding = leftSideHeight == null
        ? 0.0
        : (leftSideHeight! - bodyText.fontSize! * bodyText.height!)
            .clamp(0.0, leftSideHeight!);
    return Row(
      children: [
        Container(
          margin: EdgeInsets.only(right: widget.xInterval),
          padding: EdgeInsets.only(bottom: padding),
          child: widget.markWidget,
        ),
        Expanded(
          child: Builder(
              builder: (context) => widget.paragraph, key: paragraphExpanded),
        )
      ],
    );
  }
}
