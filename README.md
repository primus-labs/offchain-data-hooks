

Under developing...


## Overview



## Install

Get the repo:

```sh
git clone --recursive https://github.com/pado-labs/pado-uniswap.git
```

### Hardhat

```sh
cd pado-uniswap
npm install
npm run compile
```


### Foundry

```sh
cd pado-uniswap
forge install
forge update v4-periphery
```


## Local


## KYC on Sepolia

Summary of the modify position calls (AddLiquidity):

![KYC Modify Summary](./docs/sepolia/AddLiquidity.svg)

Summary of the swap calls (Swap):

![KYC Swap Summary](./docs/sepolia/Swap.svg)

The swap value flows:

![KYC Swap Value Flows](./docs/sepolia/SwapValueFlow.svg)

