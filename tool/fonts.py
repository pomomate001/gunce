"""Downloads the OFL fonts used by Günce from github.com/google/fonts, makes static
instances of the variable fonts, subsets them (Latin, Greek, Cyrillic + symbols) and
writes them to assets/fonts/. Fails loudly if a font misses Turkish letters.

    python tool/fonts.py <download-dir>
"""
import sys
import urllib.parse
import urllib.request
from pathlib import Path

from fontTools import subset
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "fonts"
BASE = "https://raw.githubusercontent.com/google/fonts/main/ofl/"
TURKISH = "ğĞşŞıİçÇöÖüÜâÂ"
UNICODES = (
    "U+0000-024F,U+0259,U+02B0-02FF,U+0300-036F,U+0370-03FF,U+0400-04FF,U+1E00-1EFF,"
    "U+2000-206F,U+20A0-20CF,U+2100-214F,U+2190-21FF,U+2200-22FF,U+25A0-25FF,U+2600-26FF,U+FB00-FB06"
)

# Fonts with a Reserved Font Name must not be modified (subset/instanced) under the
# OFL, so they are shipped byte-for-byte as "<Family>-VF.ttf".
UNMODIFIED = [
    ("Lora", "lora/Lora[wght].ttf"),
    ("Quicksand", "quicksand/Quicksand[wght].ttf"),
    ("PlayfairDisplay", "playfairdisplay/PlayfairDisplay[wght].ttf"),
    ("DancingScript", "dancingscript/DancingScript[wght].ttf"),
    ("Comfortaa", "comfortaa/Comfortaa[wght].ttf"),
]

# (output family, source file, {axis: value} or None for static, output weights)
FONTS = [
    ("Fraunces", "fraunces/Fraunces[SOFT,WONK,opsz,wght].ttf", {"SOFT": 100, "WONK": 0, "opsz": 72}, [500, 600, 700]),
    ("FrauncesItalic", "fraunces/Fraunces-Italic[SOFT,WONK,opsz,wght].ttf", {"SOFT": 100, "WONK": 0, "opsz": 24}, [400]),
    ("Nunito", "nunito/Nunito[wght].ttf", {}, [400, 600, 700, 800]),
    ("Caveat", "caveat/Caveat[wght].ttf", {}, [400, 700]),
    ("PatrickHand", "patrickhand/PatrickHand-Regular.ttf", None, [400]),
    ("Kalam", "kalam/Kalam-Regular.ttf", None, [400]),
    ("Kalam", "kalam/Kalam-Bold.ttf", None, [700]),
    ("CourierPrime", "courierprime/CourierPrime-Regular.ttf", None, [400]),
    ("CourierPrime", "courierprime/CourierPrime-Bold.ttf", None, [700]),
    ("Pacifico", "pacifico/Pacifico-Regular.ttf", None, [400]),
    ("SpaceMono", "spacemono/SpaceMono-Regular.ttf", None, [400]),
    ("SpaceMono", "spacemono/SpaceMono-Bold.ttf", None, [700]),
]


def fetch(rel: str, dl: Path) -> Path:
    dest = dl / rel.replace("/", "__")
    if not dest.exists():
        url = BASE + urllib.parse.quote(rel)
        with urllib.request.urlopen(url, timeout=60) as r:
            dest.write_bytes(r.read())
    return dest


def main() -> None:
    dl = Path(sys.argv[1])
    dl.mkdir(parents=True, exist_ok=True)
    OUT.mkdir(parents=True, exist_ok=True)
    total = 0
    for family, rel in UNMODIFIED:
        src = fetch(rel, dl)
        cmap = TTFont(src).getBestCmap()
        missing = [c for c in TURKISH if ord(c) not in cmap]
        if missing:
            raise SystemExit(f"{family} lacks Turkish glyphs: {''.join(missing)}")
        out = OUT / f"{family}-VF.ttf"
        out.write_bytes(src.read_bytes())
        total += out.stat().st_size
        print(f"{out.name:28} {out.stat().st_size // 1024:5d} KB (unmodified)")
    for family, rel, axes, weights in FONTS:
        src = fetch(rel, dl)
        for w in weights:
            font = TTFont(src)
            if axes is not None:
                loc = dict(axes)
                loc["wght"] = w
                loc = {k: v for k, v in loc.items() if k in {a.axisTag for a in font["fvar"].axes}}
                font = instancer.instantiateVariableFont(font, loc, updateFontNames=False)
            cmap = font.getBestCmap()
            missing = [c for c in TURKISH if ord(c) not in cmap]
            if missing:
                raise SystemExit(f"{family} {w} lacks Turkish glyphs: {''.join(missing)}")
            opts = subset.Options()
            opts.layout_features = ["*"]
            opts.name_IDs = ["*"]
            opts.notdef_outline = True
            opts.glyph_names = False
            opts.hinting = False
            sub = subset.Subsetter(opts)
            sub.populate(unicodes=subset.parse_unicodes(UNICODES))
            sub.subset(font)
            out = OUT / f"{family}-{w}.ttf"
            font.save(out)
            total += out.stat().st_size
            print(f"{out.name:28} {out.stat().st_size // 1024:5d} KB")
    print(f"total {total // 1024} KB")


if __name__ == "__main__":
    main()
