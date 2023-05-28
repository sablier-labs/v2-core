#!/usr/bin/env bash

# Pre-requisites:
# - The script takes a 4 inputs as arguments, i.e., progress, status, amount and duration
# - The script should be run from the repo's root directory
# - The shell script will feed data to the GenerateSVG.s.sol script
# - foundry (https://getfoundry.sh)
# - jq (https://stedolan.github.io/jq/)

# Strict mode: https://gist.github.com/vncsna/64825d5609c146e80de8b1fd623011ca
set -uo pipefail

function generate(){

  local arg_progress=${1:-4235}
  local arg_status=${2:-"Streaming"}
  local arg_amount=${3:-">= 1.23M"}
  local arg_duration=${4:-91}

  local signature="run(uint256,string,string,uint256)"
  local script="./script/GenerateSVG.s.sol"
  local output="$(forge script $script --sig $signature $arg_progress $arg_status $arg_amount $arg_duration)"
  local svg=$(echo "$output" | awk -F "svg: string " '{print $2}' | awk 'NF > 0')

  local name="nft-${arg_progress}-${arg_status}-${arg_amount}-${arg_duration}.svg"
  local sanitized="$(echo "$name" | sed "s/ //g" )"

  mkdir -p "./out-svg"
  echo $svg > "./out-svg/"$sanitized
  return 0
}

generate $@
