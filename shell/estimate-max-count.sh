#!/usr/bin/env bash

# Pre-requisites for running this script:
#
# - bun (https://bun.sh)
# - foundry (https://getfoundry.sh)

# Strict mode: https://gist.github.com/vncsna/64825d5609c146e80de8b1fd623011ca
set -euo pipefail

# Define usage
usage="\nUsage: ./shell/estimate-max-count.sh <commands> [...flags] <chain>

Examples:
  ./shell/estimate-max-count.sh segments --all
  ./shell/estimate-max-count.sh tranches --chain avalanche

Commands:
  segments                  Estimate the maximum number of segments
  tranches                  Estimate the maximum number of tranches

Flags:
  --all                     Include all chains
  --chain <chain>           Run only for the specified chain
  --help, -h                Print help text
"

# Declare the chains array
declare -A supported_chains

# Define Block gas limits for each chain
supported_chains["arbitrum"]=32000000
supported_chains["avalanche"]=15000000
supported_chains["base"]=60000000
supported_chains["blast"]=30000000
supported_chains["bsc"]=138000000
supported_chains["ethereum"]=30000000
supported_chains["gnosis"]=17000000
supported_chains["optimism"]=30000000
supported_chains["polygon"]=30000000
supported_chains["scroll"]=10000000
supported_chains["sepolia"]=30000000

# The following function calls `forge script` to get the maximum number of segments
estimate_segments() {
  blockGasLimit="${supported_chains[$1]}"
  FOUNDRY_PROFILE=optimized forge script script/EstimateMaxCount.s.sol --sig "estimateSegments(uint256)" ${blockGasLimit}
  echo "$1" block gas limit: ${blockGasLimit}
  echo
}

# The following function calls `forge script` to get the maximum number of tranches
estimate_tranches() {
  blockGasLimit="${supported_chains[$1]}"
  FOUNDRY_PROFILE=optimized forge script script/EstimateMaxCount.s.sol --sig "estimateTranches(uint256)" ${blockGasLimit}
  echo "$1" block gas limit: ${blockGasLimit}
  echo
}

# Check for arguments passed to the script
for ((i=1; i<=$#; i++)); do
  # Convert the argument to lowercase
  arg=${!i,,}

  # Show usage of this command with --help option
  if [[ ${arg} == "--help" || ${arg} == "-h" ]]; then
    echo -e "${usage}"
    exit 0
  fi

  # Check if the command is 'segments'
  if [[ ${arg} == "segments" ]]; then
    # Increment index to get the flag
    ((i++))
    arg=${!i,,}

    # Check if '--chain' flag is passed
    if [[ ${arg} == "--chain" ]]; then
      # Increment index to get the chain name
      ((i++))
      chain=${!i}

      estimate_segments ${chain}

      exit 0
    fi

    # Check if '--all' flag is passed
    if [[ ${arg} == "--all" ]]; then
      for chain in "${!supported_chains[@]}"; do
        estimate_segments ${chain}
      done

      exit 0
    fi

  fi

  # Check if the command is 'tranches'
  if [[ ${arg} == "tranches" ]]; then
    # Increment index to get the flag
    ((i++))
    arg=${!i,,}

    # Check if '--chain' flag is passed
    if [[ ${arg} == "--chain" ]]; then
      # Increment index to get the chain name
      ((i++))
      chain=${!i}

      estimate_tranches ${chain}

      exit 0
    fi

    # Check if '--all' flag is passed
    if [[ ${arg} == "--all" ]]; then
      for chain in "${!supported_chains[@]}"; do
        estimate_tranches ${chain}
      done

      exit 0
    fi
  fi

done
