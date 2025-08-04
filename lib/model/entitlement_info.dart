import 'package:purchases_flutter/purchases_flutter.dart' show EntitlementInfo;

extension RevenueCat on EntitlementInfo {
  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'isActive': isActive,
      'willRenew': willRenew,
      'periodType': periodType.name,
      'latestPurchaseDate': latestPurchaseDate,
      'originalPurchaseDate': originalPurchaseDate,
      'expirationDate': expirationDate,
      'store': store.name,
      'productIdentifier': productIdentifier,
      'isSandbox': isSandbox,
      'unsubscribeDetectedAt': unsubscribeDetectedAt,
      'billingIssueDetectedAt': billingIssueDetectedAt,
      'ownershipType': ownershipType.name,
    };
  }
}
