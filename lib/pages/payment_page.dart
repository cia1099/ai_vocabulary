import 'package:ai_vocabulary/api/dict_api.dart' show updateSubscript;
import 'package:ai_vocabulary/provider/user_provider.dart';
import 'package:ai_vocabulary/utils/function.dart';
import 'package:ai_vocabulary/utils/handle_except.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../model/payment_period.dart' show PaymentPeriod;
import '../widgets/payment.dart';
import '../widgets/revolve_mock_deal.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
  static const benefits = [
    _BenefitItem(
      benefit:
          "Learn unlimit speech, translation, and extra 200 tokens for chatting with AI assistance",
      icon: Icons.lock_open,
      color: Color(0xFF6C91F7),
    ),
    _BenefitItem(
      benefit: "Enable the localization explanation for the word",
      icon: Icons.location_pin,
      color: Color(0xFFD58F44),
    ),
    _BenefitItem(
      benefit:
          // "Get extra 100 quota for visualizing example sentence to image everyday",
          "Get extra 200 tokens for visualizing example sentence to image everyday",
      icon: CupertinoIcons.photo,
      color: Color(0xFF90DFC1),
    ),
    _BenefitItem(
      benefit:
          "Back up your learning to cloud server. The journey is never lost.",
      icon: Icons.local_library,
      color: Color(0xFFFBF1DF),
    ),
    _BenefitItem(
      benefit: "No ads to bother you",
      icon: Icons.do_disturb,
      color: Color(0xFFEE7B71),
    ),
  ];
}

class _PaymentPageState extends State<PaymentPage> {
  Package? packageToPurchase;
  late final futurePrices = getPayments();
  late final List<Package> packages;

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
                    final payments = snapshot.data!;
                    return Wrap(
                      children: [
                        for (var i = 0; i < payments.length; i++)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                packageToPurchase = packages[i];
                              });
                            },
                            child: Payment(
                              period: payments[i],
                              isSelect: packageToPurchase == packages[i],
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
                onPressed: packageToPurchase != null ? paymentProcess : null,
                child: Text(
                  "${packageToPurchase?.storeProduct.priceString ?? ""} Continue",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void paymentProcess() async {
    if (packageToPurchase == null) return;
    final customerInfo = await Purchases.purchasePackage(packageToPurchase!);
    final info = customerInfo.entitlements.active.values.firstOrNull?.toJson()
      ?..addAll({"gas": 200.0});
    final user = await updateSubscript(info ?? {});
    UserProvider().currentUser = user;
    if (mounted) Navigator.maybePop(context);
  }

  Future<List<PaymentPeriod>> getPayments() async {
    final offers = await Purchases.getOfferings();
    packages = offers.current?.availablePackages ?? [];
    final monthlyPrice =
        packages
            .firstWhereOrNull((p) => p.packageType == PackageType.monthly)
            ?.storeProduct
            .price ??
        .0;
    final payments = <Map<String, dynamic>>[];
    for (final package in packages) {
      final product = package.storeProduct;
      final period = switch (package.packageType) {
        PackageType.monthly => "month",
        PackageType.annual => "year",
        _ => "day",
      };
      Map<String, dynamic>? discount;
      if (package.packageType != PackageType.monthly) {
        final months = iso8601DurationToMonths(product.subscriptionPeriod!);
        final origin = monthlyPrice * months;
        final save = (origin - product.price) / origin;
        discount = {"origin": origin, "save": save};
      }
      payments.add({
        "period": period,
        "price": product.price,
        "currency": product.currencyCode,
        "discount": discount,
      });
    }
    return payments.map((p) => PaymentPeriod.fromJson(p)).toList();
  }

  Widget benefitItems(_BenefitItem benefit) {
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

class _BenefitItem {
  final String benefit;
  final IconData icon;
  final Color color;
  const _BenefitItem({
    required this.benefit,
    required this.icon,
    this.color = const Color(0x00000000),
  });
}
