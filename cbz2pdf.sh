#!/usr/bin/env bash

set -e

if ! command -v img2pdf &> /dev/null; then
	echo "img2pdf is not installed or not in your PATH!"
	exit 1
fi

if [ "$#" -lt 1 ]; then
	echo "Illegal number of parameters"
	exit 1
fi

CBZ=$1
if [ ! -r "${CBZ}" ]; then
	echo "Invalid input file"
	exit 1
fi

if [ ! "$CBZ" = *.cbz ]; then
    echo "Not a CBZ file"
    exit 1
fi

echo "Creating work directory…"

EXTRACT_DIR=$(mktemp -d)
function cleanup {
	rm -rf "$EXTRACT_DIR"
	echo "(Deleted work directory $EXTRACT_DIR)"
}

# register the cleanup function to be called on the EXIT signal
trap cleanup EXIT

echo "Extracting CBZ file to work directory…"
tar xf "$CBZ" -C "$EXTRACT_DIR"

DIRNAME=$(dirname "$CBZ")
FNAME_NO_EXT=$(basename "$CBZ" .cbz)
AUTHOR=${2:-""}
TITLE=${3:-$FNAME_NO_EXT}

# echo "fname: $FNAME_NO_EXT"
# echo "author: $AUTHOR"
# echo "title: $TITLE"

echo "Creating PDF file…"
shopt -s globstar nullglob

if [ -z "$TITLE" ]; then
	OUTFILE="$DIRNAME/$FNAME_NO_EXT.pdf"
else
	OUTFILE="$DIRNAME/$TITLE.pdf"
fi

img2pdf -o "$OUTFILE" --title "$TITLE" --subject "$TITLE" --author "$AUTHOR" --creator "$AUTHOR" --viewer-fit-window "$EXTRACT_DIR"/**/*.{jpg,png}

echo "Done!"