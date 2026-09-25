#!/usr/bin/env bash
# Renders every wireframe in docs/design/wireframes/index.html, with its
# notes, to docs/design/wireframes/<id>.png. Edit the HTML, then re-run this;
# don't edit the PNGs. Needs Brave or Google Chrome (headless).
set -euo pipefail

cd "$(dirname "$0")/.."

DIR=docs/design/wireframes
PAGE="file://$PWD/$DIR/index.html"

BROWSER=""
for candidate in \
  "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser" \
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"; do
  if [[ -x "$candidate" ]]; then BROWSER=$candidate; break; fi
done
if [[ -z "$BROWSER" ]]; then
  echo "Needs Brave or Google Chrome installed." >&2
  exit 1
fi

for id in $(grep -oE '<figure class="shot" id="[a-z0-9-]+"' "$DIR/index.html" | sed -E 's/.*id="([^"]+)"/\1/'); do
  "$BROWSER" --headless=new --disable-gpu --hide-scrollbars \
    --force-device-scale-factor=1.5 --window-size=948,836 \
    --virtual-time-budget=5000 \
    --screenshot="$PWD/$DIR/$id.png" "$PAGE#solo-$id" >/dev/null 2>&1
  echo "$DIR/$id.png"
done
