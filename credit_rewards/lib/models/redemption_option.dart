import 'valuation_entry.dart';

class RedemptionOption {
  const RedemptionOption({
    required this.redemptionType,
    required this.centsOfValue,
    this.transferPartner,
  });

  final RedemptionType redemptionType;

  /// Only set when redemptionType == travelTransfer.
  final String? transferPartner;

  /// Total cents of value: pointsBalance * centsPerPoint.
  final double centsOfValue;
}
