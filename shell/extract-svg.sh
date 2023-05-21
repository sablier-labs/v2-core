#!/usr/bin/env bash

# Notes:
# - The script takes a single input as an argument, i.e., the name of the test function to run
# - The script should be run from the repo's root directory
# - Test cases can be found in the files:
#   1. test/unit/lockup-dynamic/token-uri/tokenURI.t.sol
#   2. test/unit/lockup-linear/token-uri/tokenURI.t.sol

# Pre-requisites:
# - foundry (https://getfoundry.sh)
# - jq (https://stedolan.github.io/jq/)

# Strict mode: https://gist.github.com/vncsna/64825d5609c146e80de8b1fd623011ca
set -euo pipefail

if [ -z "$1" ]; then
  echo "Test function not provided, aborting"
  exit 1
fi

testFunction="$1"

noParanthesis=$(forge t -vv --match-test "$testFunction" | grep "URI: " | cut -d"(" -f2 | cut -d")" -f1)
firstLog=$(echo "$noParanthesis" | sed -n '1 p')
onlyData=$(echo "$firstLog" | awk -F "URI: " '{print $2}')
decoded=$(echo "$onlyData" | base64 --decode)
split=$(echo "$decoded" | awk -F "data:application/json;base64," '{print $2}')
clean=$(echo "$split" | jq -r .image | awk -F ',' '{print $2}' | base64 --decode)

echo "$clean" > tokenURI.svg
