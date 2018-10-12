#!/bin/sh
# vim: set ts=3 sw=3 noet ft=sh : bash
# RetroArch packaging script

PRGNAM=RetroArch
SRCNAM="$(printf %s $PRGNAM | tr '[:upper:]' '[:lower:]')"
TMP=${TMP:-/tmp/libretro}
FORCE=0
CLEAN=0

for x in $@; do
	if [ "$x" == "--force" ]; then
        FORCE=1
	fi
	if [ "$x" == "--clean" ]; then
        CLEAN=1
	fi
done

# Exit on errors and unset variables
set -eu

# Ensure a clean and fully updated repo
if [ -d $SRCNAM ]; then
    if [ $CLEAN -gt 0 ]; then
		rm -rf -- $SRCNAM
	elif [ $FORCE -gt 0 ]; then
		echo "Using existing state of $SRCNAM. If build fails, use --clean to delete and re-clone."
	else
		echo "FATAL: $SRCNAM/ exists."
		echo ""
		echo " - To build with existing sources: $0 --force"
		echo " - To delete existing sources and re-clone: $0 --clean"
		echo ""
		echo "WARNING: The --clean option does not preserve forks. That is,"
		echo "the original libretro/$PRGNAM repository will be cloned, not"
		echo "your personal fork. To build a release build from a fork,"
		echo "use --force."
		exit 1
	fi
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
