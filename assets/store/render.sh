#!/usr/bin/env bash
# Renders every App Store slide in screenshot.html into docs/screenshots at the
# 6.9-inch size, 1320x2868.
set -euo pipefail

root="$(cd "$(dirname "$0")/../.." && pwd)"
chrome="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

for name in 01-runway 02-living 03-log 04-plan; do
  "$chrome" --headless --disable-gpu --hide-scrollbars \
    --window-size=1320,2868 --virtual-time-budget=3000 \
    --screenshot="$root/docs/screenshots/$name.png" \
    "file://$root/assets/store/screenshot.html#$name"
done
