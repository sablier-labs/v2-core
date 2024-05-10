#!/usr/bin/env bash

# Pre-requisites for running this script:
#
# - bun (https://bun.sh)
# - foundry (https://getfoundry.sh)

# Strict mode
set -euo pipefail

# Path to the Solidity file
BASE_SCRIPT_FILE="script/Base.s.sol"

# Compile the contracts with optimized profile
bun run build:optimized

# Generalized function to update counts in the solidity file
update_counts() {
    local test_name=$1
    local map_name=$2
    echo "Running forge test for estimating $test_name..."
    local output=$(FOUNDRY_PROFILE=benchmark forge t --mt "test_Estimate${test_name}" -vv)
    echo "Parsing output for $test_name..."

    # Parse the output to extract counts and chain IDs
    echo "$output" | grep 'count is:' | while read -r line; do
        local count=$(echo $line | awk '{print $3}')
        local chain_id=$(echo $line | awk '{print $11}')
        local formatted_chain_id=$(format_chain_id $chain_id)

        # Update the map for each chain ID using sd
        echo "Updating $map_name for chain ID $formatted_chain_id to $count"
        sd "$map_name\[$formatted_chain_id\] = [0-9_]+;" "$map_name[$formatted_chain_id] = $count;" $BASE_SCRIPT_FILE
    done
}

# Helper function to format chain IDs with underscores
format_chain_id() {
    local id=$1
    [[ ${#id} -gt 4 ]] && echo $id | rev | sed 's/\(...\)/\1_/g' | rev | sed 's/^_//' || echo $id
}

# Call the function with specific parameters for segments and tranches
update_counts "Segments" "segmentCountMap"
update_counts "Tranches" "trancheCountMap"

# Reformat the code with Forge
forge fmt $BASE_SCRIPT_FILE

echo "All mappings updated."
