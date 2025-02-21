import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AlignParagraph extends StatelessWidget {
  const AlignParagraph({
    super.key,
    required this.paragraph,
    this.mark,
    this.xInterval,
    this.paragraphStyle,
  });

  factory AlignParagraph.text({
    required String paragraph,
    required Widget mark,
    required double xInterval,
    TextStyle? paragraphStyle,
  }) =>
      AlignParagraph(
        mark: mark,
        paragraph: Text(paragraph, style: paragraphStyle),
        xInterval: xInterval,
        paragraphStyle: paragraphStyle,
      );

  final Widget? mark;
  final Widget paragraph;
  final double? xInterval;
  final TextStyle? paragraphStyle;

  @override
  Widget build(BuildContext context) {
    final bodyText = paragraphStyle ?? Theme.of(context).textTheme.bodyMedium;
    // CupertinoTheme.of(context).textTheme.textStyle; //CupertinoTextStyle don't has height
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          // color: Colors.red,
          alignment: const Alignment(0, 0),
          height: bodyText?.fontSize.scale(bodyText.height),
          // constraints: BoxConstraints(
          //     minHeight: bodyText?.fontSize.scale(bodyText.height) ?? .0),
          margin: EdgeInsets.only(right: xInterval ?? .0),
          child: mark,
        ),
        Expanded(
          child: paragraph,
        )
      ],
    );
  }
}

void main() {
  runApp(CupertinoApp(
    theme: const CupertinoThemeData(brightness: Brightness.light),
    home: CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Align Example'),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 16,
        children: [
          AlignParagraph(
              mark: const Text('n.'),
              //   const Icon(
              // CupertinoIcons.circle_fill,
              // size: 8,
              // ),
              paragraph: Text('11' * 100),
              xInterval: 4),
        ],
      ),
    ),
  ));
}
