enum RedemptionType {
  cashBack,
  travelTransfer,
  statementCredit,
  merchandise,
  portal,
}

class ValuationEntry {
  const ValuationEntry({
    required this.rewardCurrencyType,
    required this.redemptionType,
    required this.centsPerPoint,
    this.transferPartner,
    this.minPointsRequired,
  }) : assert(
          redemptionType != RedemptionType.travelTransfer ||
              transferPartner != null,
          'travelTransfer entries must specify a transferPartner',
        );

  /// Identifier matching CardSnapshot.rewardCurrencyType (e.g. "chase_ur").
  final String rewardCurrencyType;

  final RedemptionType redemptionType;

  /// Value in actual cents per point (e.g. 1.5 means 1.5¢/point).
  final double centsPerPoint;

  /// Only set when redemptionType == travelTransfer.
  final String? transferPartner;

  /// Minimum balance required to redeem via this option; null means no minimum.
  final int? minPointsRequired;
}
