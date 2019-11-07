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

# Setup a clean environment
cd "$BASE_DIR"
msg "Setting up a clean environment..."
rm -rf workdir
mkdir workdir
rsync -a DEBIAN src/* workdir/
cd workdir

# Set version and package name
version=$(grep "Version:" DEBIAN/control | cut -d " " -f 2)
pkgname_prefix="zcli_${version}_${arch}"
pkgname=${pkgname_prefix}_DEV_${distribution}_${DATE}.deb

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

