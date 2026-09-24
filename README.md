# Financial Runway

One phone. No account, no bank connection.

## How long will your money last?

Most money apps tell you where your money went. This one tells you how long it
lasts: one number, counted from today, and the month it runs out.

It is for a defined chapter rather than for ever — studying abroad, between
jobs, bootstrapping something, living off savings. The question does not change
while you are in one, so neither does the app.

## Screens

<p align="center">
  <img src="docs/screenshots/01-runway.png" width="24%" alt="Dashboard — how many months your money covers, cash and run-out month">
  <img src="docs/screenshots/02-living.png" width="24%" alt="Living budget — spent against budget, what is left, and the daily amount">
  <img src="docs/screenshots/03-log.png" width="24%" alt="Log — every entry with the budget it counts against">
  <img src="docs/screenshots/04-plan.png" width="24%" alt="Plan — a lower monthly cost and the months it adds">
</p>

Demo data, computed rather than mocked.

## See it, log it, try it

**Know what you can spend today.** Your monthly living budget becomes one useful
number for today, and what is left after it.

**Speed dial.** Six occasions and an amount. Logging an expense uses up its
budget rather than adding to your costs, so the runway only moves when you go
over.

**See what one change buys you.** Try a lower monthly cost or extra income
against the runway you already have, and read the months it adds. It changes no
records.

## Your money story stays with you

Entries live in a SQLCipher database with the key in the Keychain, so there is
no account to make, no bank to connect and no server to leak. Six languages —
English, Spanish, French, Italian, Japanese and Traditional Chinese — and six
currency symbols: JPY, TWD, USD, EUR, GBP, CNY. The symbol is a display choice;
amounts are never converted.

Delete all data erases every entry, loan, subscription, budget and setting.
The Pro purchase survives it, so clearing your data never costs you what you
paid for.

## Status

Not yet on the App Store. Runway Pro is a one-time purchase, never a
subscription.

---

## What's next

**Android.** The same number on whatever phone you carry.

---

## Building it

```
packages/
  domain/          Pure Dart. Entities, logic, repository interfaces.
  data/            Drift + SQLCipher. Repository implementations.
  application/     Riverpod providers and use cases.
  design_system/   Tokens, theme, components, localisations.
  presentation/    Screens and widgets.
app/               The Flutter app that wires them together.
```

A Melos workspace. `domain` has no Flutter dependency, which is what keeps the
runway calculation testable without a widget tree.

```bash
make setup        # melos bootstrap
make gen          # Drift and Riverpod codegen
make gen-l10n     # regenerate localisations from the .arb files
make analyze      # every package
make test         # every package
make run          # on a connected device
```
