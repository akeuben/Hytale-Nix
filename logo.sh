ICON=hytale-launcher
SRC=hytale.png
BASE=./icons/hicolor

for s in 16 24 32 48 64 128 256; do
  install -d "$BASE/${s}x${s}/apps"
  magick "$SRC" -resize ${s}x${s} "$BASE/${s}x${s}/apps/${ICON}.png"
done
