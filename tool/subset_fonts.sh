#!/usr/bin/env bash
# Writes the fonts the app bundles (assets/fonts/*.ttf) from the full ones in
# assets/fonts/source/, keeping only the characters the app can show: Latin,
# general punctuation and every character in its texts and string literals.
# Fails if the subset drops any of those characters that the full font has.
# Run it after adding a text with a new symbol, then review the goldens.
set -euo pipefail

cd "$(dirname "$0")/.."

venv=.dart_tool/fonttools-venv
if [[ ! -x "$venv/bin/pyftsubset" ]]; then
  python3 -m venv "$venv"
  "$venv/bin/pip" install --quiet --disable-pip-version-check "fonttools==4.60.1"
fi

"$venv/bin/python" - <<'PY'
import glob
import pathlib
import subprocess
from fontTools.ttLib import TTFont

ranges = [(0x20, 0x7E), (0xA0, 0x17F), (0x2000, 0x206F), (0x20AC, 0x20AC)]
needed = {c for start, end in ranges for c in range(start, end + 1)}
texts = glob.glob("lib/l10n/*.arb") + glob.glob("lib/**/*.dart", recursive=True)
used = {ord(c) for path in texts for c in pathlib.Path(path).read_text()
        if ord(c) > 0x7E}
needed |= used
unicodes = ",".join(f"U+{c:04X}" for c in sorted(needed))

missing = {}
for source in sorted(glob.glob("assets/fonts/source/*.ttf")):
    target = pathlib.Path("assets/fonts") / pathlib.Path(source).name
    subprocess.run(
        [".dart_tool/fonttools-venv/bin/pyftsubset", source,
         f"--unicodes={unicodes}", f"--output-file={target}",
         "--layout-features=*", "--name-IDs=*", "--notdef-outline"],
        check=True,
    )
    full = TTFont(source).getBestCmap()
    kept = TTFont(target).getBestCmap()
    gaps = sorted(c for c in used if c in full and c not in kept)
    if gaps:
        missing[target.name] = "".join(chr(c) for c in gaps)
    print(f"{target}: {pathlib.Path(source).stat().st_size} -> {target.stat().st_size} bytes")

if missing:
    raise SystemExit(f"Characters the app uses that the subset dropped: {missing}")
PY
