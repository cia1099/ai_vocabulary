import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:vector_math/vector_math.dart';

import '../app_settings.dart';
import '../utils/shortcut.dart';

class CountPickerTile extends StatelessWidget {
  const CountPickerTile({
    super.key,
    required this.titlePattern,
    required this.initialCount,
    required this.itemText,
    this.itemCount,
    this.onPickDone,
    this.transform,
  });

  final String titlePattern;
  final int initialCount;
  final int? itemCount;
  final Matrix2? transform;
  final String Function(int index, int value) itemText;
  final void Function(int count)? onPickDone;

  @override
  Widget build(BuildContext context) {
    final A = transform ?? Matrix2.identity();
    final invA = A.clone()..invert();
    final picker = ValueNotifier<int>(
      (invA * Vector2(initialCount.toDouble(), 1)).x.toInt(),
    );
    final titles = titlePattern.split(',');
    return PlatformListTile(
      onTap: () {
        final box = context.findRenderObject() as RenderBox?;
        final anchor = box?.localToGlobal(Offset.zero);
        if (anchor == null || box == null) return;
        final width = box.size.width / 2;
        final rect = Rect.fromLTWH(
          box.size.width / 2 - width / 2,
          anchor.dy - 20,
          width,
          56 * 1.5,
        );
        showPickUp(context, rect, picker);
      },
      title: Text.rich(
        TextSpan(
          children: [
            for (final text in titles)
              text != '?'
                  ? TextSpan(text: text)
                  : WidgetSpan(
                    child: ValueListenableBuilder(
                      valueListenable: picker,
                      builder:
                          (context, value, _) => Text(
                            itemText(
                              value,
                              (A * Vector2(value.toDouble(), 1)).x.toInt(),
                            ),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                    ),
                  ),
          ],
        ),
      ),
      trailing: Icon(
        CupertinoIcons.chevron_down,
        size: CupertinoTheme.of(context).textTheme.textStyle.fontSize,
        color: CupertinoColors.systemGrey2.resolveFrom(context),
      ),
    );
  }

  void showPickUp(
    BuildContext context,
    Rect rect,
    ValueNotifier<int> picker, [
    MySettings? setting,
  ]) {
    final A = transform ?? Matrix2.identity();
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
                  borderRadius: BorderRadius.circular(
                    kRadialReactionRadius / 2,
                  ),
                ),
                child: CupertinoPicker.builder(
                  itemExtent: 32,
                  scrollController: FixedExtentScrollController(
                    initialItem: picker.value,
                  ),
                  onSelectedItemChanged: (value) => picker.value = value,
                  itemBuilder:
                      (context, index) => Text(
                        itemText(
                          index,
                          (A * Vector2(index.toDouble(), 1)).x.toInt(),
                        ),
                      ),
                  childCount: itemCount,
                ),
              ),
            ),
          ],
        );
      },
    ).then(
      (_) =>
          onPickDone?.call((A * Vector2(picker.value.toDouble(), 1)).x.toInt()),
    );
  }
}

void main() {
  runApp(
    MaterialApp(theme: ThemeData.light(), home: const Scaffold(body: MyApp())),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 20,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Look below Text Rect',
            textScaler: TextScaler.linear(1.4),
          ),
        ),
        Builder(
          builder: (context) {
            final box = context.findRenderObject() as RenderBox?;
            final anchor = box?.localToGlobal(Offset.zero);
            Rect? rect;
            if (anchor != null && box != null) {
              rect = Rect.fromLTWH(
                anchor.dx,
                anchor.dy,
                box.size.width,
                box.size.height,
              );
            }
            return Text(
              'Last renderBox = (${rect?.topLeft.dx}, ${rect?.topLeft.dy}, ${rect?.width}, ${rect?.height})',
            );
          },
        ),
        ElevatedButton(
          onPressed: () => setState(() {}),
          child: const Text('setState'),
        ),
      ],
    );
  }
}
