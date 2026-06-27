# Project: Card Rewards & Points Optimizer App

## What this app does
A personal app, inspired by Max Rewards (view card offers and rewards) and
CRED (bill pay UX), that helps the user track credit cards across banks,
compare rewards, get a chat interface for goals like "get me a free flight
from XYZ," and decide how to best redeem points. Open source, runs locally
on the user's own devices, no backend server.

## Scope (v1) — read this before suggesting anything bigger
- Cross platform: Flutter, targeting iOS and Android (APK export). NOT a
  web app.
- Countries: design for USA and India, but build ONE bank end to end
  before adding a second. Do not start two banks in parallel.
- Data source: read card data via a webview session AFTER the user logs
  into their bank's own real site inside the app. Never capture, store,
  or transmit the user's bank password. The password should never touch
  app code or storage — the user types it directly into the bank's own
  login page rendered in the webview. App code only runs read only JS
  against the DOM after authentication completes.
- Payment feature is Tier 1 ONLY: show due dates and balances, recommend
  what to pay, and deep link out to the bank's own app or site for the
  actual payment action. The app itself never initiates a real money
  transfer. This is a firm boundary, not a "for now" placeholder — if it
  comes up again, treat it as a deliberate scope change to discuss, not
  a default next step.
- Points logic is two distinct engines sharing one valuation table (see
  Engines section below). Build both with hand entered real data first;
  neither depends on the webview reader working.
- Chat/goal layer (e.g. "get me a free flight from XYZ") is additive, on
  top of the engines, built last. See Chat layer guardrails below before
  touching this.

## Architecture
- Country selector → filters which banks are shown as addable
- Each bank = one independent reader/scraper module + parser for that
  bank's offers/rewards page
- A user can add multiple cards from the same country/bank list
- Both engines read across all added cards' data for comparisons

### Tech stack and structure
```
lib/
  models/        # Card, RewardOption, ValuationEntry, EarnRate, FlightGoal
  data/
    local_store/ # sqlite (sqflite or drift) - see hot/cold split below
    valuation/   # hand maintained JSON/sqlite table of issuer stated rates
  readers/
    base_reader.dart   # abstract interface every bank reader implements
    chase_reader.dart  # webview controller + DOM parser for Chase
    hdfc_reader.dart   # same shape, different parsing rules
  engine/
    redemption_engine.dart  # pure functions, no IO
    best_card_engine.dart   # pure functions, no IO
  chat/
    intent_extractor.dart   # LLM call, strict JSON schema in/out only
  ui/
    country_select/
    card_list/
    recommendation/
    chat/
```

### Bank reader contract
```dart
abstract class BankReader {
  String get bankId;
  Future<WebViewSession> startLogin(BuildContext context);
  Future<CardSnapshot> readSnapshot(WebViewSession session);
}
```
`startLogin` shows the bank's real login URL in a webview — app code never
touches the form fields. `readSnapshot` runs read only JS against the DOM
after auth completes to extract balance/points/offers for that bank's
specific page structure.

### Data models (core fields, not exhaustive)
```dart
class CardSnapshot {
  String cardId, issuer, currency, rewardCurrencyType;
  double balanceDue; DateTime dueDate; int pointsBalance;
}
class ValuationEntry {
  String rewardCurrencyType, redemptionType; // cash_back, travel_transfer, statement_credit
  double centsPerPoint; String? transferPartner;
}
class EarnRate {
  String cardId, category; double multiplier; double? categoryCapUsd;
}
```

## Engines (two, sharing one valuation table)
1. **Redemption engine** — "what's the best use of points I already have."
   Input: a card's point balance. Output: ranked redemption options by
   actual cents of value, using `ValuationEntry`.
2. **Best card engine** — "which card should I use for this purchase."
   Input: a merchant category. Output: ranked cards by cents earned per
   dollar spent, using `EarnRate` converted through the same
   `ValuationEntry` table (this conversion step is why both engines share
   the table — "3x points" and "5% cash back" aren't comparable until
   both are converted to a common cents-per-dollar unit).
Both are pure functions, no IO, unit testable with hand entered real card
data before any webview reader exists. Build and test these BEFORE the
reader.

## Valuation and earn rate data
Hand maintained, not scraped, not pulled live from search. These are
issuer published facts (transfer ratios, cash back rates, category bonus
structures). Seed from a JSON file or sqlite table you update manually.
Same approach for any future flight/award chart data — hand maintain the
specific routes/programs the user cares about rather than trusting a
live web search or letting an LLM estimate point costs as fact.

## Chat layer guardrails (apply before building lib/chat/)
- The chat input can be about anything; the LLM's only job is structured
  extraction, never a direct free text response shown to the user.
  Force a strict JSON schema out (e.g. `{intent, params}` with a fixed
  enum of known intents). App code parses this and renders its own
  templated UI — the model's raw text never reaches the screen.
- Fail closed on unrecognized or malformed output: fall back to a
  clarifying prompt with known intent options, never pass through an
  unvalidated response.
- The model only ever calls the existing pure engine functions with
  extracted parameters. It never gets direct database access and never
  constructs its own queries.
- Don't send more user data into a prompt than that specific request
  needs (e.g. a category string, not a full balance dump).
- If a scoped web search tool is added later for genuinely volatile data
  (e.g. a limited time transfer bonus), keep it narrow and label results
  to the user as "found via web search, verify before relying on it" —
  do not present it with the same confidence as the hand curated tables.
- Leaning toward a hosted LLM API call for extraction rather than a fully
  local model, for extraction quality reasons.

## Local storage: hot/cold split (apply when building lib/data/local_store/)
Keep operational data and historical data in physically separate tables
so the app stays fast regardless of how much history accumulates:
- **Hot** (`current_card_state`): current balances, points, due dates.
  Always small — bounded by number of cards, not by time. This is the
  only table the engines and main UI query.
- **Cold** (`balance_history`): point-in-time snapshots, append only,
  grows with usage. Only queried by an explicit history screen, never on
  the hot path. Fine to grow to thousands of rows; never delete data to
  manage size — bloat comes from querying this on the hot path, not from
  the data existing.
- Don't store derived/computed data (rankings, past recommendations) —
  recompute fresh from hot data each time, it's cheap given the row count
  is bounded by card count.

## Build order (do not skip ahead)
1. `ValuationEntry` model + hand seeded data for the user's real cards
2. Redemption engine + unit tests against real numbers (dummy-free,
   manually entered)
3. `EarnRate` model + hand seeded category data for the user's real cards
4. Best card engine + unit tests, reusing the valuation table from step 1
5. One bank's webview reader — prove the read-session-then-parse pattern,
   feed it into the already-tested engines
6. App shell connecting everything, with manual entry as fallback for any
   card without a reader yet
7. Local storage with the hot/cold split, once there's real data to store
8. Expand bank coverage one bank at a time
9. Chat/goal layer last, following the guardrails above

## How to work with me
- I am a software developer, comfortable with code — explain the WHY
  briefly before generating code, but skip beginner level explanations of
  general programming concepts. Focus explanations on decisions specific
  to this app (why a pattern was chosen here), not how the language or
  syntax works.
- Show me a short plan (a few bullets) before writing code for a new
  piece, so I can redirect early instead of after a big generation.
- Prefer diffs/explanations of what changed over regenerating whole
  files once code already exists.
- Flag anything near the credential/webview boundary explicitly, even if
  it seems minor.
- Keep explanations concrete and avoid restating context already in this
  file.