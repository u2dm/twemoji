#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SVG_DIR="$ROOT/assets/svg"
OUT="$ROOT/Twemoji.ttf"
FAMILY="Twemoji"

[ -d "$SVG_DIR" ] || { echo "error: $SVG_DIR not found, run from the twemoji fork root" >&2; exit 1; }

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

echo "==> Creating virtualenv + installing nanoemoji"
python3 -m venv "$work/venv"
"$work/venv/bin/pip" install --quiet --upgrade pip
"$work/venv/bin/pip" install --quiet nanoemoji fonttools ninja
export PATH="$work/venv/bin:$PATH"   # so nanoemoji's ninja build finds picosvg/ninja

echo "==> Building COLRv0 font ($(ls "$SVG_DIR" | wc -l) glyphs)"
nanoemoji \
    --color_format glyf_colr_0 \
    --family "$FAMILY" \
    --output_file "$work/Twemoji.ttf" \
    "$SVG_DIR"/*.svg

echo "==> Stripping text-range codepoints from cmap (space, digits, # and *)"
"$work/venv/bin/python" "$SCRIPT_DIR/strip-text-codepoints.py" "$work/Twemoji.ttf" "$OUT"

echo "==> Writing checksum"
( cd "$ROOT" && sha256sum "$(basename "$OUT")" > "$OUT.sha256" )
cat "$OUT.sha256"

echo "==> Done: $OUT"
