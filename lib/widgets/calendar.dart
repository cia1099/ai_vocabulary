import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';

abstract interface class CalendarDelegate {
  Widget dateItemBuilder(DateTime date, double maxHeight);
  void onMonthChanged(DateTime date);
}

class Calendar extends StatefulWidget {
  final double height;
  final CalendarDelegate? delegate;
  const Calendar({super.key, this.height = 300, this.delegate});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      // constraints: BoxConstraints(
      //   minHeight: widget.height,
      //   maxHeight: widget.height * 1.05,
      // ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: PageView.builder(
        reverse: true,
        controller: pageController,
        onPageChanged: (index) {
          final now = DateTime.now();
          final date = DateTime(now.year, now.month - index, 1);
          widget.delegate?.onMonthChanged(date);
        },
        itemBuilder: (context, index) {
          final now = DateTime.now();
          final date = DateTime(now.year, now.month - index, 1);
          return buildCalendar(date.year, date.month);
        },
      ),
    );
  }

  Widget buildCalendar(int year, int month) {
    final dayList = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (year % 4 == 0) dayList[1] = 29;
    const weekday = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final isPresentMonth = (now.year - year + now.month - month) == 0;
    final offset = DateTime(year, month, 1).weekday % 7;
    final maxAnchor = dayList[month - 1] + offset - 1;
    return Column(
      children: [
        SizedBox(
          height: kTextTabBarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PlatformIconButton(
                onPressed: () => pageController.nextPage(
                  duration: Durations.medium1,
                  curve: Curves.fastOutSlowIn,
                ),
                material: (_, __) => MaterialIconButtonData(
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                padding: EdgeInsets.zero,
                icon: const Icon(CupertinoIcons.chevron_back),
              ),
              PlatformTextButton(
                onPressed: () => showPlatformModalSheet(
                  context: context,
                  builder: (context) => Container(
                    height: 216,
                    padding: const EdgeInsets.only(top: 6),
                    margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    color: CupertinoColors.systemBackground.resolveFrom(
                      context,
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.monthYear,
                      initialDateTime: DateTime(year, month),
                      maximumDate: DateTime(now.year, now.month),
                      onDateTimeChanged: (date) {
                        final index =
                            (now.year - date.year) * 12 +
                            (now.month - date.month);
                        pageController.animateToPage(
                          index,
                          duration: Durations.medium1,
                          curve: Curves.fastOutSlowIn,
                        );
                      },
                    ),
                  ),
                ),
                padding: EdgeInsets.zero,
                material: (_, __) => MaterialTextButtonData(
                  style: TextButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                child: Wrap(
                  spacing: 8,
                  children: [
                    Text(DateFormat.yMMMM().format(DateTime(year, month))),
                    const Icon(CupertinoIcons.chevron_down),
                  ],
                ),
              ),
              PlatformIconButton(
                onPressed: isPresentMonth
                    ? null
                    : () => pageController.previousPage(
                        duration: Durations.medium1,
                        curve: Curves.fastOutSlowIn,
                      ),
                material: (_, __) => MaterialIconButtonData(
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                padding: EdgeInsets.zero,
                icon: const Icon(CupertinoIcons.chevron_forward),
              ),
            ],
          ),
        ),
        Expanded(
          child: Table(
            // border: const TableBorder.symmetric(outside: BorderSide()),
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide()),
                ),
                children: weekday.map((d) => Center(child: Text(d))).toList(),
              ),
              for (var anchor = 0; anchor < maxAnchor;)
                TableRow(
                  children: List.generate(7, (_) {
                    final bodyMedium = Theme.of(context).textTheme.bodyMedium!;
                    final textHeight =
                        bodyMedium.height! * bodyMedium.fontSize!;
                    final cellHeight =
                        (widget.height - kTextTabBarHeight - textHeight) /
                        (maxAnchor / 7).ceil();
                    final cell = anchor > maxAnchor || anchor < offset
                        ? const SizedBox.shrink()
                        : Container(
                            // height: cellHeight,
                            alignment: const Alignment(0, -1),
                            constraints: BoxConstraints(maxHeight: cellHeight),
                            decoration: anchor < 7
                                ? null
                                : BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: colorScheme.outlineVariant,
                                      ),
                                    ),
                                  ),
                            child: FittedBox(
                              fit: BoxFit.none,
                              child: widget.delegate == null
                                  ? Text(
                                      '${anchor - offset + 1}',
                                      style: bodyMedium,
                                    )
                                  : widget.delegate!.dateItemBuilder(
                                      DateTime(
                                        year,
                                        month,
                                        anchor - offset + 1,
                                      ),
                                      cellHeight,
                                    ),
                            ),
                          );
                    anchor++;
                    return cell;
                  }),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
