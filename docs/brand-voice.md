# Brand voice

How Financial Runway sounds and looks, outside the app and in it. Check any new
copy or store asset against this page.

## The idea

One number: how long your money lasts, counted from today. Knowing it is not a
warning, it is permission: to stay longer, to take the trip, to change direction.
Courage, not survival mode.

## Voice

**Plain.** Short sentences, everyday words, the useful fact and nothing else.
- Sounds like: "Log a spend in seconds."
- Not like: "Effortlessly track your expenditures with our intuitive interface."

**Honest.** Say exactly what the app does. No promise the code does not keep.
- Sounds like: "Your records never leave your phone."
- Not like: "Nothing ever leaves your phone." (usage analytics do, with no money in them)

**Calm, then brave.** Lead with the question, end with what the reader can now do.
Never with fear.
- Sounds like: "How long will your money last?"
- Not like: "Are you about to go broke?"

## Words

| Use | Not | Why |
|---|---|---|
| Financial Runway, then Runway | Survival Optimizer (the old name) | "Financial Runway" on first mention |
| Runway Pro | premium, subscription | Pro is one payment |
| runway, months, run-out month | burn rate, survival | Plain words a reader types |
| entry, log | transaction, record (in UI) | The words the app shows |
| your records | your data (in claims) | Analytics are data; records never leave |

Never: "financial advice", "guarantee", "best", "only", or a figure the app does
not show.

## Style

- No em dashes, anywhere. Join halves with " · ". A lone "—" for an unknown
  value is a placeholder, not prose. `packages/presentation/test/copy_has_no_em_dash_test.dart`
  enforces this in the app.
- Headlines in sentence case. Captions and labels carry no full stop.
- Write the English first and cut it, then apply the same cut in every locale.
- Store images carry no prices, URLs or awards (Apple's rule). The website and
  the paywall may state the price.

## Look

From the Shipaton artwork, colours sampled from its plate:

| Role | Value |
|---|---|
| Ground | cream `#fefbf4` |
| Ink | `#08142b`, secondary `#536279` |
| Slab | deep violet `#3a1f80`, near-parallel edges, behind the phone, off the right edge |
| Ridge | mint `#a7e9b7`, steps up toward the phone, falls off the canvas |
| Star | coral `#ed8871`, seven points, once per image |
| Type | Newsreader for headlines, JetBrains Mono for the wordmark, Inter for body |
| Phone | light titanium edge `#c8d8ea`, tilted right; the app screen lifted (brightness 1.3, contrast 1.15) so it reads small |

Store slides: `assets/store/screenshot.html`. Header and search assets:
`assets/store/creative.html`. Both render with `assets/store/render.sh`.
