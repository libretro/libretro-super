#!/bin/sh
# vim: set ts=3 sw=3 noet ft=sh : sh
# RetroArch packaging script for release tarballs

PRGNAM=RetroArch
SRCNAM="$(printf %s $PRGNAM | tr '[:upper:]' '[:lower:]')"
TMP=${TMP:-/tmp/libretro}

# Exit on errors and unset variables
set -eu

# Ensure a clean and fully updated repo
if [ -d $SRCNAM ]; then
	printf %s\\n "WARNING: The $PRGNAM directory already exists." \
		"Remove the $PRGNAM directory and continue? (y/n)" >&2
	read -r answer
	case "$answer" in
		[yY]|[yY][eE][sS] ) rm -rf -- $SRCNAM ;;
		* ) printf %s\\n 'Exiting ...'; exit 0 ;;
	esac
fi

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

# Create SHA256SUMS and SHA512SUMS, use 'gpg --clearsign' to sign these.
sha256sum "$PRGNAM-$VERSION.tar.xz" "$PRGNAM-$VERSION.zip" > SHA256SUMS
sha512sum "$PRGNAM-$VERSION.tar.xz" "$PRGNAM-$VERSION.zip" > SHA512SUMS

exit 0
