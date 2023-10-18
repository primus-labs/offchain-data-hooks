#!/bin/bash
set -x

. ./scripts/x_comm.sh "$@"

# Factory
if [ ! "$(grep 'COUNTER_HOOK_FACTORY' $keyfile)" ]; then
  forge create --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    src/hooks/CounterHook.sol:CounterFactory >$tmpfile

  b=$(grep 'Deployed to' $tmpfile)
  if [ ! "$b" ]; then
    echo "COUNTER_HOOK_FACTORY failed"
    exit 1
  fi
  deployedto=$(cat $tmpfile | awk -F: '/Deployed to/{print $2}' | sed 's/ //')
  export COUNTER_HOOK_FACTORY=$deployedto

  echo "COUNTER_HOOK_FACTORY=$COUNTER_HOOK_FACTORY" >>$keyfile
else
  export COUNTER_HOOK_FACTORY=$(cat $keyfile | awk -F= '/COUNTER_HOOK_FACTORY/{print $2}')
fi

# Hook
if [ ! "$(grep 'COUNTER_HOOK_ADDRESS' $keyfile)" ]; then
  cast call $COUNTER_HOOK_FACTORY \
    "mineDeploy(address)" \
    $POOL_MGR_ADDRESS \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY >$tmpfile

  b=$(grep '0x000000000000000000000000' $tmpfile)
  if [ ! "$b" ]; then
    echo "COUNTER_HOOK_ADDRESS failed"
    exit 1
  fi
  deployedto=$(cat $tmpfile | grep "0x000000000000000000000000")
  deployedto=$(expr substr "$deployedto" 27 40)
  export COUNTER_HOOK_ADDRESS=0x$deployedto

  echo "COUNTER_HOOK_ADDRESS=$COUNTER_HOOK_ADDRESS" >>$keyfile
else
  export COUNTER_HOOK_ADDRESS=$(cat $keyfile | awk -F= '/COUNTER_HOOK_ADDRESS/{print $2}')
fi

# Test
forge create --rpc-url $RPC_URL \
  --constructor-args $POOL_MGR_ADDRESS $COUNTER_HOOK_ADDRESS $MTK1 $MTK2 $V4_CALLER \
  --private-key $PRIVATE_KEY \
  src/MyCounter.sol:MyCounter

exit 0
