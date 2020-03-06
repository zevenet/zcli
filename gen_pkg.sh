#!/bin/bash

# Exit at the first error
set -e

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DATE=$(date +%y%m%d_%H%M%S)
arch="amd64"

# Default options
devel="false"

function print_usage_and_exit() {
	echo "Usage: $(basename "$0") "

	exit 1
}

function msg() {
	echo -e "\n#### ${1} ####\n"
}

function die() {
	local bldred='\e[1;31m' # Red bold text
	local txtrst='\e[0m'    # Text Reset

	msg "${bldred}Error${txtrst}${1}"
	exit 1
}



#### Initial setup ####

INST_PATH_LIB="usr/share/perl5"
INST_PATH_BIN="usr/bin"


# Setup a clean environment
cd "$BASE_DIR"
msg "Setting up a clean environment..."
rm -rf workdir
mkdir workdir
cp -r DEBIAN workdir/
mkdir -p "workdir/$INST_PATH_LIB"
mkdir -p "workdir/$INST_PATH_BIN"
cp -r src/ZCLI "workdir/$INST_PATH_LIB"
cp -r src/zcli.pl "workdir/$INST_PATH_BIN/zcli"
cd workdir


# Set version and package name
version=$(grep '$Version' ${INST_PATH_LIB}/ZCLI/Define.pm | sed -E 's/[^\.0-1]//g')
sed -i "s/#VERSION#/$version/" DEBIAN/control
pkgname_prefix="zcli_${version}_${arch}"
pkgname=${pkgname_prefix}_${DATE}.deb

#### Package preparation ####

msg "Preparing package..."

# Remove .keep files
find . -name .keep -exec rm {} \;


#### Generate package and clean up ####

msg "Generating .deb package..."
cd "$BASE_DIR"

# Generate package using the most recent debian version
if [ ! -d packages ]; then
	mkdir packages
fi

dpkg-deb --build workdir packages/"$pkgname" \
	|| die " generating the package"

msg "Success: package ready"

