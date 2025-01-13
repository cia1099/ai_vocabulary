import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';

class Calendar extends StatefulWidget {
  final double height;
  const Calendar({super.key, this.height = 300});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: PageView.builder(
          reverse: true,
          controller: pageController,
          itemBuilder: (context, index) {
            final now = DateTime.now();
            final date = DateTime(now.year, now.month - index, 1);
            return buildCalendar(date.year, date.month);
          }),
    );
  }

  Widget buildCalendar(int year, int month) {
    final dayList = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (year % 4 == 0) dayList[1] = 29;
    const weekday = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
    final now = DateTime.now();
    final thisMonth = now.year - year + now.month - month;
    final offset = DateTime(year, month, 1).weekday % 7;
    final maxAnchor = dayList[month - 1] + offset - 1;
    final textSize = Theme.of(context).textTheme.bodyMedium!.fontSize!;
    final cellHeight = (widget.height - kTextTabBarHeight - textSize * 2) /
        (maxAnchor / 7).ceil();
    return Column(
      children: [
        SizedBox(
          height: kTextTabBarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PlatformIconButton(
                  onPressed: () => pageController.nextPage(
                      duration: Durations.medium1, curve: Curves.fastOutSlowIn),
                  material: (_, __) => MaterialIconButtonData(
                      style: IconButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap)),
                  padding: EdgeInsets.zero,
                  icon: const Icon(CupertinoIcons.chevron_back)),
              PlatformTextButton(
                onPressed: () {
                  final now = DateTime.now();
                  showPlatformModalSheet(
                    context: context,
                    builder: (context) => Container(
                      height: 216,
                      padding: const EdgeInsets.only(top: 6),
                      margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      color:
                          CupertinoColors.systemBackground.resolveFrom(context),
                      child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.monthYear,
                          initialDateTime: DateTime(year, month),
                          maximumDate: DateTime(now.year, now.month),
                          onDateTimeChanged: (dateTime) {}),
                    ),
                  );
                },
                padding: EdgeInsets.zero,
                material: (_, __) => MaterialTextButtonData(
                    style: TextButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap)),
                child: Wrap(
                  spacing: 8,
                  children: [
                    Text(DateFormat.yMMMM().format(DateTime(year, month))),
                    const Icon(CupertinoIcons.chevron_down)
                  ],
                ),
              ),
              PlatformIconButton(
                onPressed: thisMonth == 0
                    ? null
                    : () => pageController.previousPage(
                        duration: Durations.medium1,
                        curve: Curves.fastOutSlowIn),
                material: (_, __) => MaterialIconButtonData(
                    style: IconButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap)),
                padding: EdgeInsets.zero,
                icon: const Icon(CupertinoIcons.chevron_forward),
              ),
            ],
          ),
        ),
        Table(
            // border: TableBorder.symmetric(outside: BorderSide()),
            children: [
              TableRow(
                  decoration:
                      const BoxDecoration(border: Border(bottom: BorderSide())),
                  children:
                      weekday.map((d) => Center(child: Text(d))).toList()),
              for (var anchor = 0; anchor < maxAnchor;)
                TableRow(
                    children: List.generate(7, (_) {
                  final colorScheme = Theme.of(context).colorScheme;
                  final cell = anchor > maxAnchor || anchor < offset
                      ? const SizedBox.shrink()
                      : Container(
                          constraints: BoxConstraints(minHeight: cellHeight),
                          alignment: const Alignment(0, 0),
                          decoration: anchor < 7
                              ? null
                              : BoxDecoration(
                                  border: Border(
                                      top: BorderSide(
                                  color: colorScheme.outlineVariant,
                                ))),
                          child: Text('${anchor - offset + 1}'));
                  anchor++;
                  return cell;
                })),
            ]),
      ],
    );
  }
}
