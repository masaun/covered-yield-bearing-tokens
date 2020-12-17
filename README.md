# Covered Yield Bearing Token

***
## 【Introduction of Covered Yield Bearing Token】
- This is a smart contract for creating the `covered yield bearing token (CYB)` which a fully fungible token that `both yield bearing and covered` are included.

&nbsp;

***

## Setup
### ① Install modules
```
$ npm install
```

<br>

### ② Compile & migrate contracts (on Kovan testnet)
```
$ npm run migrate:kovan
```

<br>

### ③ Execute script (it's instead of testing) on Kovan testnet
- Testing for CoveredYieldBearingToken.sol (CYB Token)
```
$ npm run script:cyb
```

&nbsp;

- Testing for Distributor.sol
```
$ npm run script:distributor
```

&nbsp;

***

## 【References】
- Nexus Mutual
  - Nexus Mutual Smart Contracts: https://github.com/NexusMutual/smart-contracts/tree/master/contracts
  - Nexus Mutual docs: https://nexusmutual.gitbook.io/docs/docs
  - Nexus Mutual app: https://app.nexusmutual.io/ 
  - Nexus Mutual Smart Contracts index: https://nxm.surge.sh/ 
  - Stats: https://nexustracker.io/ 
  - Wrapped NXM (wNXM): https://etherscan.io/address/0x0d438f3b5175bebc262bf23753c1e53d03432bde#code
  - Deployed contract address
    - Deployed contract information
      https://nexusmutual.gitbook.io/docs/docs#deployed-contract-information

    - How to deploy on Kovan
      https://github.com/NexusMutual/smart-contracts#getting-started
