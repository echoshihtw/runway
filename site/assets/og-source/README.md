# Open Graph image

`card.html` uses the same Newsreader, Inter, and JetBrains Mono font files as
the marketing page. Render it from this directory with:

```sh
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless --disable-gpu --allow-file-access-from-files --hide-scrollbars \
  --force-device-scale-factor=2 --window-size=1200,630 \
  --screenshot=../og.png card.html
```

The resulting 2400 × 1260 PNG is the 1.91:1 Open Graph image referenced by
the site metadata.
