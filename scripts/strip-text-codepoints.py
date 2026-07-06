#!/usr/bin/env python3
"""Strip text-range codepoints from a font's cmap.

An emoji font must not own plain-text characters. Space, '#', '*' and the digits
exist only as keycap ligature components; removing them from cmap makes them fall
back to the UI font. Keep U+200D (ZWJ), U+FE0F, U+20E3, needed to shape emoji
sequences.

Usage: strip-text-codepoints.py <src.ttf> <dst.ttf>
"""
import sys

from fontTools.ttLib import TTFont

src, dst = sys.argv[1], sys.argv[2]
f = TTFont(src)
remove = {0x20, 0x23, 0x2A} | set(range(0x30, 0x3A))
for t in f["cmap"].tables:
    for cp in list(t.cmap):
        if cp in remove:
            del t.cmap[cp]
f.save(dst)
print("wrote", dst)
