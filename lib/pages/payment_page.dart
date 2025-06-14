import 'dart:convert';

import 'package:ai_vocabulary/api/dict_api.dart';
import 'package:ai_vocabulary/effects/pointer_down_physic.dart';
import 'package:ai_vocabulary/utils/function.dart';
import 'package:ai_vocabulary/utils/handle_except.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../model/payment_period.dart' show PaymentPeriod;
import '../widgets/revolve_mock_deal.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
  static const benefits = [
    BenefitItem(
      benefit:
          "Learn unlimit speech, translation, and extra 200 tokens for chatting with AI assistance",
      icon: Icons.lock_open,
      color: Color(0xFF6C91F7),
    ),
    BenefitItem(
      benefit: "Enable the localization explanation for the word",
      icon: Icons.location_pin,
      color: Color(0xFFD58F44),
    ),
    BenefitItem(
      benefit:
          // "Get extra 100 quota for visualizing example sentence to image everyday",
          "Get extra 200 tokens for visualizing example sentence to image everyday",
      icon: CupertinoIcons.photo,
      color: Color(0xFF90DFC1),
    ),
    BenefitItem(
      benefit:
          "Back up your learning to cloud server. The journey is never lost.",
      icon: Icons.local_library,
      color: Color(0xFFFBF1DF),
    ),
    BenefitItem(
      benefit: "No ads to bother you",
      icon: Icons.do_disturb,
      color: Color(0xFFEE7B71),
    ),
  ];
}

class _PaymentPageState extends State<PaymentPage> {
  PaymentPeriod? selectedPeriod;
  late var futurePrices =
      getPayments(Localizations.localeOf(context).toLanguageTag()).then((
        res,
      ) async {
        final offers = await Purchases.getOfferings();
        print(offers.toString());
        return res;
      });

  @override
  Widget build(BuildContext context) {
    final textTheme = CupertinoTheme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final hPadding = MediaQuery.sizeOf(context).width / 32;
    return PlatformScaffold(
      appBar: PlatformAppBar(
        backgroundColor: colorScheme.surface,
        leading: GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: Icon(Icons.close),
          // child: Icon(CupertinoIcons.xmark, size: 24),
        ),
        title: RevolveMockDeal(),
        cupertino: (_, __) => CupertinoNavigationBarData(border: Border()),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(hPadding),
            child: Column(
              spacing: hPadding * 2,
              // crossAxisAlignment: CrossAxisAlignment.start,
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
                Wrap(
                  runSpacing: hPadding,
                  children: [
                    ...PaymentPage.benefits.map((b) => benefitItems(b)),
                  ],
                ),
                FutureBuilder(
                  future: futurePrices,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator.adaptive();
                    }
                    if (snapshot.hasError) {
                      return Text(
                        messageExceptions(snapshot.error),
                        style: TextStyle(color: colorScheme.error),
                      );
                    }
                    final payments = List<PaymentPeriod>.from(
                      jsonDecode(
                        snapshot.data!.content,
                      ).map((map) => PaymentPeriod.fromJson(map)),
                    );
                    return Wrap(
                      children: [
                        ...payments.map(
                          (p) => GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedPeriod = p;
                              });
                            },
                            child: Payment(
                              period: p,
                              isSelect: selectedPeriod == p,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
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
                onPressed: selectedPeriod != null ? paymentProcess : null,
                child: Text(
                  "${selectedPeriod?.currencyPrice(Localizations.localeOf(context)) ?? ""} Continue",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void paymentProcess() {
    //TODO: integrate revenue cat
  }

  Widget benefitItems(BenefitItem benefit) {
    const diameter = 40.0;
    final textTheme = CupertinoTheme.of(context).textTheme;
    final hPadding = MediaQuery.sizeOf(context).width / 32;
    final color = HSVColor.fromColor(benefit.color);
    final value = (color.value / 2).clamp(.0, 1.0);
    final bgColor = color.withSaturation(value);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPadding * 3),
      child: Row(
        children: [
          Container(
            width: diameter,
            height: diameter,
            decoration: ShapeDecoration(
              color: bgColor.toColor(),
              shape: CircleBorder(
                side: BorderSide(
                  width: 4,
                  color:
                      textTheme.textStyle.color?.withValues(alpha: .4) ??
                      Color(0x00000000),
                ),
              ),
            ),
            padding: EdgeInsets.all(diameter / 8),
            margin: EdgeInsets.only(right: hPadding),
            child: FittedBox(
              fit: BoxFit.fill,
              child: Icon(
                benefit.icon,
                color: textTheme.textStyle.color?.withValues(alpha: .7),
              ),
            ),
          ),
          Expanded(child: Text(benefit.benefit, style: textTheme.textStyle)),
        ],
      ),
    );
  }
}

class Payment extends StatelessWidget {
  const Payment({super.key, this.isSelect = false, required this.period});
  final bool isSelect;
  final PaymentPeriod period;

  @override
  Widget build(BuildContext context) {
    final textTheme = CupertinoTheme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final hPadding = MediaQuery.sizeOf(context).width / 32;
    final locale = Localizations.localeOf(context);
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
                    Text(period.pricePerPeriod(locale)),
                    if (period.monthPrice(locale) != null)
                      Text(
                        period.monthPrice(locale)!,
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

class BenefitItem {
  final String benefit;
  final IconData icon;
  final Color color;
  const BenefitItem({
    required this.benefit,
    required this.icon,
    this.color = const Color(0x00000000),
  });
}

extension PaymentPeriodExt on PaymentPeriod {
  String get title => "${period.capitalize()}ly";
  String pricePerPeriod(Locale locale) =>
      "${NumberFormat.simpleCurrency(locale: locale.toLanguageTag()).format(price)}/$period";
  String? monthPrice(Locale locale) {
    if (period != "year") return null;
    return "${NumberFormat.simpleCurrency(locale: locale.toLanguageTag()).format(price / 12)}/month";
  }

  String? get subtitle {
    if (discount == null) return null;
    final original = NumberFormat.simpleCurrency(
      locale: locale,
      decimalDigits: 0,
    ).format(discount!.origin);
    final save = (discount!.save * 1e2).toStringAsFixed(0);
    return "Original $original, save $save%";
  }

  String currencyPrice(Locale locale) =>
      NumberFormat.simpleCurrency(locale: locale.toLanguageTag()).format(price);
}
