#!/bin/bash

set -e

BIN_PATH="/usr/bin/zcli"
PERL_PATH="/usr/share/perl5"
if [ -d "$PERL_PATH/vendor_perl" ]; then
	PERL_PATH="$PERL_PATH/vendor_perl"
fi

GIT_ZCLI_BIN="src/zcli.pl"
GIT_ZCLI_LIB="src/ZCLI"

BASE_DIR=$(dirname "$0")
ZCLI_BIN=$(realpath ${BASE_DIR}/$GIT_ZCLI_BIN)
ZCLI_LIB=$(realpath ${BASE_DIR}/$GIT_ZCLI_LIB)
DEPENDENCIES="$BASE_DIR/dependencies.txt"


cpan install `cat $DEPENDENCIES`
ln -s $ZCLI_BIN $BIN_PATH
ln -s $ZCLI_LIB $PERL_PATH
