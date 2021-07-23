#!/bin/bash

set -e
set -x

DOCKER=0
BIN_PATH="/usr/bin/zcli"
PERL_PATH="/usr/share/perl5"

OS_FILE="/etc/os-release"
source $OS_FILE


if [[ "$1" != "" ]]; then
	if [[ "$1" == "-docker" ]]; then
		DOCKER=1
		# Var to set autoconfirm option in CPAN
		PERL_MM_USE_DEFAULT=1
	elif [[ "$1" =~ "^(-h|--help)$" ]]; then
		echo "$0 [-docker]"
		echo "   The docker option accept the interactive dialog in order not to need human interaction"
	else
		echo "The option '$1' is not recoignized"
		exit 1
	fi
fi


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
YES=""
if [[ $DOCKER -eq 1 ]]; then YES="-y"; fi
if [[ "$OS" == "centos" ]]; then
	yum install `grep -E "build\b" $DEPENDENCIES | sed -E 's/build\s*=>\s*//'` $YES
	yum install `grep build_centos $DEPENDENCIES | sed -E 's/build_centos\s*=>\s*//'` $YES
elif [[ "$OS" == "debian" ]]; then
	apt-get install $YES `grep -E "build\b" $DEPENDENCIES | sed -E 's/build\s*=>\s*//'`
	apt-get install $YES `grep -E "build_debian\b" $DEPENDENCIES | sed -E 's/build_debian\s*=>\s*//'`
else
	pacman -S `grep -E "build\b" $DEPENDENCIES | sed -E 's/build\s*=>\s*//'`
fi

# perl modules
cpan install `grep common $DEPENDENCIES | sed -E 's/common\s*=>\s*//'`

## Necessary, the Term::ReadLine::Gnu module requires human interface for tests
FORCE=""
if [[ $DOCKER -eq 1 ]]; then FORCE="-f"; fi
cpan install $FORCE `grep linux $DEPENDENCIES | sed -E 's/linux\s*=>\s*//'`
ln -s $ZCLI_BIN $BIN_PATH
ln -s $ZCLI_LIB $PERL_PATH

exit 0
