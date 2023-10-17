#!/bin/bash
set -x
# You should set RPC_URL, PRIVATE_KEY, DEPLOYER first

export RPC_URL=
export PRIVATE_KEY=
export DEPLOYER=
export POOL_MGR_ADDRESS=0x64255ed21366DB43d89736EE48928b890A84E2Cb
export EAS_ADDRESS=0xC2679fBD37d54388Ce493F1DB75320D236e1815e
export EASPROXY_ADDRESS=0xb53F5BcB421B0aE0f0d2a16D3f7531A8d00f63aC
export MaxAmount=0xffffffffffffffffffffffffffffffff

if [ ! $RPC_URL ]; then
  echo "You should set RPC_URL, PRIVATE_KEY, DEPLOYER first"
  exit 1
fi
if [ ! $PRIVATE_KEY ]; then
  echo "You should set RPC_URL, PRIVATE_KEY, DEPLOYER first"
  exit 1
fi
if [ ! $DEPLOYER ]; then
  echo "You should set RPC_URL, PRIVATE_KEY, DEPLOYER first"
  exit 1
fi

# # Deployer: 0x48f760bd0678DAAF51a9417Ca68eDb210eB50104
# # Deployed to: 0x8E58CB9506edB02C602f3ACDfED9A63993671F38
# # Transaction hash: 0x0bfe9241884bf1d8f1fee2dd1cbdf3b40b6f889571e69405abf8d3a220bf5235
# forge create --rpc-url $RPC_URL \
#   --constructor-args "My Token 1" "MTK1" $MaxAmount \
#   --private-key $PRIVATE_KEY \
#   src/MyToken.sol:MyToken
export MTK1=0x8E58CB9506edB02C602f3ACDfED9A63993671F38
# cast call $MTK1 \
#   "balanceOf(address)(uint256)" \
#   $DEPLOYER --rpc-url $RPC_URL

# Deployer: 0x48f760bd0678DAAF51a9417Ca68eDb210eB50104
# Deployed to: 0x00e619cdb530f1dA5D1Dc399cD8b2832214A9C27
# Transaction hash: 0xa5199b019f8a35b15ae3f5799933cff3b0d12dee15d3a67c1fdfeb2de493370c
# forge create --rpc-url $RPC_URL \
#   --constructor-args "My Token 2" "MTK2" $MaxAmount \
#   --private-key $PRIVATE_KEY \
#   src/MyToken.sol:MyToken
export MTK2=0x00e619cdb530f1dA5D1Dc399cD8b2832214A9C27
# cast call $MTK2 \
#   "balanceOf(address)(uint256)" \
#   $DEPLOYER --rpc-url $RPC_URL

export MTK1=0x00e619cdb530f1dA5D1Dc399cD8b2832214A9C27
export MTK2=0x8E58CB9506edB02C602f3ACDfED9A63993671F38

# # Deployer: 0x48f760bd0678DAAF51a9417Ca68eDb210eB50104
# # Deployed to: 0x1eB72E540246C8a8D0455f16e44e13b7085867a7
# # Transaction hash: 0xf7ab4de615d7a5037a273574f46537711e77fa522488293a98a5a2633d3d1796
# forge create --rpc-url $RPC_URL \
#   --private-key $PRIVATE_KEY \
#   src/router/UniswapV4RouterLibrary.sol:UniswapV4RouterLibrary
export V4_ROUTER_LIBRARY=0x1eB72E540246C8a8D0455f16e44e13b7085867a7

# # Deployer: 0x48f760bd0678DAAF51a9417Ca68eDb210eB50104
# # Deployed to: 0x0fa524b2b74EC8d59Ca4515263AA9E145d2CC3eC
# # Transaction hash: 0xec21906d9b4d57e530e46b0890afc20a6c1f0ae52da78c23aa2bf7f7661faf60
# forge create --rpc-url $RPC_URL \
#   --constructor-args $POOL_MGR_ADDRESS \
#   --private-key $PRIVATE_KEY \
#   --libraries src/router/UniswapV4RouterLibrary.sol:UniswapV4RouterLibrary:$V4_ROUTER_LIBRARY \
#   src/router/UniswapV4Router.sol:UniswapV4Router
# # OR SET libraries = ["<path>:<lib name>:<address>"]  IN YOML
# # ref: https://book.getfoundry.sh/reference/forge/forge-create#linker-options
export V4_ROUTER=0x0fa524b2b74EC8d59Ca4515263AA9E145d2CC3eC

# cast call $MTK1 \
#   "approve(address,uint256)" \
#   $V4_ROUTER $MaxAmount --rpc-url $RPC_URL \
#   --private-key $PRIVATE_KEY
# cast call $MTK2 \
#   "approve(address,uint256)" \
#   $V4_ROUTER $MaxAmount --rpc-url $RPC_URL \
#   --private-key $PRIVATE_KEY

# # Deployer: 0x48f760bd0678DAAF51a9417Ca68eDb210eB50104
# # Deployed to: 0xBC0A87e573983fad513Cc6C5e342bB5865972BB6
# # Transaction hash: 0x7ed320e37a099aa8982713aa4b67decb2ef97ce5ea396225cf7fab83692a2880
# forge create --rpc-url $RPC_URL \
#   --constructor-args $V4_ROUTER $POOL_MGR_ADDRESS \
#   --private-key $PRIVATE_KEY \
#   --libraries src/router/UniswapV4RouterLibrary.sol:UniswapV4RouterLibrary:$V4_ROUTER_LIBRARY \
#   src/router/UniswapV4Caller.sol:UniswapV4Caller
export V4_CALLER=0xBC0A87e573983fad513Cc6C5e342bB5865972BB6

# Factory
# Deployer: 0x48f760bd0678DAAF51a9417Ca68eDb210eB50104
# Deployed to: 0xD8504A73AE29e4Eb3ec699050db49EC4a44B59C6
# Transaction hash: 0xad0ac7aa756456ddbd4d73ce1981b92317f5a67457a9a659e7bae37ff5d0f821
# forge create --rpc-url $RPC_URL \
#   --private-key $PRIVATE_KEY \
#   src/hooks/KYCHook.sol:KYCFactory
export HOOK_FACTORY=0xD8504A73AE29e4Eb3ec699050db49EC4a44B59C6

# Hook
# address: 0x0000000000000000000000008a2097c722a148e238cf9d5cda86e8ad277a72fd
export schemaKyc=0x5f868b117fd34565f3626396ba91ef0c9a607a0e406972655c5137c6d4291af9
export schemaCountry=0x5f868b117fd34565f3626396ba91ef0c9a607a0e406972655c5137c6d4291af9
# cast call $HOOK_FACTORY \
#   "mineDeploy(address,address,address,bytes32,bytes32)" \
#   $POOL_MGR_ADDRESS $EASPROXY_ADDRESS $EAS_ADDRESS $schemaKyc $schemaCountry \
#   --rpc-url $RPC_URL \
#   --private-key $PRIVATE_KEY
export HOOK_ADDRESS=0x8a2097c722a148e238cf9d5cda86e8ad277a72fd

forge create --rpc-url $RPC_URL \
  --constructor-args $POOL_MGR_ADDRESS $HOOK_ADDRESS $MTK1 $MTK2 $V4_CALLER \
  --private-key $PRIVATE_KEY \
  src/MyKYC.sol:MyKYC

exit 0
