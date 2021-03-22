# Monochrome Social Icons

## Convert SVGs to PNGs

Using ImageMagick's `convert` (`brew install imagemagick`) and `imageoptim` (`brew install imageoptim-cli`) run from this directory:

```sh
for file in *.svg; do convert -resize 100 -background none "$file" "${file/.svg/.png}" && imageoptim "${file/.svg/.png}"; done
```

Or using `svg2png` (`yarn global add svg2png`) and `imageoptim` (`brew install imageoptim-cli`) run from this directory:

```sh
for file in *.svg; do svg2png -w 100 "$file" "${file/.svg/.png}" && imageoptim "${file/.svg/.png}"; done
```
