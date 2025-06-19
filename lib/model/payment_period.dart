import 'dart:convert';

class PaymentPeriod {
  final String period;
  final double price;
  final Discount? discount;
  final String currency;

  PaymentPeriod({
    required this.period,
    required this.price,
    required this.currency,
    this.discount,
  });

  factory PaymentPeriod.fromRawJson(String str) =>
      PaymentPeriod.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PaymentPeriod.fromJson(Map<String, dynamic> json) => PaymentPeriod(
    period: json["period"],
    price: json["price"],
    discount: json["discount"] == null
        ? null
        : Discount.fromJson(json["discount"]),
    currency: json["currency"],
  );

  Map<String, dynamic> toJson() => {
    "period": period,
    "price": price,
    "discount": discount?.toJson(),
    "currency": currency,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentPeriod &&
        other.period == period &&
        other.currency == currency;
  }

  @override
  int get hashCode => period.hashCode;
}

class Discount {
  final double origin;
  final double save;

  Discount({required this.origin, required this.save});

  factory Discount.fromRawJson(String str) =>
      Discount.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Discount.fromJson(Map<String, dynamic> json) =>
      Discount(origin: json["origin"], save: json["save"]);

  Map<String, dynamic> toJson() => {"origin": origin, "save": save};
}
