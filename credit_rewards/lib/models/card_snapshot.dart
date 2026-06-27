class CardSnapshot {
  const CardSnapshot({
    required this.cardId,
    required this.issuer,
    required this.currency,
    required this.rewardCurrencyType,
    required this.balanceDue,
    required this.dueDate,
    required this.pointsBalance,
  });

  final String cardId;
  final String issuer;

  /// ISO 4217 currency code for the billing currency (e.g. "USD", "INR").
  final String currency;

  /// Joins to ValuationEntry.rewardCurrencyType (e.g. "chase_ur").
  final String rewardCurrencyType;

  final double balanceDue;
  final DateTime dueDate;
  final int pointsBalance;
}
