#!/usr/bin/env bash

# Usage: ./shell/deploy-multi-chain.sh chain
#   Enters interactive mode if .env.deployment not found
# Examples:
#  Generate deployment command for Ethereum: ./shell/deploy-multi-chain.sh ethereum
#  Generate deployment command for Arbitrum: ./shell/deploy-multi-chain.sh arbitrum

# Pre-requisites:
# - bash >=4.0.0
# - foundry (https://getfoundry.sh)

# Strict mode: https://gist.github.com/vncsna/64825d5609c146e80de8b1fd623011ca
set -euo pipefail

# Color codes
EC='\033[0;31m' # Error Color
IC='\033[0;36m' # Info Color
NC='\033[0m' # No Color
SC='\033[0;32m' # Success Color
WC='\033[0;33m' # Warn Color

# Unicode characters for tick
TICK="\xE2\x9C\x94"

# Check: Bash >=4.0.0 is required for associative arrays
if ((BASH_VERSINFO[0] < 4)); then
    echo -e "${EC}Error:\nThis script requires Bash version 4.0.0 or higher.
    \nYou are currently using Bash version ${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}.${BASH_VERSINFO[2]}.
    \nPlease upgrade your Bash version and try again.${NC}"
    exit 1
fi

# Addressed taken from https://docs.sablier.com/contracts/v2/deployments
ARBITRUM_COMPTROLLER="0x17Ec73692F0aDf7E7C554822FBEAACB4BE781762"
ARBITRUM_SEPOLIA_COMPTROLLER="0xA6A0cfA3442053fbB516D55205A749Ef2D33aed9"
AVALANCHE_COMPTROLLER="0x66F5431B0765D984f82A4fc4551b2c9ccF7eAC9C"
BASE_COMPTROLLER="0x7Faaedd40B1385C118cA7432952D9DC6b5CbC49e"
BSC_COMPTROLLER="0x33511f69A784Fd958E6713aCaC7c9dCF1A5578E8"
GNOSIS_COMPTROLLER="0x73962c44c0fB4cC5e4545FB91732a5c5e87F55C2"
MAINNET_COMPTROLLER="0xC3Be6BffAeab7B297c03383B4254aa3Af2b9a5BA"
OPTIMISM_COMPTROLLER="0x1EECb6e6EaE6a1eD1CCB4323F3a146A7C5443A10"
POLYGON_COMPTROLLER="0x9761692EDf10F5F2A69f0150e2fd50dcecf05F2E"
SCROLL_COMPTROLLER="0x859708495E3B3c61Bbe19e6E3E1F41dE3A5C5C5b"
SEPOLIA_COMPTROLLER="0x2006d43E65e66C5FF20254836E63947FA8bAaD68"

# Declare the chain IDs
ARBITRUM_CHAIN_ID="42161"
ARBITRUM_SEPOLIA_CHAIN_ID="421614"
AVALANCHE_CHAIN_ID="43114"
BASE_CHAIN_ID="8453"
BSC_CHAIN_ID="56"
GNOSIS_CHAIN_ID="100"
MAINNET_CHAIN_ID="1"
OPTIMISM_CHAIN_ID="10"
POLYGON_CHAIN_ID="137"
SCROLL_CHAIN_ID="534352"
SEPOLIA_CHAIN_ID="11155111"

# Check if exactly one argument was passed
if [ $# -ne 1 ]; then
    echo -e "\n${EC}Error: more than one argument${NC}"
    echo -e "\nUsage: ./generate-deployment-command.sh [chain]\n"
    exit 1
fi

# Convert the argument to lowercase
arg=${1,,}

# if ethereum is requested, use mainnet
if [[ $arg == "ethereum" ]]; then
  arg="mainnet"
fi

# Flag to enter interactive mode in case .env.deployment not found
INTERACTIVE=false

# Declare the chains array
declare -A chains

if [ -f .env.deployment ]; then
    # Source the .env.deployment file to load the variables
    source .env.deployment

    # Define the chain configurations
    chains["arbitrum"]="$ARBITRUM_RPC_URL $ARBISCAN_API_KEY $ARBITRUM_CHAIN_ID $ARBITRUM_ADMIN $ARBITRUM_COMPTROLLER"
    chains["arbitrum_sepolia"]="$ARBITRUM_SEPOLIA_RPC_URL $ARBISCAN_API_KEY $ARBITRUM_SEPOLIA_CHAIN_ID $ARBITRUM_SEPOLIA_ADMIN $ARBITRUM_SEPOLIA_COMPTROLLER"
    chains["avalanche"]="$AVALANCHE_RPC_URL $SNOWTRACE_API_KEY $AVALANCHE_CHAIN_ID $AVALANCHE_ADMIN $AVALANCHE_COMPTROLLER"
    chains["base"]="$BASE_RPC_URL $BASESCAN_API_KEY $BASE_CHAIN_ID $BASE_ADMIN $BASE_COMPTROLLER"
    chains["bnb_smart_chain"]="$BSC_RPC_URL $BSCSCAN_API_KEY $BSC_CHAIN_ID $BSC_ADMIN $BSC_COMPTROLLER"
    chains["gnosis"]="$GNOSIS_RPC_URL $GNOSISSCAN_API_KEY $GNOSIS_CHAIN_ID $GNOSIS_ADMIN $GNOSIS_COMPTROLLER"
    chains["mainnet"]="$MAINNET_RPC_URL $ETHERSCAN_API_KEY $MAINNET_CHAIN_ID $MAINNET_ADMIN $MAINNET_COMPTROLLER"
    chains["optimism"]="$OPTIMISM_RPC_URL $OPTIMISTIC_API_KEY $OPTIMISM_CHAIN_ID $OPTIMISM_ADMIN $OPTIMISM_COMPTROLLER"
    chains["polygon"]="$POLYGON_RPC_URL $POLYGONSCAN_API_KEY $POLYGON_CHAIN_ID $POLYGON_ADMIN $POLYGON_COMPTROLLER"
    chains["sepolia"]="$SEPOLIA_RPC_URL $ETHERSCAN_API_KEY $SEPOLIA_CHAIN_ID $SEPOLIA_ADMIN $SEPOLIA_COMPTROLLER"
    chains["scroll"]="$SCROLL_RPC_URL $SCROLLSCAN_API_KEY $SCROLL_CHAIN_ID $SCROLL_ADMIN $SCROLL_COMPTROLLER"
else
    # Set bool to enter intaractive mode
    INTERACTIVE=true

    # Define the chain configurations
    chains["arbitrum"]="$ARBITRUM_CHAIN_ID $ARBITRUM_COMPTROLLER"
    chains["arbitrum_sepolia"]="$ARBITRUM_SEPOLIA_CHAIN_ID $ARBITRUM_SEPOLIA_COMPTROLLER"
    chains["avalanche"]="$AVALANCHE_CHAIN_ID $AVALANCHE_COMPTROLLER"
    chains["base"]="$BASE_CHAIN_ID $BASE_COMPTROLLER"
    chains["bnb_smart_chain"]="$BSC_CHAIN_ID $BSC_COMPTROLLER"
    chains["gnosis"]="$GNOSIS_CHAIN_ID $GNOSIS_COMPTROLLER"
    chains["mainnet"]="$MAINNET_CHAIN_ID $MAINNET_COMPTROLLER"
    chains["optimism"]="$OPTIMISM_CHAIN_ID $OPTIMISM_COMPTROLLER"
    chains["polygon"]="$POLYGON_CHAIN_ID $POLYGON_COMPTROLLER"
    chains["sepolia"]="$SEPOLIA_CHAIN_ID $SEPOLIA_COMPTROLLER"
    chains["scroll"]="$SCROLL_CHAIN_ID $SCROLL_COMPTROLLER"
fi

# Check if the provided chain is defined
if [[ ! -v "chains[$arg]" ]]; then
    echo -e "\n${EC}Invalid chain: Chain configuration for '$arg' not found.${NC}"
    exit 1
fi

# Check for arguments passed to the script
if [[ $INTERACTIVE == true ]]; then
    # load values from the terminal prompt
    echo -e "${WC}.env.deployment missing, entering interactive mode.... ${NC}\n"
    echo -e "1. Enter RPC URL: \c"
    read rpc_url

    echo -e "2. Enter etherscan API key: \c"
    read api_key

    echo -e "3. Enter admin address: \c"
    read admin

    echo -e "4. Enter max segment: \c"
    read MAX_SEGMENT_COUNT

    echo -e "5. Using deterministic script? (yes/no): \c"
    read IS_DETERMINISTIC

    # Get the values from the chains array
    IFS=' ' read -r chain_id comptroller <<< "${chains[$arg]}"
else
    # load values from the terminal prompt
    echo -e "Using deterministic script? (yes/no): \c"
    read IS_DETERMINISTIC

    # Get the values from the chains array
    IFS=' ' read -r rpc_url api_key chain_id admin comptroller <<< "${chains[$arg]}"
fi

# Convert to lower case
IS_DETERMINISTIC=${IS_DETERMINISTIC,,}

if [[ $IS_DETERMINISTIC == "yes" || $IS_DETERMINISTIC == "y" ]]; then
    # Construct the command
    deployment_command="forge script script/DeployDeterministicCore3.s.sol"
    deployment_command+=" --rpc-url $rpc_url"
    deployment_command+=" --sig \"run(string,address,address,uint256)\""
    deployment_command+=" \"ChainID ${chain_id}, Version 1.1.1\""
    deployment_command+=" $admin"
    deployment_command+=" $comptroller"
    deployment_command+=" $MAX_SEGMENT_COUNT"
    deployment_command+=" -vvv --broadcast --verify --etherscan-api-key $api_key"

    # print deployment_command
    echo -e "\n${SC}$deployment_command${NC}"
elif [[ $IS_DETERMINISTIC == "no" || $IS_DETERMINISTIC == "n" ]]; then
    # Construct the command
    deployment_command="forge script script/DeployCore3.s.sol"
    deployment_command+=" --rpc-url $rpc_url"
    deployment_command+=" --sig \"run(address,address,uint256)\""
    deployment_command+=" $admin"
    deployment_command+=" $comptroller"
    deployment_command+=" $MAX_SEGMENT_COUNT"
    deployment_command+=" -vvv --broadcast --verify --etherscan-api-key $api_key"

    # print deployment_command
    echo -e "\n${SC}$deployment_command${NC}"
else
    echo -e "\n${EC}Invalid input: please enter 'yes', 'no', 'y', or 'n'.${NC}"
fi
