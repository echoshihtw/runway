# og.png

The link preview card. Rendered from `card.html`, not drawn by hand, so it
stays in step with the site: same tokens, same fonts, same screenshot.

```
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless --disable-gpu --allow-file-access-from-files --hide-scrollbars \
  --force-device-scale-factor=2 --window-size=1200,630 \
  --screenshot=../og.png card.html
```

1200x630 at 2x. That ratio is what Open Graph and Twitter expect; a portrait
screenshot is what the preview fell back to before this existed, and it was
cropped to a tall tile with the title overlaying the app.

Re-render it when the hero copy or `device/01-runway.png` changes.
