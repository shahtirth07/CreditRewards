import 'package:flutter_test/flutter_test.dart';
import 'package:credit_rewards/engine/redemption_engine.dart';
import 'package:credit_rewards/models/card_snapshot.dart';
import 'package:credit_rewards/models/valuation_entry.dart';
import 'package:credit_rewards/data/valuation/chase_ur_valuations.dart';

void main() {
  final preferredCard = CardSnapshot(
    cardId: 'chase_sapphire_preferred_001',
    issuer: 'Chase',
    currency: 'USD',
    rewardCurrencyType: 'chase_ur_preferred',
    balanceDue: 1200.00,
    dueDate: DateTime(2026, 7, 15),
    pointsBalance: 50000,
  );

  final reserveCard = CardSnapshot(
    cardId: 'chase_sapphire_reserve_001',
    issuer: 'Chase',
    currency: 'USD',
    rewardCurrencyType: 'chase_ur_reserve',
    balanceDue: 800.00,
    dueDate: DateTime(2026, 7, 15),
    pointsBalance: 50000,
  );

  group('rankRedemptions — happy path', () {
    test('returns all eligible options sorted by centsOfValue descending', () {
      final results = rankRedemptions(
        card: preferredCard,
        valuations: chaseUrValuations,
      );

      expect(results, isNotEmpty);
      for (var i = 0; i < results.length - 1; i++) {
        expect(results[i].centsOfValue,
            greaterThanOrEqualTo(results[i + 1].centsOfValue));
      }
    });

    test('Hyatt transfer tops the ranking at 1.7 cpp', () {
      final results = rankRedemptions(
        card: preferredCard,
        valuations: chaseUrValuations,
      );

      // 50,000 * 1.7 = 85,000¢
      expect(results.first.transferPartner, 'World of Hyatt');
      expect(results.first.centsOfValue, closeTo(85000, 0.001));
    });

    test('cash back option returns correct absolute value', () {
      final results = rankRedemptions(
        card: preferredCard,
        valuations: chaseUrValuations,
      );

      final cashBack = results.firstWhere(
        (o) => o.redemptionType == RedemptionType.cashBack,
      );
      // 50,000 * 1.0 = 50,000¢
      expect(cashBack.centsOfValue, closeTo(50000, 0.001));
    });

    test('Reserve portal rate is 1.5¢ vs Preferred portal rate of 1.25¢', () {
      final preferredResults = rankRedemptions(
        card: preferredCard,
        valuations: chaseUrValuations,
      );
      final reserveResults = rankRedemptions(
        card: reserveCard,
        valuations: chaseUrValuations,
      );

      final preferredPortal = preferredResults
          .firstWhere((o) => o.redemptionType == RedemptionType.portal);
      final reservePortal = reserveResults
          .firstWhere((o) => o.redemptionType == RedemptionType.portal);

      // 50,000 * 1.25 = 62,500¢  vs  50,000 * 1.5 = 75,000¢
      expect(preferredPortal.centsOfValue, closeTo(62500, 0.001));
      expect(reservePortal.centsOfValue, closeTo(75000, 0.001));
    });

    test('Preferred card does not receive Reserve entries', () {
      final results = rankRedemptions(
        card: preferredCard,
        valuations: chaseUrValuations,
      );

      // 3 non-transfer + 4 transfer = 7 entries, all Preferred
      expect(results.length, 7);
      // Exactly one portal entry, at the Preferred rate (not 75,000¢)
      final portalValues = results
          .where((o) => o.redemptionType == RedemptionType.portal)
          .map((o) => o.centsOfValue)
          .toList();
      expect(portalValues, hasLength(1));
      expect(portalValues.first, closeTo(62500, 0.001));
    });

    test('Reserve card does not receive Preferred entries', () {
      final results = rankRedemptions(
        card: reserveCard,
        valuations: chaseUrValuations,
      );

      // 3 non-transfer + 4 transfer = 7 entries, all Reserve
      expect(results.length, 7);
      // Exactly one portal entry, at the Reserve rate (not 62,500¢)
      final portalValues = results
          .where((o) => o.redemptionType == RedemptionType.portal)
          .map((o) => o.centsOfValue)
          .toList();
      expect(portalValues, hasLength(1));
      expect(portalValues.first, closeTo(75000, 0.001));
    });
  });

  group('rankRedemptions — minPointsRequired exclusion', () {
    test('transfer options are excluded when balance is below minimum', () {
      final lowBalanceCard = CardSnapshot(
        cardId: 'chase_sapphire_preferred_002',
        issuer: 'Chase',
        currency: 'USD',
        rewardCurrencyType: 'chase_ur_preferred',
        balanceDue: 0,
        dueDate: DateTime(2026, 7, 15),
        pointsBalance: 500, // below 1,000 minimum for all transfers
      );

      final results = rankRedemptions(
        card: lowBalanceCard,
        valuations: chaseUrValuations,
      );

      final hasTransfer = results.any(
        (o) => o.redemptionType == RedemptionType.travelTransfer,
      );
      expect(hasTransfer, isFalse);
      // Cash back and statement credit should still appear
      expect(results, isNotEmpty);
    });
  });

  group('rankRedemptions — unrecognized rewardCurrencyType', () {
    test('returns empty list when no valuations match', () {
      final unknownCard = CardSnapshot(
        cardId: 'amex_mrp_001',
        issuer: 'Amex',
        currency: 'USD',
        rewardCurrencyType: 'amex_mr', // not in chaseUrValuations
        balanceDue: 0,
        dueDate: DateTime(2026, 7, 15),
        pointsBalance: 100000,
      );

      final results = rankRedemptions(
        card: unknownCard,
        valuations: chaseUrValuations,
      );

      expect(results, isEmpty);
    });
  });

  group('seed data completeness', () {
    // Every variant must have at least one entry for each of these types.
    const requiredTypes = {
      RedemptionType.cashBack,
      RedemptionType.statementCredit,
      RedemptionType.portal,
      RedemptionType.travelTransfer,
    };

    final variantLists = {
      'chase_ur_preferred': chaseUrPreferredValuations,
      'chase_ur_reserve': chaseUrReserveValuations,
    };

    for (final entry in variantLists.entries) {
      final variant = entry.key;
      final entries = entry.value;

      test('$variant has all required redemption types', () {
        final presentTypes = entries.map((v) => v.redemptionType).toSet();
        expect(
          presentTypes,
          containsAll(requiredTypes),
          reason: 'Missing types: ${requiredTypes.difference(presentTypes)}',
        );
      });

      test('all entries in $variant carry the correct rewardCurrencyType', () {
        for (final v in entries) {
          expect(v.rewardCurrencyType, variant);
        }
      });
    }
  });
}
