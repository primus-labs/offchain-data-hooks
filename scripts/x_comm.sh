#!/bin/bash
network=${1:-"local"} # local, seoplia
echo $#

set -x
# You should set RPC_URL, PRIVATE_KEY, DEPLOYER first

if [ "$network" = "local" ]; then
  # local test
  export RPC_URL=http://localhost:8545
  export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
  export DEPLOYER=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
  export POOL_MGR_ADDRESS=0x5FbDB2315678afecb367f032d93F642f64180aa3
  tmpfile=.tmp.local
  keyfile=.key.local
elif [ "$network" = "seoplia" ]; then
  export RPC_URL=$(cat .env | awk -F= '/RPC_URL/{print $2}')
  export PRIVATE_KEY=$(cat .env | awk -F= '/PRIVATE_KEY/{print $2}')
  export DEPLOYER=$(cat .env | awk -F= '/DEPLOYER/{print $2}')
  export POOL_MGR_ADDRESS=$(cat .env | awk -F= '/POOL_MGR_ADDRESS/{print $2}')
  tmpfile=.tmp.seoplia
  keyfile=.key.seoplia
else
  echo "invalid network"
  exit 1
fi

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

export EAS_ADDRESS=0xC2679fBD37d54388Ce493F1DB75320D236e1815e
export EASPROXY_ADDRESS=0xb53F5BcB421B0aE0f0d2a16D3f7531A8d00f63aC
export MaxAmount=0xffffffffffffffffffffffffffffffff

if [ ! "$(grep 'MTK1' $keyfile)" ]; then
  forge create --rpc-url $RPC_URL \
    --constructor-args "My Token 1" "MTK1" $MaxAmount \
    --private-key $PRIVATE_KEY \
    src/MyToken.sol:MyToken >$tmpfile

  b=$(grep 'Deployed to' $tmpfile)
  if [ ! "$b" ]; then
    echo "MTK1 failed"
    exit 1
  fi
  deployedto=$(cat $tmpfile | awk -F: '/Deployed to/{print $2}' | sed 's/ //')
  export MTK1=$deployedto
  echo "MTK1=$MTK1" >>$keyfile
else
  export MTK1=$(cat $keyfile | awk -F= '/MTK1/{print $2}')
fi

# cast call $MTK1 \
#   "balanceOf(address)(uint256)" \
#   $DEPLOYER --rpc-url $RPC_URL

if [ ! "$(grep 'MTK2' $keyfile)" ]; then
  forge create --rpc-url $RPC_URL \
    --constructor-args "My Token 2" "MTK2" $MaxAmount \
    --private-key $PRIVATE_KEY \
    src/MyToken.sol:MyToken >$tmpfile

  b=$(grep 'Deployed to' $tmpfile)
  if [ ! "$b" ]; then
    echo "MTK2 failed"
    exit 1
  fi
  deployedto=$(cat $tmpfile | awk -F: '/Deployed to/{print $2}' | sed 's/ //')
  export MTK2=$deployedto
  echo "MTK2=$MTK2" >>$keyfile
else
  export MTK2=$(cat $keyfile | awk -F= '/MTK2/{print $2}')
fi

# cast call $MTK2 \
#   "balanceOf(address)(uint256)" \
#   $DEPLOYER --rpc-url $RPC_URL

if [ "$MTK1" \> "$MTK2" ]; then
  mtkx=$MTK1
  export MTK1=$MTK2
  export MTK2=$mtkx
fi

if [ ! "$(grep 'ROUTER_LIBRARY' $keyfile)" ]; then
  forge create --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    src/router/UniswapV4RouterLibrary.sol:UniswapV4RouterLibrary >$tmpfile

  b=$(grep 'Deployed to' $tmpfile)
  if [ ! "$b" ]; then
    echo "ROUTER_LIBRARY failed"
    exit 1
  fi
  deployedto=$(cat $tmpfile | awk -F: '/Deployed to/{print $2}' | sed 's/ //')
  export ROUTER_LIBRARY=$deployedto

  echo "ROUTER_LIBRARY=$ROUTER_LIBRARY" >>$keyfile
else
  export ROUTER_LIBRARY=$(cat $keyfile | awk -F= '/ROUTER_LIBRARY/{print $2}')
fi

if [ ! "$(grep 'V4_ROUTER' $keyfile)" ]; then
  forge create --rpc-url $RPC_URL \
    --constructor-args $POOL_MGR_ADDRESS \
    --private-key $PRIVATE_KEY \
    --libraries src/router/UniswapV4RouterLibrary.sol:UniswapV4RouterLibrary:$ROUTER_LIBRARY \
    src/router/UniswapV4Router.sol:UniswapV4Router >$tmpfile
  # # OR SET libraries = ["<path>:<lib name>:<address>"]  IN YOML
  # # ref: https://book.getfoundry.sh/reference/forge/forge-create#linker-options

  b=$(grep 'Deployed to' $tmpfile)
  if [ ! "$b" ]; then
    echo "V4_ROUTER failed"
    exit 1
  fi
  deployedto=$(cat $tmpfile | awk -F: '/Deployed to/{print $2}' | sed 's/ //')
  export V4_ROUTER=$deployedto

  echo "V4_ROUTER=$V4_ROUTER" >>$keyfile

  # approve
  cast call $MTK1 \
    "approve(address,uint256)" \
    $V4_ROUTER $MaxAmount --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY
  cast call $MTK2 \
    "approve(address,uint256)" \
    $V4_ROUTER $MaxAmount --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY
else
  export V4_ROUTER=$(cat $keyfile | awk -F= '/V4_ROUTER/{print $2}')
fi

if [ ! "$(grep 'V4_CALLER' $keyfile)" ]; then
  forge create --rpc-url $RPC_URL \
    --constructor-args $V4_ROUTER $POOL_MGR_ADDRESS \
    --private-key $PRIVATE_KEY \
    --libraries src/router/UniswapV4RouterLibrary.sol:UniswapV4RouterLibrary:$ROUTER_LIBRARY \
    src/router/UniswapV4Caller.sol:UniswapV4Caller >$tmpfile

  b=$(grep 'Deployed to' $tmpfile)
  if [ ! "$b" ]; then
    echo "V4_CALLER failed"
    exit 1
  fi
  deployedto=$(cat $tmpfile | awk -F: '/Deployed to/{print $2}' | sed 's/ //')
  export V4_CALLER=$deployedto

  echo "V4_CALLER=$V4_CALLER" >>$keyfile
else
  export V4_CALLER=$(cat $keyfile | awk -F= '/V4_CALLER/{print $2}')
fi
