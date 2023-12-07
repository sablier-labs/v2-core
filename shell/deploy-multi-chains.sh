
#!/usr/bin/env bash

# Usage: ./shell/deploy-multi-chains.sh [options] [chain1 [chain2 ...]]
# Options:
#  --deterministic Deploy using the deterministic script.
#  --broadcast Broadcast the deployment and verify on Etherscan.
# Example: ./shell/deploy-multi-chains.sh # Default deploys only to Sepolia
# Example: ./shell/deploy-multi-chains.sh --broadcast arbitrum_one mainnet
# Example: ./shell/deploy-multi-chains.sh --deterministic --broadcast mainnet

# Make sure you set-up your .env file first. See .env.example.

# Pre-requisites:
# - foundry (https://getfoundry.sh)

# Strict mode: https://gist.github.com/vncsna/64825d5609c146e80de8b1fd623011ca
set -euo pipefail

# Create deployments directory
deployments=./deployments
rm -rf $deployments
mkdir $deployments

# Declare chain IDs
ARBITRUM_CHAIN_ID="42161"
AVALANCHE_CHAIN_ID="43114"
BASE_CHAIN_ID="8453"
BSC_CHAIN_ID="56"
GOERLI_CHAIN_ID="5"
GNOSIS_CHAIN_ID="100"
MAINNET_CHAIN_ID="1"
OPTIMISM_CHAIN_ID="10"
POLYGON_CHAIN_ID="137"
SCROLL_CHAIN_ID="534352"
SEPOLIA_CHAIN_ID="11155111"

echo $BASH_VERSION

# Define chain configurations
declare -A chains
chains["arbitrum_one"]="$ARBITRUM_RPC_URL $ARBISCAN_API_KEY $ARBITRUM_CHAIN_ID $ARBITRUM_ADMIN"
chains["avalanche"]="$AVALANCHE_RPC_URL $SNOWTRACE_API_KEY $AVALANCHE_CHAIN_ID $AVALANCHE_ADMIN"
chains["base"]="$BASE_RPC_URL $BASESCAN_API_KEY $BASE_CHAIN_ID $BASE_ADMIN"
chains["bnb_smart_chain"]="$BSC_RPC_URL $BSCSCAN_API_KEY $BSC_CHAIN_ID $BSC_ADMIN"
chains["gnosis"]="$GNOSIS_RPC_URL $GNOSISSCAN_API_KEY $GNOSIS_CHAIN_ID $GNOSIS_ADMIN"
chains["mainnet"]="$MAINNET_RPC_URL $ETHERSCAN_API_KEY $MAINNET_CHAIN_ID $MAINNET_ADMIN"
chains["optimism"]="$OPTIMISM_RPC_URL $OPTIMISTIC_API_KEY $OPTIMISM_CHAIN_ID $OPTIMISM_ADMIN"
chains["polygon"]="$POLYGON_RPC_URL $POLYGONSCAN_API_KEY $POLYGON_CHAIN_ID $POLYGON_ADMIN"
chains["scroll"]="$SCROLL_RPC_URL $SCROLL_API_KEY $SCROLL_CHAIN_ID $SCROLL_ADMIN"
chains["sepolia"]="$SEPOLIA_RPC_URL $ETHERSCAN_API_KEY $SEPOLIA_CHAIN_ID $SEPOLIA_ADMIN"

# Flag for broadcast deployment
BROADCAST_DEPLOYMENT=false

# Flag for deterministic deployment
DETERMINISTIC_DEPLOYMENT=false

# Flag for gas price
WITH_GAS_PRICE=false
GAS_PRICE=0

# Requested chains
requested_chains=()

# Check for arguments passed to the script
for ((i=1; i<=$#; i++)); do
    arg=${!i}

    # Check for '--broadcast' flag in the arguments
    if [[ $arg == "--broadcast" ]]; then
        BROADCAST_DEPLOYMENT=true
    fi

    # Check for '--broadcast' flag in the arguments
    if [[ $arg == "--deterministic" ]]; then
        DETERMINISTIC_DEPLOYMENT=true
    fi      

    # Check for '--with-gas-price' flag in the arguments
    if [[ $arg == "--with-gas-price" ]]; then
        WITH_GAS_PRICE=true
        # Increment index to get the next argument, which should be the gas price
        ((i++))
        GAS_PRICE=${!i}
        if ! [[ $GAS_PRICE =~ ^[0-9]+$ ]]; then
            echo "Error: Gas price must be a number."
            exit 1
        fi
    fi

    # Check for '--all' flag in the arguments
    if [[ $arg == "--all" ]]; then
        requested_chains=("${!chains[@]}")
    fi

    # Check for passed chains
    if [[ $arg != "--all" && $arg != "--deterministic" && $arg != "--broadcast"  && $arg != "--with-gas-price" ]]; then
        requested_chains+=("$arg")
    fi
done

# Set the default chain to Sepolia if no chains are requested
if [ ${#requested_chains[@]} -eq 0 ]; then
    requested_chains=("sepolia")
fi

# Compile the contracts
echo "Compiling the contracts..."
FOUNDRY_PROFILE=optimized forge build

# Deploy to requested chains
for chain in "${requested_chains[@]}"; do
    # Check if the requested chain is defined
    if [[ ! -v "chains[$chain]" ]]; then
        echo "Chain configuration for '$chain' not found."
        continue
    fi

    # Split the configuration into RPC, API key, Chain ID and the admin address
    IFS=' ' read -r rpc_url api_key chain_id admin <<< "${chains[$chain]}"

    # Declare a deployment command
    deployment_command="";

    # Choose the script based on the flag
    if [[ $DETERMINISTIC_DEPLOYMENT == true ]]; then
        echo "Deploying deterministic contracts to $chain..."
        # Construct the command
        deployment_command="forge script script/DeployDeterministicCore.s.sol \
        --rpc-url $rpc_url \
        --sig run(string,address,uint256) \
        \"ChainID $chain_id, Version 1.1.0\" \
        $admin \
        $MAX_SEGMENTS_COUNT \
        -vv"
    else
        echo "Deploying contracts to $chain..."
        # Construct the command
        deployment_command="forge script script/DeployCore.s.sol \
        --rpc-url $rpc_url \
        --sig run(address,uint256) \
        $admin \
        $MAX_SEGMENTS_COUNT \
        -vv"
    fi

    # Append additional options if broadcast is enabled
    if [[ $BROADCAST_DEPLOYMENT == true ]]; then    
        echo "This deployment is broadcasted on $chain"
        deployment_command+=" --broadcast --verify --etherscan-api-key \"$api_key\""
    fi

    # Append additional options if gas price is enabled
    if [[ $WITH_GAS_PRICE == true ]]; then
        gas_price_in_gwei=$(echo "scale=2; $GAS_PRICE / 1000000000" | bc)
        echo "This deployment is using gas price of $gas_price_in_gwei gwei"
        deployment_command+=" --with-gas-price $GAS_PRICE"
    fi

    # Run the deployment command
    output=$(FOUNDRY_PROFILE=optimized $deployment_command)

    # Create a file for the chain
    chain_file="$deployments/$chain.txt"
    touch "$chain_file"

    # Extract and save contract addresses
    comptroller_address=$(echo "$output" | awk '/comptroller: contract/{print $NF}')
    lockupDynamic_address=$(echo "$output" | awk '/lockupDynamic: contract/{print $NF}')
    lockupLinear_address=$(echo "$output" | awk '/lockupLinear: contract/{print $NF}')
    nftDescriptor_address=$(echo "$output" | awk '/nftDescriptor: contract/{print $NF}')

    # Save to the chain file
    {
        echo "SablierV2Comptroller = $comptroller_address"
        echo "SablierV2LockupDynamic = $lockupDynamic_address"
        echo "SablierV2LockupLinear = $lockupLinear_address"
        echo "SablierV2NFTDescriptor = $nftDescriptor_address"
    } >> "$chain_file"

    echo "Deployment for $chain done. Addresses saved in $chain_file"
done

echo "All deployments completed."