import 'package:ai_vocabulary/utils/clickable_text_mixin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InlineParagraph extends StatefulWidget {
  final Widget mark;
  final Color? markColor;
  final String paragraph;
  final TextStyle? paragraphStyle;
  const InlineParagraph({
    super.key,
    required this.mark,
    required this.paragraph,
    this.markColor,
    this.paragraphStyle,
  });

  @override
  State<InlineParagraph> createState() => _InlineParagraphState();
}

class _InlineParagraphState extends State<InlineParagraph>
    with ClickableTextStateMixin {
  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          WidgetSpan(child: widget.mark),
          TextSpan(text: "\t:\t", style: TextStyle(color: widget.markColor)),
          TextSpan(
            children: clickableWords(widget.paragraph),
            // style: textTheme.labelLarge?.copyWith(
            //   height: 1.618,
            //   // color: colorScheme.primary,
            // ),
            // style: cupTheme.textTheme.textStyle.copyWith(
            //   fontWeight: FontWeight.w500,
            // ),
            style: widget.paragraphStyle,
          ),
        ],
      ),
    );
  }
}

class BoxText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? color;
  const BoxText({super.key, required this.text, this.style, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color ?? Color(0x00000000)),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: Text(text, style: style?.apply(color: color)),
    );
  }
}
