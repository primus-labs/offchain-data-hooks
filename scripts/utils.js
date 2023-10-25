require('dotenv').config({ path: '.address' })
const {
  TOKEN0, TOKEN1, KYC_HOOK
} = process.env;

function getPoolKey() {
  const HOOK_SWAP_FEE_FLAG = 0x400000;
  const HOOK_WITHDRAW_FEE_FLAG = 0x200000;
  const poolKey = {
    currency0: TOKEN0,
    currency1: TOKEN1,
    fee: HOOK_SWAP_FEE_FLAG | HOOK_WITHDRAW_FEE_FLAG | 3000,
    tickSpacing: 60,
    hooks: KYC_HOOK,
  };
  return poolKey;
}

module.exports = {
  getPoolKey: getPoolKey
};