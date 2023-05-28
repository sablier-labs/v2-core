#!/usr/bin/env bash

# Notes:
# - Generates a panoply of SVGs with different accent colors and card contents.

# Pre-requisites:
# - foundry (https://getfoundry.sh)
# - jq (https://stedolan.github.io/jq/)

# Strict mode: https://gist.github.com/vncsna/64825d5609c146e80de8b1fd623011ca
set -euo pipefail

./shell/generate-svg.sh 0 "Pending" "1" 5
./shell/generate-svg.sh 0 "Pending" "1.30K" 21
./shell/generate-svg.sh 0 "Pending" "424.01M" 565

./shell/generate-svg.sh 0 "Canceled" "1" 3
./shell/generate-svg.sh 0 "Canceled" "84.01K" 3
./shell/generate-svg.sh 7231 "Canceled" "421.11K" 24

./shell/generate-svg.sh 15 "Streaming" "§" 0
./shell/generate-svg.sh 42 "Streaming" "200" 0
./shell/generate-svg.sh 422 "Streaming" "102.30K" 0
./shell/generate-svg.sh 1030 "Streaming" "48.93M" 1021
./shell/generate-svg.sh 4235 "Streaming" "8.91M" 1
./shell/generate-svg.sh 7291 "Streaming" "756.12T" 7211
./shell/generate-svg.sh 9999 "Streaming" "3.32K" 88

./shell/generate-svg.sh 10000 "Settled" "1" 892
./shell/generate-svg.sh 10000 "Settled" "14.94K" 892
./shell/generate-svg.sh 10000 "Settled" "645.01M" 3402
./shell/generate-svg.sh 10000 "Settled" "990.12B" 6503
