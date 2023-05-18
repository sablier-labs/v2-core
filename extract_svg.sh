#!/bin/bash

# To run this script, execute the following commands in the terminal:
# 1. source extract_svg.sh
# 2. extract_svg "TestName"
# Replace "TestName" with the desired test name.
# Test cases can be found in the files:
# 1. test/unit/lockup-dynamic/token-uri/tokenURI.t.sol
# 2. test/unit/lockup-linear/token-uri/tokenURI.t.sol

function extract_svg() {
    local TEST_NAME="$1"

    if [ -z "$TEST_NAME" ]; then
        echo "Usage: extract_svg <TestName>"
        return 1
    fi

    local NO_PARENTHESIS=$(forge t -vvvv --mt "$TEST_NAME" | grep "URI: " | cut -d"(" -f2 | cut -d")" -f1)
    local FIRST_LOG=$(echo "$NO_PARENTHESIS" | sed -n '1 p')
    local ONLY_DATA=$(echo "$FIRST_LOG" | awk -F "URI: " '{print $2}')
    local DECODED=$(echo "$ONLY_DATA" | base64 --decode)
    local SPLIT=$(echo "$DECODED" | awk -F "data:application/json;base64," '{print $2}')
    local CLEAN=$(echo "$SPLIT" | jq -r .image | awk -F ',' '{print $2}' | base64 --decode)

    echo "$CLEAN" > tokenURI.svg
}
