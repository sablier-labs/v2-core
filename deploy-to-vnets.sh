## Check git (foundry.toml only)
git diff --quiet -- foundry.toml; nochanges=$?
if [ $nochanges -ne 0 ]; then
    echo "commit or clear changes from foundry.toml"
    return
fi

## run cat ~/.tenderly/config.yaml to fetch it or get it from dashboard
## https://docs.tenderly.co/account/projects/how-to-generate-api-access-token
TENDERLY_ACCESS_KEY= # TODO Replace with your private key

## place RPC URL (pick UNLOCKED not testnet from the dashboard)
RPC_URL= #  TODO replace with your UNLOCKED URL
VERIFICATION_URL=$RPC_URL/verify/etherscan

## Fund the deployer address (test test ... junk mnemonic) using the Unlimited faucet
curl $RPC_URL \
    -X POST \
    -H "Content-Type: application/json" \
    -d '{
        "jsonrpc": "2.0",
        "method": "tenderly_setBalance",
        "params": [
          "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
          "0xDE0B6B3A7640000"
        ],
        "id": "1234"
    }'

## Need the chain ID
CHAIN_ID_HEX=`curl $RPC_URL \
    -X POST \
    -H "Content-Type: application/json" \
    -d '{
      "jsonrpc": "2.0",
      "id": 0,
      "method": "eth_chainId"
}' | jq -r ".result"`

CHAIN_ID=$((${CHAIN_ID_HEX}))

echo "
[etherscan]
unknown_chain = { key = "\"$TENDERLY_ACCESS_KEY\"", chain = $CHAIN_ID, url = "\"$VERIFICATION_URL\"" }" >> foundry.toml

## TODO: Configure admin address and max segment count
ADMIN_ADDRESS=0xBd8DaA414Fda8a8A129F7035e7496759C5aF8570
MAX_SEGMENT_COUNT=3

FOUNDRY_PROFILE=optimized \
forge script script/DeployCore.s.sol \
  --broadcast \
  --rpc-url $RPC_URL \
  --sig "run(address)" \
  --verify \
  --verifier-url $VERIFICATION_URL \
  $ADMIN_ADDRESS

git checkout -- foundry.toml