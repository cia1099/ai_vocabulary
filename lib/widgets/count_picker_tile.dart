import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../app_settings.dart';
import '../utils/shortcut.dart';

class CountPickerTile extends StatelessWidget {
  const CountPickerTile({
    super.key,
    required this.titlePattern,
    required this.initialCount,
    this.onPickDone,
  });
  final String titlePattern;
  final int initialCount;
  final void Function(int count)? onPickDone;

  @override
  Widget build(BuildContext context) {
    final picker = ValueNotifier(initialCount ~/ 5 - 1);
    final titles = titlePattern.split(',');
    return PlatformListTile(
      onTap: () {
        final box = context.findRenderObject() as RenderBox?;
        final anchor = box?.localToGlobal(Offset.zero);
        if (anchor == null || box == null) return;
        final width = box.size.width / 2;
        final rect = Rect.fromLTWH(
            box.size.width / 2 - width / 2, anchor.dy - 20, width, 56 * 1.5);
        showPickUp(context, rect, picker);
      },
      title: Text.rich(TextSpan(children: [
        for (final text in titles)
          text != '?'
              ? TextSpan(text: text)
              : WidgetSpan(
                  child: ValueListenableBuilder(
                    valueListenable: picker,
                    builder: (context, value, _) => Text('${5 * (value + 1)}',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                )
      ])),
      trailing: Icon(
        CupertinoIcons.chevron_down,
        size: CupertinoTheme.of(context).textTheme.textStyle.fontSize,
        color: CupertinoColors.systemGrey2.resolveFrom(context),
      ),
    );
  }

  void showPickUp(BuildContext context, Rect rect, ValueNotifier<int> picker,
      [MySettings? setting]) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Stack(
          children: [
            Positioned.fromRect(
              rect: rect,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: kCupertinoSheetColor.resolveFrom(context),
                  borderRadius:
                      BorderRadius.circular(kRadialReactionRadius / 2),
                ),
                child: CupertinoPicker.builder(
                  itemExtent: 32,
                  scrollController:
                      FixedExtentScrollController(initialItem: picker.value),
                  onSelectedItemChanged: (value) => picker.value = value,
                  itemBuilder: (context, index) => Text('${5 * (index + 1)}'),
                  childCount: 40,
                ),
              ),
            ),
          ],
        );
      },
    ).then((_) => onPickDone?.call((picker.value + 1) * 5));
  }
}

void main() {
  runApp(MaterialApp(
    theme: ThemeData.light(),
    home: const Scaffold(body: Center(child: MyApp())),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 20,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'This is a Stateless widget, we need use explicit StatefulBuilder to build twice and then get RenderBox information',
            textScaler: TextScaler.linear(1.4),
          ),
        ),
        StatefulBuilder(
          builder: (context, setState) {
            final box = context.findRenderObject() as RenderBox?;
            final anchor = box?.localToGlobal(Offset.zero);
            Rect? rect;
            if (anchor != null && box != null) {
              final width = box.size.width / 2;
              rect = Rect.fromLTWH(box.size.width / 2 - width / 2,
                  anchor.dy - 20, width, 56 * 1.5);
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {});
              });
            }
            print('rect = $rect');
            return Text(rect.toString());
          },
        )
      ],
    );
  }
}
