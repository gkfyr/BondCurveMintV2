# Mint Club V2
The inherited token creator employs a bonding curve to generate new tokens using base tokens as collateral

## Contract addresses 📜
### Ethereum Sepolia Testnet
- MCV2_Token: [0x469F0c719bbD71686087dF42336E208617a7AD77](https://sepolia.etherscan.io/address/0x469F0c719bbD71686087dF42336E208617a7AD77#code)
- MCV2_MultiToken: [0xa26Ed6D99696408cb12f3490F9A12F8E4A580cFc](https://sepolia.etherscan.io/address/0xa26Ed6D99696408cb12f3490F9A12F8E4A580cFc#code)
- MCV2_Bond: [0x9e32d918CD91989C70C9c36F7ea66Df03f9fa864](https://sepolia.etherscan.io/address/0x9e32d918CD91989C70C9c36F7ea66Df03f9fa864#code)
- Locker: [0xA5f922Ce1992665B4B93D1Ee32BFb6C33F513550](https://sepolia.etherscan.io/address/0xA5f922Ce1992665B4B93D1Ee32BFb6C33F513550#code)
- MerkleDistributor: [0x8F4C6Bc7B47D9d54b4B698Dc5DE1D087386f4161](https://sepolia.etherscan.io/address/0x8F4C6Bc7B47D9d54b4B698Dc5DE1D087386f4161#code)

## Design Choices 📐

### Discrete Bonding Curve
Unlike Mint Club V1's linear bonding curve (`y = x` -> `total supply = token price`), the V2 contract uses a custom increasing price step array for the following reasons:
1. Utilizing `y = ax^b` bonding curves is challenging to test because we have to use approximation to calculate the power function of `(_baseN / _baseD) ^ (_expN / _expD)` ([Reference: Banchor's Bonding Curve implementation](https://github.com/relevant-community/bonding-curve/blob/master/contracts/Power.sol))
2. Employing a single bonding curve is hard to customize. Supporting various types of curve functions (e.g., Sigmoid, Logarithm, etc) might be too difficult to implement in Solidity, or even impossible in many cases
3. Therefore, we decided to use an array of price steps (called `BondStep[] { rangeTo, price }`), that is simple to calculate and fully customizable.

#### An example of a price step array:
![image](https://github.com/Steemhunt/mint.club-v2-contract/assets/1332279/d61607a2-39cc-433a-8cd2-3bbb627ab2aa)

Parameters:
- maxSupply: 10,000
- stepRanges: [ 1000, 1600, 2200, 2800, ..., 10000 ]
- stepPrices: [ 2, 2.1, 2.3, 2.7, ..., 10 ]

### Custom ERC20 Tokens as Reserve Tokens
Some ERC20 tokens incorporate tax or rebasing functionalities, which could lead to unforeseen behaviors in our Bond contract. For instance, a taxed token might result in the undercollateralization of the reserve token, preventing the complete refund of minted tokens from the bond contract. A similar scenario could occur with Rebase Tokens, as they are capable of altering the balance within the Bond contract.

Due to the diverse nature of custom cases, it is impractical for our bond contract to address all of them. Therefore, we have chosen not to handle these cases explicitly. It's important to note that any behavior stemming from the custom ERC20 token is not considered a bug, as it is a consequence of the token's inherent code.

We plan to issue warnings on our official front-end for tokens known to potentially disrupt our bond contract. However, **it's crucial for users to conduct their own research and understand the potential implications of selecting a specific reserve token.**

## Run Tests 🧪
```bash
npx hardhat test
```

### Coverage ☂️
TODO: FIXME
```m
------------------------|----------|----------|----------|----------|----------------|
File                    |  % Stmts | % Branch |  % Funcs |  % Lines |Uncovered Lines |
------------------------|----------|----------|----------|----------|----------------|
 contracts/             |    98.05 |    89.52 |    93.75 |    98.29 |                |
  Locker.sol            |    94.74 |      100 |       75 |     96.3 |        136,140 |
  MCV2_Bond.sol         |      100 |       92 |      100 |    99.43 |            237 |
  MCV2_ICommonToken.sol |      100 |      100 |      100 |      100 |                |
  MCV2_MultiToken.sol   |      100 |    58.33 |      100 |      100 |                |
  MCV2_Royalty.sol      |      100 |      100 |      100 |      100 |                |
  MCV2_Token.sol        |      100 |       50 |      100 |      100 |                |
  MerkleDistributor.sol |    94.92 |    90.38 |    85.71 |     96.3 |    145,236,240 |
------------------------|----------|----------|----------|----------|----------------|
All files               |    98.05 |    89.52 |    93.75 |    98.29 |                |
------------------------|----------|----------|----------|----------|----------------|
```

## Deploy 🚀
```bash
npx hardhat compile && HARDHAT_NETWORK=ethsepolia node scripts/deploy.js
```

## Gas Consumption ⛽️
```m
·---------------------------------------------------|---------------------------|---------------|-----------------------------·
|               Solc version: 0.8.20                ·  Optimizer enabled: true  ·  Runs: 50000  ·  Block limit: 30000000 gas  │
····················································|···························|···············|······························
|  Methods                                          ·                15 gwei/gas                ·       2053.34 usd/eth       │
······················|·····························|·············|·············|···············|···············|··············
|  Contract           ·  Method                     ·  Min        ·  Max        ·  Avg          ·  # calls      ·  usd (avg)  │
······················|·····························|·············|·············|···············|···············|··············
|  Locker             ·  createLockUp               ·     118370  ·     177070  ·       147556  ·           40  ·       4.54  │
······················|·····························|·············|·············|···············|···············|··············
|  Locker             ·  unlock                     ·      65443  ·      66700  ·        66002  ·            9  ·       2.03  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Bond          ·  burn                       ·      89620  ·     128860  ·       111123  ·           41  ·       3.42  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Bond          ·  claimRoyalties             ·          -  ·          -  ·        80118  ·            3  ·       2.47  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Bond          ·  createMultiToken           ·     388360  ·     489563  ·       484210  ·           87  ·      14.91  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Bond          ·  createToken                ·     318320  ·     521850  ·       513903  ·          106  ·      15.83  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Bond          ·  mint                       ·     104331  ·     210070  ·       187135  ·           93  ·       5.76  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Bond          ·  updateBondCreator          ·      28439  ·      31251  ·        30312  ·           12  ·       0.93  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Bond          ·  updateProtocolBeneficiary  ·          -  ·          -  ·        28995  ·            1  ·       0.89  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_MultiToken    ·  setApprovalForAll          ·          -  ·          -  ·        48812  ·           20  ·       1.50  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_MultiToken    ·  transfer                   ·      32258  ·      36465  ·        34362  ·            2  ·       1.06  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Token         ·  approve                    ·      49012  ·      49312  ·        49194  ·           25  ·       1.52  │
······················|·····························|·············|·············|···············|···············|··············
|  MerkleDistributor  ·  claim                      ·      91750  ·      96538  ·        95202  ·           18  ·       2.93  │
······················|·····························|·············|·············|···············|···············|··············
|  MerkleDistributor  ·  createDistribution         ·     140040  ·     199492  ·       182561  ·           47  ·       5.62  │
······················|·····························|·············|·············|···············|···············|··············
|  MerkleDistributor  ·  refund                     ·          -  ·          -  ·        47595  ·            3  ·       1.47  │
······················|·····························|·············|·············|···············|···············|··············
|  TestMultiToken     ·  setApprovalForAll          ·          -  ·          -  ·        46114  ·           13  ·       1.42  │
······················|·····························|·············|·············|···············|···············|··············
|  TestToken          ·  approve                    ·      24327  ·      46611  ·        46039  ·          162  ·       1.42  │
······················|·····························|·············|·············|···············|···············|··············
|  TestToken          ·  transfer                   ·      34354  ·      51490  ·        50441  ·          111  ·       1.55  │
······················|·····························|·············|·············|···············|···············|··············
|  Deployments                                      ·                                           ·  % of limit   ·             │
····················································|·············|·············|···············|···············|··············
|  Locker                                           ·          -  ·          -  ·      1373693  ·        4.6 %  ·      42.31  │
····················································|·············|·············|···············|···············|··············
|  MCV2_Bond                                        ·    4139945  ·    4139969  ·      4139953  ·       13.8 %  ·     127.51  │
····················································|·············|·············|···············|···············|··············
|  MCV2_MultiToken                                  ·          -  ·          -  ·      1809793  ·          6 %  ·      55.74  │
····················································|·············|·············|···············|···············|··············
|  MCV2_Token                                       ·          -  ·          -  ·       850499  ·        2.8 %  ·      26.20  │
····················································|·············|·············|···············|···············|··············
|  MerkleDistributor                                ·          -  ·          -  ·      2099515  ·          7 %  ·      64.67  │
····················································|·············|·············|···············|···············|··············
|  TestMultiToken                                   ·    1380918  ·    1380930  ·      1380924  ·        4.6 %  ·      42.53  │
····················································|·············|·············|···············|···············|··············
|  TestToken                                        ·     659419  ·     679683  ·       678180  ·        2.3 %  ·      20.89  │
·---------------------------------------------------|-------------|-------------|---------------|---------------|-------------·
```
