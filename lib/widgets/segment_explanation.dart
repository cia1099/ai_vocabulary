import 'package:ai_vocabulary/app_settings.dart';
import 'package:ai_vocabulary/pages/views/matching_word_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class SegmentExplanation extends StatefulWidget {
  const SegmentExplanation({super.key});

  @override
  State<SegmentExplanation> createState() => _SegmentExplanationState();
}

class _SegmentExplanationState extends State<SegmentExplanation> {
  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material:
          (_, __) => SegmentedButton<SelectExplanation>(
            selected: {AppSettings.of(context).defaultExplanation},
            showSelectedIcon: false,
            segments: [
              for (final value in SelectExplanation.values)
                ButtonSegment(value: value, label: Text(value.type)),
            ],
            onSelectionChanged:
                (set) => setState(() {
                  AppSettings.of(context).defaultExplanation = set.first;
                }),
          ),
      cupertino:
          (_, __) => CupertinoSegmentedControl<SelectExplanation>(
            groupValue: AppSettings.of(context).defaultExplanation,
            padding: EdgeInsets.zero,
            children: {
              for (final value in SelectExplanation.values)
                value: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(value.type),
                ),
            },
            onValueChanged:
                (value) => setState(() {
                  AppSettings.of(context).defaultExplanation = value;
                }),
          ),
    );
  }
}
