import '../../models/valuation_entry.dart';

// Rates are issuer-stated or widely published partner ratios.
// Verify against current Chase terms before relying on these numbers.

const List<ValuationEntry> chaseUrPreferredValuations = [
  ValuationEntry(
    rewardCurrencyType: 'chase_ur_preferred',
    redemptionType: RedemptionType.cashBack,
    centsPerPoint: 1.0,
  ),
  ValuationEntry(
    rewardCurrencyType: 'chase_ur_preferred',
    redemptionType: RedemptionType.statementCredit,
    centsPerPoint: 1.0,
  ),
  ValuationEntry(
    rewardCurrencyType: 'chase_ur_preferred',
    redemptionType: RedemptionType.portal,
    centsPerPoint: 1.25,
  ),
  ValuationEntry(
    rewardCurrencyType: 'chase_ur_preferred',
    redemptionType: RedemptionType.travelTransfer,
    transferPartner: 'World of Hyatt',
    centsPerPoint: 1.7,
    minPointsRequired: 1000,
  ),
  ValuationEntry(
    rewardCurrencyType: 'chase_ur_preferred',
    redemptionType: RedemptionType.travelTransfer,
    transferPartner: 'United MileagePlus',
    centsPerPoint: 1.3,
    minPointsRequired: 1000,
  ),
  ValuationEntry(
    rewardCurrencyType: 'chase_ur_preferred',
    redemptionType: RedemptionType.travelTransfer,
    transferPartner: 'Southwest Rapid Rewards',
    centsPerPoint: 1.5,
    minPointsRequired: 1000,
  ),
  ValuationEntry(
    rewardCurrencyType: 'chase_ur_preferred',
    redemptionType: RedemptionType.travelTransfer,
    transferPartner: 'Air Canada Aeroplan',
    centsPerPoint: 1.4,
    minPointsRequired: 1000,
  ),
];

const List<ValuationEntry> chaseUrReserveValuations = [
  ValuationEntry(
    rewardCurrencyType: 'chase_ur_reserve',
    redemptionType: RedemptionType.cashBack,
    centsPerPoint: 1.0,
  ),
  ValuationEntry(
    rewardCurrencyType: 'chase_ur_reserve',
    redemptionType: RedemptionType.statementCredit,
    centsPerPoint: 1.0,
  ),
  // Reserve gets 1.5¢ on the Chase Travel portal vs Preferred's 1.25¢
  ValuationEntry(
    rewardCurrencyType: 'chase_ur_reserve',
    redemptionType: RedemptionType.portal,
    centsPerPoint: 1.5,
  ),
  ValuationEntry(
    rewardCurrencyType: 'chase_ur_reserve',
    redemptionType: RedemptionType.travelTransfer,
    transferPartner: 'World of Hyatt',
    centsPerPoint: 1.7,
    minPointsRequired: 1000,
  ),
  ValuationEntry(
    rewardCurrencyType: 'chase_ur_reserve',
    redemptionType: RedemptionType.travelTransfer,
    transferPartner: 'United MileagePlus',
    centsPerPoint: 1.3,
    minPointsRequired: 1000,
  ),
  ValuationEntry(
    rewardCurrencyType: 'chase_ur_reserve',
    redemptionType: RedemptionType.travelTransfer,
    transferPartner: 'Southwest Rapid Rewards',
    centsPerPoint: 1.5,
    minPointsRequired: 1000,
  ),
  ValuationEntry(
    rewardCurrencyType: 'chase_ur_reserve',
    redemptionType: RedemptionType.travelTransfer,
    transferPartner: 'Air Canada Aeroplan',
    centsPerPoint: 1.4,
    minPointsRequired: 1000,
  ),
];

/// Combined table passed to the engine. The engine filters by
/// CardSnapshot.rewardCurrencyType, so both variants can coexist here.
const List<ValuationEntry> chaseUrValuations = [
  ...chaseUrPreferredValuations,
  ...chaseUrReserveValuations,
];
