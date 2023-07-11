# Mint Club V2
The inherited token creator employs a bonding curve to generate new tokens using base tokens as collateral

## Contract addresses 📜
### Ethereum Sepolia Testnet
- MCV2_Token: [0x4bF67e5C9baD43DD89dbe8fCAD3c213C868fe881](https://sepolia.etherscan.io/address/0x4bF67e5C9baD43DD89dbe8fCAD3c213C868fe881#code)
- MCV2_Bond: [0x905F3AE86108c6A3b1a345dACEaef6c4749Ec66a](https://sepolia.etherscan.io/address/0x905F3AE86108c6A3b1a345dACEaef6c4749Ec66a#code)

## Design Choices 📐
Unlike Mint Club V1's bonding curve (`y = x` -> `total supply = token price`), the V2 contract uses a custom increasing price step array for the following reasons:
1. Utilizing `y = ax^b` bonding curves is challenging to test because we have to use approximation to calculate the power function of `(_baseN / _baseD) ^ (_expN / _expD)` ([Reference: Banchor's Bonding Curve implementation](https://github.com/relevant-community/bonding-curve/blob/master/contracts/Power.sol))
2. Employing a single bonding curve is hard to customize. Supporting various types of curve functions (e.g., Sigmoid, Logarithm, etc) might be too difficult to implement in Solidity, or even impossible in many cases
3. Therefore, we decided to use an array of price steps (called `BondStep[] { rangeTo, price }`), that is simple to calculate and fully customizable.

### An example of a price step array:
[TODO: Image attached]

Parameters:
- maxSupply: 1,000,000
- stepRanges: [...]
- stepPrices: [...]

## Run Tests 🧪
```bash
npx hardhat test
```

### Coverage ☂️
```m
-------------------------|----------|----------|----------|----------|----------------|
File                     |  % Stmts | % Branch |  % Funcs |  % Lines |Uncovered Lines |
-------------------------|----------|----------|----------|----------|----------------|
 contracts/              |    91.01 |    67.57 |    78.26 |    90.98 |                |
  MCV2_Bond.sol          |    97.37 |       75 |    83.33 |    96.97 |    137,141,162 |
  MCV2_Distributor.sol   |      100 |      100 |      100 |      100 |                |
  MCV2_FeeCollector.sol  |       25 |    16.67 |    57.14 |    38.46 |... 35,37,47,55 |
  MCV2_Token.sol         |      100 |       50 |      100 |      100 |                |
 contracts/lib/          |    47.92 |    27.27 |    66.67 |       50 |                |
  ERC20Initializable.sol |    47.92 |    27.27 |    66.67 |       50 |... 297,298,299 |
 contracts/mock/         |      100 |      100 |      100 |      100 |                |
  TestToken.sol          |      100 |      100 |      100 |      100 |                |
-------------------------|----------|----------|----------|----------|----------------|
All files                |    76.09 |    58.33 |    73.81 |     77.6 |                |
-------------------------|----------|----------|----------|----------|----------------|
```

## Deploy 🚀
```bash
npx hardhat compile && HARDHAT_NETWORK=ethsepolia node scripts/deploy.js
```

## Gas Consumption ⛽️
```m
·-----------------------------|---------------------------|---------------|-----------------------------·
|    Solc version: 0.8.20     ·  Optimizer enabled: true  ·  Runs: 50000  ·  Block limit: 30000000 gas  │
······························|···························|···············|······························
|  Methods                    ·                15 gwei/gas                ·       1886.78 usd/eth       │
··············|···············|·············|·············|···············|···············|··············
|  Contract   ·  Method       ·  Min        ·  Max        ·  Avg          ·  # calls      ·  usd (avg)  │
··············|···············|·············|·············|···············|···············|··············
|  ERC20      ·  approve      ·          -  ·          -  ·        49222  ·           15  ·       1.39  │
··············|···············|·············|·············|···············|···············|··············
|  MCV2_Bond  ·  buy          ·     102102  ·     191402  ·       161747  ·           48  ·       4.58  │
··············|···············|·············|·············|···············|···············|··············
|  MCV2_Bond  ·  createToken  ·     334307  ·     523071  ·       519441  ·           52  ·      14.70  │
··············|···············|·············|·············|···············|···············|··············
|  MCV2_Bond  ·  sell         ·      99839  ·     115103  ·       106124  ·           17  ·       3.00  │
··············|···············|·············|·············|···············|···············|··············
|  TestToken  ·  approve      ·      46243  ·      46255  ·        46244  ·           32  ·       1.31  │
··············|···············|·············|·············|···············|···············|··············
|  TestToken  ·  transfer     ·      51373  ·      51385  ·        51374  ·           32  ·       1.45  │
··············|···············|·············|·············|···············|···············|··············
|  Deployments                ·                                           ·  % of limit   ·             │
······························|·············|·············|···············|···············|··············
|  MCV2_Bond                  ·          -  ·          -  ·      2407284  ·          8 %  ·      68.13  │
······························|·············|·············|···············|···············|··············
|  MCV2_Token                 ·          -  ·          -  ·      1064865  ·        3.5 %  ·      30.14  │
······························|·············|·············|···············|···············|··············
|  TestToken                  ·          -  ·          -  ·       758959  ·        2.5 %  ·      21.48  │
·-----------------------------|-------------|-------------|---------------|---------------|-------------·
```
