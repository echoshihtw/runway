# Open Graph image

`card.html` uses the marketing page's Newsreader, Inter, and JetBrains Mono
fonts. Render it from this directory:

```sh
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless --disable-gpu --allow-file-access-from-files --hide-scrollbars \
  --force-device-scale-factor=2 --window-size=1200,630 \
  --screenshot=../og.png card.html
```

2400 × 1260, which is 1.91:1 at 2x -- the ratio Open Graph and Twitter expect.
Re-render when the hero copy or `device/01-runway.png` changes, so the preview
and the page cannot drift apart.
