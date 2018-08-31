#!/bin/sh
# vim: set ts=3 sw=3 noet ft=sh : bash
# RetroArch packaging script

PRGNAM=RetroArch
SRCNAM="$(printf %s $PRGNAM | tr '[:upper:]' '[:lower:]')"
TMP=${TMP:-/tmp/libretro}

# Exit on errors and unset variables
set -eu

# Ensure a clean and fully updated repo
[ -d $SRCNAM ] && rm -rf -- $SRCNAM

./libretro-fetch.sh $SRCNAM

COMMIT="$(git --work-tree=$SRCNAM --git-dir=$SRCNAM/.git describe --abbrev=0 \
	--tags)"
VERSION="$(printf %s $COMMIT | tr -d v)"

trap 'rm -rf -- $TMP/$PRGNAM-$VERSION; exit 0' EXIT INT

# Don't alter the original cloned repo
mkdir -p -- "$TMP"
rm -rf -- "$TMP/$PRGNAM-$VERSION"
cp -a $SRCNAM "$TMP/$PRGNAM-$VERSION"

# Checkout the last release tag
git --work-tree="$TMP/$PRGNAM-$VERSION" --git-dir="$TMP/$PRGNAM-$VERSION/.git" \
	checkout "$COMMIT"

# Remove .git directories and files
find "$TMP/$PRGNAM-$VERSION" -name ".git*" | xargs rm -rf

cd -- "$TMP"

# Create .zip and .tar.xz release tarballs.
zip -r "$PRGNAM-$VERSION.zip" "$PRGNAM-$VERSION"
tar cf - "$PRGNAM-$VERSION" | xz -c9 - > "$PRGNAM-$VERSION.tar.xz"

# Test the tarballs
rm -rf -- "$PRGNAM-$VERSION"
tar xvf "$PRGNAM-$VERSION.tar.xz"
rm -rf -- "$PRGNAM-$VERSION"
unzip -- "$PRGNAM-$VERSION.zip"

exit 0
