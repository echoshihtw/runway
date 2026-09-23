# Open Graph image

`../og.png` is 2400 × 1260, which is 1.91:1 at 2x — the ratio Open Graph and
Twitter expect. It is referenced absolutely by all three pages.

The HTML here does **not** produce the shipped image. `card.html` renders an
earlier all-CSS card, and the current `og.png` is a composed render. Keeping
them is fine; treating either as the source is not. If you change the card,
replace `og.png` directly and update `og:image:alt` on the three pages, which
is the only thing that describes it to a screen reader.
