#!/usr/bin/env bash

# Usage: ./shell/deploy-multi-chain.sh [options] [[chain1 chain2 ...]]
# Options:
#  --all Deploy on all chains.
#  --broadcast Broadcast the deployment and verify on Etherscan.
#  --deterministic Deploy using the deterministic script.
#  --with-gas-price Specify gas price for transaction.
# Example: ./shell/deploy-multi-chain.sh # By default, deploys only to Sepolia
# Example: ./shell/deploy-multi-chain.sh --broadcast optimism mainnet
# Example: ./shell/deploy-multi-chain.sh --broadcast --deterministic mainnet

# Make sure you set-up your `.env.deployment` file first.

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

# Create deployments directory
deployments=./deployments
rm -rf $deployments
mkdir $deployments

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

# Source the .env file to load the variables
if [ -f .env.deployment ]; then
    source .env.deployment
else
    echo -e "${EC}Error: .env.deployment file not found${NC}"
    exit 1
fi

# Check: Bash >=4.0.0 is required for associative arrays
if ((BASH_VERSINFO[0] < 4)); then
    echo -e "${EC}Error:\nThis script requires Bash version 4.0.0 or higher.
    \nYou are currently using Bash version ${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}.${BASH_VERSINFO[2]}.
    \nPlease upgrade your Bash version and try again.${NC}"
    exit 1
fi

# Define the chain configurations
declare -A chains
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

# Flag for broadcast deployment
BROADCAST_DEPLOYMENT=false

# Flag for deterministic deployment
DETERMINISTIC_DEPLOYMENT=false

# Flag for gas price
GAS_PRICE=0
WITH_GAS_PRICE=false

# Flag for all chains
ON_ALL_CHAINS=false

# Provided chains
provided_chains=()

# Check for arguments passed to the script
for ((i=1; i<=$#; i++)); do
    arg=${!i}

    # Check if '--broadcast' flag is provided the arguments
    if [[ $arg == "--broadcast" ]]; then
        BROADCAST_DEPLOYMENT=true
    fi

    # Check if '--deterministic' flag is provided in the arguments
    if [[ $arg == "--deterministic" ]]; then
        DETERMINISTIC_DEPLOYMENT=true
    fi

    # Check if '--with-gas-price' flag is provided in the arguments
    if [[ $arg == "--with-gas-price" ]]; then
        WITH_GAS_PRICE=true

        # Increment index to get the next argument, which should be the gas price
        ((i++))
        GAS_PRICE=${!i}
        if ! [[ $GAS_PRICE =~ ^[0-9]+$ ]]; then
            echo -e "${EC}Error: Invalid value for --with-gas-price, must be number${NC}"
            exit 1
        fi
    fi

    # Check if '--all' flag is provided in the arguments
    if [[ $arg == "--all" ]]; then
        ON_ALL_CHAINS=true
        provided_chains=("${!chains[@]}")
    fi

    # Check for passed chains
    if [[ $arg != "--all" && $arg != "--deterministic" && $arg != "--broadcast" && $arg != "--with-gas-price" && $ON_ALL_CHAINS == false ]]; then
        provided_chains+=("$arg")
    fi
done

# Set the default chain to Sepolia if no chains are provided
if [ ${#provided_chains[@]} -eq 0 ]; then
    provided_chains=("sepolia")
fi

# Compile the contracts
echo "Compiling the contracts..."
FOUNDRY_PROFILE=optimized forge build

# Deploy to the provided chains
for chain in "${provided_chains[@]}"; do
    # Check if the provided chain is defined
    if [[ ! -v "chains[$chain]" ]]; then
        echo -e "\n${WC}Warning: Chain configuration for '$chain' not found.${NC}"
        continue
    fi

    # Split the configuration into RPC, API key, Chain ID, admin, and comptroller
    IFS=' ' read -r rpc_url api_key chain_id admin comptroller <<< "${chains[$chain]}"

    # Declare a deployment command
    declare -a deployment_command

    # Choose the script based on the flag
    if [[ $DETERMINISTIC_DEPLOYMENT == true ]]; then
        echo -e "\n${IC}Deploying deterministic contracts to $chain...${NC}"
        # Construct the command
        deployment_command=(forge script script/DeployDeterministicCore3.s.sol)
        deployment_command+=(--rpc-url "${rpc_url}")
        deployment_command+=(--sig 'run(string,address,address,uint256)')
        deployment_command+=("ChainID ${chain_id}, Version 1.1.1")
        deployment_command+=(${admin})
        deployment_command+=(${comptroller})
        deployment_command+=(${MAX_SEGMENT_COUNT})
        deployment_command+=(-vvv)
    else
        echo -e "\n${IC}Deploying contracts to $chain...${NC}"
        # Construct the command
        deployment_command=(forge script script/DeployCore3.s.sol)
        deployment_command+=(--rpc-url "${rpc_url}")
        deployment_command+=(--sig 'run(address,address,uint256)')
        deployment_command+=(${admin})
        deployment_command+=(${comptroller})
        deployment_command+=(${MAX_SEGMENT_COUNT})
        deployment_command+=(-vvv)
    fi

    # Append additional options if broadcast is enabled
    if [[ $BROADCAST_DEPLOYMENT == true ]]; then
        echo -e "${SC}+${NC} Broadcasting on $chain"
        deployment_command+=(--broadcast --verify --etherscan-api-key ${api_key})
    else
        echo -e "${SC}+${NC} Simulating on $chain"
    fi

    # Append additional options if gas price is enabled
    if [[ $WITH_GAS_PRICE == true ]]; then
        gas_price_in_gwei=$(echo "scale=2; $GAS_PRICE / 1000000000" | bc)
        echo -e "${SC}+${NC} Using gas price of $gas_price_in_gwei gwei"
        deployment_command+=(--with-gas-price ${GAS_PRICE})
    fi

    # Run the deployment command
    output=$(FOUNDRY_PROFILE=optimized "${deployment_command[@]}")

    # Create a file for the chain
    chain_file="$deployments/$chain.txt"
    touch "$chain_file"

    # Extract and save contract addresses
    lockupDynamic_address=$(echo "$output" | awk '/lockupDynamic: contract/{print $NF}')
    lockupLinear_address=$(echo "$output" | awk '/lockupLinear: contract/{print $NF}')
    nftDescriptor_address=$(echo "$output" | awk '/nftDescriptor: contract/{print $NF}')

    # Save to the chain file
    {
        echo "SablierV2LockupDynamic = $lockupDynamic_address"
        echo "SablierV2LockupLinear = $lockupLinear_address"
        echo "SablierV2NFTDescriptor = $nftDescriptor_address"
    } >> "$chain_file"

    echo -e "${SC}$TICK Deployed on $chain. You can find the addresses in $chain_file${NC}"
done

echo -e "\nAll deployments completed."
