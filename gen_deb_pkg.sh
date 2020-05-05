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
mkdir -p "workdir/$INST_PATH_LIB"
mkdir -p "workdir/$INST_PATH_BIN"
cp -r src/ZCLI "workdir/$INST_PATH_LIB"
cp -r src/zcli.pl "workdir/$INST_PATH_BIN/zcli"
cd workdir



#### Control cfg ####

echo
version=$(grep '$Version' ${INST_PATH_LIB}/ZCLI/Define.pm | sed -E 's/[^\.0-9b]//g')

echo $version

deps=$(grep debian ${BASE_DIR}/dependencies.txt | sed -E 's/debian\s*=>\s*//')

control="Package: zcli\nVersion: $version\n\
Maintainer: ZEVENET Company SL <support@zevenet.com>\n\
Architecture: amd64\n\
Section: admin\n\
Priority: optional\n\
Description: Zevenet client line interface\n\
Depends: $deps\n"

mkdir DEBIAN
echo -e $control >DEBIAN/control


#### Package preparation ####

pkgname_prefix="zcli_${version}_${arch}"
pkgname=${pkgname_prefix}_${DATE}.deb

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

