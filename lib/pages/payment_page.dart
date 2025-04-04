import 'package:ai_vocabulary/effects/pointer_down_physic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_lorem/flutter_lorem.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  Widget build(BuildContext context) {
    final textTheme = CupertinoTheme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final hPadding = MediaQuery.sizeOf(context).width / 32;
    return PlatformScaffold(
      appBar: PlatformAppBar(
        leading: GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: Icon(Icons.close),
          // child: Icon(CupertinoIcons.xmark, size: 24),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hPadding),
            child: Column(
              children: [
                Text.rich(
                  TextSpan(
                    text: 'Start improving your ',
                    children: [
                      TextSpan(
                        text: 'vocabulary',
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: textTheme.navLargeTitleTextStyle,
                ),
                benefitItems(),
                payment(),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 100,
            child: Container(
              color: colorScheme.surfaceContainer,
              padding: EdgeInsets.only(
                left: hPadding,
                right: hPadding,
                bottom: 32,
                top: 8,
              ),
              child: PlatformElevatedButton(
                onPressed: () {},
                child: Text("Continue"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget payment() {
    final textTheme = CupertinoTheme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final hPadding = MediaQuery.sizeOf(context).width / 32;
    return OnPointerDownPhysic(
      child: Card(
        shape: Border.all(width: 2, color: colorScheme.primary),
        child: Container(
          constraints: BoxConstraints.expand(height: 80),
          padding: EdgeInsets.symmetric(horizontal: hPadding),
          child: DefaultTextStyle(
            style: textTheme.textStyle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Yearly", style: textTheme.navTitleTextStyle),
                Text("\$1,050.00/year"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget benefitItems() {
    const diameter = 40.0;
    final textTheme = CupertinoTheme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final hPadding = MediaQuery.sizeOf(context).width / 32;
    return Row(
      children: [
        Container(
          width: diameter,
          height: diameter,
          decoration: ShapeDecoration(
            color: colorScheme.primaryContainer,
            shape: CircleBorder(
              side: BorderSide(width: 2, color: colorScheme.onPrimaryContainer),
            ),
          ),
          padding: EdgeInsets.all(diameter / 6),
          margin: EdgeInsets.only(right: hPadding),
          child: FittedBox(
            fit: BoxFit.fill,
            child: Icon(CupertinoIcons.lock_open),
          ),
        ),
        Expanded(
          child: Text(
            lorem(paragraphs: 1, words: 10),
            style: textTheme.textStyle,
          ),
        ),
      ],
    );
  }
}
