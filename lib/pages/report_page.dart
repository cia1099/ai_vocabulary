import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key, required this.word});
  final Vocabulary word;

  @override
  Widget build(BuildContext context) {
    final selectIndex = <int>{};
    final enableSubmit = ValueNotifier(selectIndex.isNotEmpty);
    void toggleSelection(int value) {
      if (!selectIndex.add(value)) selectIndex.remove(value);
      enableSubmit.value = selectIndex.isNotEmpty;
    }

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final hPadding = MediaQuery.of(context).size.width / 16;
    return PlatformScaffold(
      appBar: PlatformAppBar(title: const Text('Report Issue')),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(hPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.word,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'select which issue case',
                    style: textTheme.titleLarge?.apply(
                      color: colorScheme.error,
                    ),
                  ),
                  CupertinoListSection(
                    header: Text(
                      "Definition issue",
                      style: textTheme.titleMedium,
                    ),
                    children: [
                      PlatformListTile(
                        title: const Text('Wrong part of speech'),
                        leading: RadioButton(value: 0, onTap: toggleSelection),
                      ),
                      PlatformListTile(
                        title: const Text('Wrong phonetic'),
                        leading: RadioButton(value: 1, onTap: toggleSelection),
                      ),
                      PlatformListTile(
                        title: const Text('Wrong inflection'),
                        leading: RadioButton(value: 2, onTap: toggleSelection),
                      ),
                      PlatformListTile(
                        title: const Text('Wrong definition'),
                        leading: RadioButton(value: 3, onTap: toggleSelection),
                      ),
                      PlatformListTile(
                        title: const Text('Wrong translation'),
                        leading: RadioButton(value: 4, onTap: toggleSelection),
                      ),
                    ],
                  ),
                  CupertinoListSection(
                    header: Text("Example issue", style: textTheme.titleMedium),
                    children: [
                      PlatformListTile(
                        title: const Text('Wrong asset'),
                        leading: RadioButton(value: 5, onTap: toggleSelection),
                      ),
                      PlatformListTile(
                        title: const Text('Wrong translation'),
                        leading: RadioButton(value: 6, onTap: toggleSelection),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ValueListenableBuilder(
                valueListenable: enableSubmit,
                builder:
                    (context, value, child) => PlatformElevatedButton(
                      onPressed:
                          value
                              ? () {
                                Navigator.of(context)
                                  ..pop()
                                  ..maybePop();
                              }
                              : null,
                      child: const Text("Submit"),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RadioButton extends StatefulWidget {
  const RadioButton({super.key, required this.value, this.onTap});
  final int value;
  final void Function(int value)? onTap;

  @override
  State<RadioButton> createState() => _RadioButtonState();
}

class _RadioButtonState extends State<RadioButton> {
  var selected = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => setState(() {
            selected ^= true;
            widget.onTap?.call(widget.value);
          }),
      child:
          selected
              ? const Icon(
                CupertinoIcons.smallcircle_fill_circle_fill,
                size: kRadialReactionRadius,
              )
              : const Icon(CupertinoIcons.circle, size: kRadialReactionRadius),
    );
  }
}
