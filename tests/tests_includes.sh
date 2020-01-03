#!/bin/bash

SRC_PATH="../src/ZCLI"

function get_host_var() {
    VAR=$(perl -E "require '${SRC_PATH}/Lib.pm'; my \$var = &hostInfo()->{$1}; print \$var;")
}

CONFIG="$HOME/.zcli/hosts.ini";

get_host_var "HOST"
IP=$VAR

ZCLI="zcli"

# exit with the first error
set -e