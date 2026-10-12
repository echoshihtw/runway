#!/usr/bin/env bash
# Renders the App Store slides in screenshot.html into docs/screenshots at the
# 6.9-inch size, 1320x2868, and the creative assets in creative.html into
# build/store at Apple's three sizes.
set -euo pipefail

root="$(cd "$(dirname "$0")/../.." && pwd)"
chrome="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

shot() { # <html file> <hash> <width,height> <out>
  "$chrome" --headless --disable-gpu --hide-scrollbars \
    --window-size="$3" --virtual-time-budget=3000 \
    --screenshot="$4" "file://$root/assets/store/$1#$2"
}

for name in 01-runway 02-living 03-log 04-plan; do
  shot screenshot.html "$name" 1320,2868 "$root/docs/screenshots/$name.png"
done

mkdir -p "$root/build/store"
shot creative.html universal 5244,2950 "$root/build/store/creative-universal.png"
shot creative.html search 3840,2560 "$root/build/store/creative-search.png"
shot creative.html header 3840,1646 "$root/build/store/creative-header.png"
