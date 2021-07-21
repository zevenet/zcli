#!/bin/bash

set -e

BIN_PATH="/usr/bin/zcli"
PERL_PATH="/usr/share/perl5"

OS_FILE="/etc/os-release"
source $OS_FILE

shopt -s nocasematch
if [[ $NAME =~ "debian" ]]; then
	OS="debian"
elif [[ $NAME =~ "arch" ]]; then
	OS="arch"
elif [[ $NAME =~ "centos" ]]; then
	OS="centos"
else
	echo "The OS was not recoignized"
	exit 1
fi


if [ -d "$PERL_PATH/vendor_perl" ]; then
	PERL_PATH="$PERL_PATH/vendor_perl"
fi

GIT_ZCLI_BIN="src/zcli.pl"
GIT_ZCLI_LIB="src/ZCLI"

BASE_DIR=$(dirname "$0")
ZCLI_BIN=$(realpath ${BASE_DIR}/$GIT_ZCLI_BIN)
ZCLI_LIB=$(realpath ${BASE_DIR}/$GIT_ZCLI_LIB)
DEPENDENCIES="$BASE_DIR/dependencies.txt"

# system packages
if [[ "$OS" == "centos" ]]; then
	yum install `grep -E "build\b" $DEPENDENCIES | sed -E 's/build\s*=>\s*//'`
	yum install `grep build_centos $DEPENDENCIES | sed -E 's/build_centos\s*=>\s*//'`
elif [[ "$OS" == "debian" ]]; then
	apt-get instal `grep -E "build\b" $DEPENDENCIES | sed -E 's/build\s*=>\s*//'`
else
	pacman -S `grep -E "build\b" $DEPENDENCIES | sed -E 's/build\s*=>\s*//'`
fi

# perl modules
cpan install `grep common $DEPENDENCIES | sed -E 's/common\s*=>\s*//'`
cpan install `grep linux $DEPENDENCIES | sed -E 's/linux\s*=>\s*//'`
ln -s $ZCLI_BIN $BIN_PATH
ln -s $ZCLI_LIB $PERL_PATH
