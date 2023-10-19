

|                       |                                                 |
| --------------------- | ----------------------------------------------- |
| PoolManagerScript.sol | Deploy a pool manager, **only worked on local** |
| KYCScript.sol         | Deploy all KYC without pool manager             |
| KYCFromHookScript.sol | Deploy from Hook if KYCHook has updated         |
| KYCTestSwapScript.sol | Test swap                                       |
 

## Usage Local


```bash
# start anvil with a larger code limit
anvil --code-size-limit 30000
```

---

First of all, use the following scripts to depoly a pool manager

```sh
export RPC_URL=http://localhost:8545
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

forge create \
  --rpc-url $RPC_URL \
  --constructor-args 500000 \
  --private-key $PRIVATE_KEY --optimize --optimizer-runs 1 \
  lib/v4-periphery/lib/v4-core/contracts/PoolManager.sol:PoolManager

# OR

forge script script/PoolManagerScript.sol \
  --rpc-url $RPC_URL \
  --code-size-limit 30000 \
  --private-key $PRIVATE_KEY \
  --broadcast --optimize --optimizer-runs 1
```



### Deploy all KYC

**Important**:

- Comment `_checkKycResult` in `KYCHook.sol` if you want to deploy to local chain, because no eas, easproxy contract in local chain.

```sh
export RPC_URL=http://localhost:8545
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
export POOL_MANAGER=0x5FbDB2315678afecb367f032d93F642f64180aa3

export SCHEMA_KYC_BYTES=0x5f868b117fd34565f3626396ba91ef0c9a607a0e406972655c5137c6d4291af9
export SCHEMA_COUNTRY_BYTES=0x5f868b117fd34565f3626396ba91ef0c9a607a0e406972655c5137c6d4291af9
export EAS_ADDRESS=0xC2679fBD37d54388Ce493F1DB75320D236e1815e
export EASPROXY_ADDRESS=0x140Bd8EaAa07d49FD98C73aad908e69a75867336

forge script script/KYCScript.sol \
  --rpc-url $RPC_URL \
  --code-size-limit 30000 \
  --private-key $PRIVATE_KEY \
  --broadcast --optimize --optimizer-runs 1
```


### If you have updated the KYCHook

Get the `TOKENA`, `TOKENB`, `CALLER` from the above steps.

```sh
export RPC_URL=http://localhost:8545
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
export POOL_MANAGER=0x5FbDB2315678afecb367f032d93F642f64180aa3

export SCHEMA_KYC_BYTES=0x5f868b117fd34565f3626396ba91ef0c9a607a0e406972655c5137c6d4291af9
export SCHEMA_COUNTRY_BYTES=0x5f868b117fd34565f3626396ba91ef0c9a607a0e406972655c5137c6d4291af9
export EAS_ADDRESS=0xC2679fBD37d54388Ce493F1DB75320D236e1815e
export EASPROXY_ADDRESS=0x140Bd8EaAa07d49FD98C73aad908e69a75867336

export TOKENA=0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
export TOKENB=0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9
export CALLER=0x5FC8d32690cc91D4c39d9d3abcBD16989F875707

forge script script/KYCFromHookScript.sol \
  --rpc-url $RPC_URL \
  --code-size-limit 30000 \
  --private-key $PRIVATE_KEY \
  --broadcast --optimize --optimizer-runs 1
```


##


### Test 


```sh
export RPC_URL=http://localhost:8545
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

export TOKENA=0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
export TOKENB=0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9
export CALLER=0x5FC8d32690cc91D4c39d9d3abcBD16989F875707

export KYC_HOOK=0x28775FC5387D8F1a64c3Ac4c284E9CA04d69c441

# add
forge script script/KYCTestAddLiquidityScript.sol \
  --rpc-url $RPC_URL \
  --code-size-limit 30000 \
  --private-key $PRIVATE_KEY \
  --broadcast --optimize --optimizer-runs 1

# swap
forge script script/KYCTestSwapScript.sol \
  --rpc-url $RPC_URL \
  --code-size-limit 30000 \
  --private-key $PRIVATE_KEY \
  --broadcast --optimize --optimizer-runs 1
```
