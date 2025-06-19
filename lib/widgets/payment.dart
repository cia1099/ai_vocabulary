import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../effects/pointer_down_physic.dart';
import '../model/payment_period.dart';
import '../utils/function.dart';

class Payment extends StatelessWidget {
  const Payment({super.key, this.isSelect = false, required this.period});
  final bool isSelect;
  final PaymentPeriod period;

  @override
  Widget build(BuildContext context) {
    final textTheme = CupertinoTheme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final hPadding = MediaQuery.sizeOf(context).width / 32;
    // final locale = Localizations.localeOf(context);
    return OnPointerDownPhysic(
      child: Card(
        shape: isSelect
            ? Border.all(width: 2, color: colorScheme.primary)
            : null,
        child: Container(
          constraints: BoxConstraints.expand(height: 80),
          padding: EdgeInsets.symmetric(horizontal: hPadding),
          child: DefaultTextStyle(
            style: textTheme.textStyle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(period.title, style: textTheme.navTitleTextStyle),
                    if (period.discount != null)
                      Text.rich(
                        TextSpan(
                          children: [
                            for (final entry
                                in period.subtitle!.split(', ').asMap().entries)
                              TextSpan(
                                children: [
                                  if (entry.key > 0) TextSpan(text: ", "),
                                  TextSpan(
                                    text: entry.value,
                                    style: TextStyle(
                                      decoration: entry.key == 0
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: entry.key == 1
                                          ? colorScheme.primary
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        textScaler: TextScaler.linear(.9),
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(period.pricePerPeriod),
                    if (period.monthPrice != null)
                      Text(
                        period.monthPrice!,
                        textScaler: TextScaler.linear(.9),
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension PaymentPeriodExt on PaymentPeriod {
  String get title => "${period.capitalize()}ly";
  String get pricePerPeriod =>
      "${NumberFormat.simpleCurrency(name: currency).format(price)}/$period";
  String? get monthPrice {
    if (period != "year") return null;
    return "${NumberFormat.simpleCurrency(name: currency).format(price / 12)}/month";
  }

  String? get subtitle {
    if (discount == null) return null;
    final original = NumberFormat.simpleCurrency(
      name: currency,
      decimalDigits: 0,
    ).format(discount!.origin);
    final save = (discount!.save * 1e2).toStringAsFixed(0);
    return "Original $original, save $save%";
  }
}
