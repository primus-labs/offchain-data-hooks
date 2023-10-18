#!/bin/bash
set -x

. ./scripts/x_comm.sh "$@"

# Factory
if [ ! "$(grep 'KYC_HOOK_FACTORY' $keyfile)" ]; then
  forge create --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    src/hooks/KYCHook.sol:KYCFactory >$tmpfile

  b=$(grep 'Deployed to' $tmpfile)
  if [ ! "$b" ]; then
    echo "KYC_HOOK_FACTORY failed"
    exit 1
  fi
  deployedto=$(cat $tmpfile | awk -F: '/Deployed to/{print $2}' | sed 's/ //')
  export KYC_HOOK_FACTORY=$deployedto

  echo "KYC_HOOK_FACTORY=$KYC_HOOK_FACTORY" >>$keyfile
else
  export KYC_HOOK_FACTORY=$(cat $keyfile | awk -F= '/KYC_HOOK_FACTORY/{print $2}')
fi

# Hook
export schemaKyc=0x5f868b117fd34565f3626396ba91ef0c9a607a0e406972655c5137c6d4291af9
export schemaCountry=0x5f868b117fd34565f3626396ba91ef0c9a607a0e406972655c5137c6d4291af9
if [ ! "$(grep 'KYC_HOOK_ADDRESS' $keyfile)" ]; then
  cast call $KYC_HOOK_FACTORY \
    "mineDeploy(address,address,address,bytes32,bytes32)" \
    $POOL_MGR_ADDRESS $EASPROXY_ADDRESS $EAS_ADDRESS $schemaKyc $schemaCountry \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY >$tmpfile

  b=$(grep '0x000000000000000000000000' $tmpfile)
  if [ ! "$b" ]; then
    echo "KYC_HOOK_ADDRESS failed"
    exit 1
  fi
  deployedto=$(cat $tmpfile | grep "0x000000000000000000000000")
  deployedto=$(expr substr "$deployedto" 27 40)
  export KYC_HOOK_ADDRESS=0x$deployedto

  echo "KYC_HOOK_ADDRESS=$KYC_HOOK_ADDRESS" >>$keyfile
else
  export KYC_HOOK_ADDRESS=$(cat $keyfile | awk -F= '/KYC_HOOK_ADDRESS/{print $2}')
fi

# Test
forge create --rpc-url $RPC_URL \
  --constructor-args $POOL_MGR_ADDRESS $KYC_HOOK_ADDRESS $MTK1 $MTK2 $V4_CALLER \
  --private-key $PRIVATE_KEY \
  src/MyKYC.sol:MyKYC
