#!/usr/bin/env bash

# Pre-requisites:
# - The script is used as a regression test against a set of common configurations
# - The script should be run from the repo's root directory
# - foundry (https://getfoundry.sh)
# - jq (https://stedolan.github.io/jq/)

# Strict mode: https://gist.github.com/vncsna/64825d5609c146e80de8b1fd623011ca
set -uo pipefail

source ./shell/generate-svg.sh 10000 "Settled" "1000" 24
source ./shell/generate-svg.sh 5000 "Active" "1000" 10
