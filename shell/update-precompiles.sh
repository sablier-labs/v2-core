#!/usr/bin/env bash

# Pre-requisites:
# - foundry (https://getfoundry.sh)
# - jq (https://stedolan.github.io/jq)
# - sd (https://github.com/chmln/sd)

# Strict mode: https://gist.github.com/vncsna/64825d5609c146e80de8b1fd623011ca
set -euo pipefail

# Compile the contracts with Forge
FOUNDRY_PROFILE=optimized forge build

# Retrieve the raw bytecodes, removing the "0x" prefix
batch_lockup=$(cat out-optimized/SablierBatchLockup.sol/SablierBatchLockup.json | jq -r '.bytecode.object' | cut -c 3-)
lockup=$(cat out-optimized/SablierLockup.sol/SablierLockup.json | jq -r '.bytecode.object' | cut -c 3-)
nft_descriptor=$(cat out-optimized/LockupNFTDescriptor.sol/LockupNFTDescriptor.json | jq -r '.bytecode.object' | cut -c 3-)

precompiles_path="precompiles/Precompiles.sol"
if [ ! -f $precompiles_path ]; then
    echo "Precompiles file does not exist"
    exit 1
fi

# TODO: Update these with mainnet addresses
HELPERS_LIBRARY="7715bE116061E014Bb721b46Dc78Dd57C91FDF9b"
VESTINGMATH_LIBRARY="26F9d826BDed47Fc472526aE8095B75ac336963C"

# Replace the placeholders in lockup bytecode with mainnet addresses of libraries
lockup=$(echo "$lockup" | sd "__\\\$70ac0b9f44f1ad43af70526685fc041161\\\$__" "$HELPERS_LIBRARY")
lockup=$(echo "$lockup" | sd "__\\\$a5f83f921acff269341ef3c300f67f6dd4\\\$__" "$VESTINGMATH_LIBRARY")

# Replace the current bytecodes
sd "(BYTECODE_BATCH_LOCKUP =)[^;]+;" "\$1 hex\"$batch_lockup\";" $precompiles_path
sd "(BYTECODE_LOCKUP =)[^;]+;" "\$1 hex\"$lockup\";" $precompiles_path
sd "(BYTECODE_NFT_DESCRIPTOR =)[^;]+;" "\$1 hex\"$nft_descriptor\";" $precompiles_path

# Reformat the code with Forge
forge fmt $precompiles_path
