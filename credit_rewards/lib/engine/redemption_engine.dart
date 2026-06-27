import '../models/card_snapshot.dart';
import '../models/redemption_option.dart';
import '../models/valuation_entry.dart';

/// Returns redemption options for [card] ranked by total cents of value,
/// highest first. Options whose [ValuationEntry.minPointsRequired] exceeds
/// the card's current balance are excluded.
List<RedemptionOption> rankRedemptions({
  required CardSnapshot card,
  required List<ValuationEntry> valuations,
}) {
  final options = <RedemptionOption>[];

  for (final v in valuations) {
    if (v.rewardCurrencyType != card.rewardCurrencyType) continue;
    if (v.minPointsRequired != null &&
        card.pointsBalance < v.minPointsRequired!) continue;

    options.add(RedemptionOption(
      redemptionType: v.redemptionType,
      transferPartner: v.transferPartner,
      centsOfValue: card.pointsBalance * v.centsPerPoint,
    ));
  }

  options.sort((a, b) => b.centsOfValue.compareTo(a.centsOfValue));
  return options;
}
