# Mint Club V2
The inherited token creator employs a bonding curve to generate new tokens using base tokens as collateral

## Contract addresses 📜
### Ethereum Sepolia Testnet
- MCV2_Token: [0xF4567Fc564Bfd23F50Fe092f65146CAf7266d241](https://sepolia.etherscan.io/address/0xF4567Fc564Bfd23F50Fe092f65146CAf7266d241#code)
- MCV2_Bond: [0xAD5a113ee65F30269f7558f96483126B1FB60c4E](https://sepolia.etherscan.io/address/0xAD5a113ee65F30269f7558f96483126B1FB60c4E#code)
- Locker: [0x9770cadFCdba5BF9A26AfDcAd48cB51338941A1A](https://sepolia.etherscan.io/address/0x9770cadFCdba5BF9A26AfDcAd48cB51338941A1A#code)
- MerkleDistributor: [0xB43826E079dFB2e2b48a0a473Efc7F1fe6391763](https://sepolia.etherscan.io/address/0xB43826E079dFB2e2b48a0a473Efc7F1fe6391763#code)

## Design Choices 📐
Unlike Mint Club V1's bonding curve (`y = x` -> `total supply = token price`), the V2 contract uses a custom increasing price step array for the following reasons:
1. Utilizing `y = ax^b` bonding curves is challenging to test because we have to use approximation to calculate the power function of `(_baseN / _baseD) ^ (_expN / _expD)` ([Reference: Banchor's Bonding Curve implementation](https://github.com/relevant-community/bonding-curve/blob/master/contracts/Power.sol))
2. Employing a single bonding curve is hard to customize. Supporting various types of curve functions (e.g., Sigmoid, Logarithm, etc) might be too difficult to implement in Solidity, or even impossible in many cases
3. Therefore, we decided to use an array of price steps (called `BondStep[] { rangeTo, price }`), that is simple to calculate and fully customizable.

### An example of a price step array:
![image](https://github.com/Steemhunt/mint.club-v2-contract/assets/1332279/d61607a2-39cc-433a-8cd2-3bbb627ab2aa)

Parameters:
- maxSupply: 10,000
- stepRanges: [ 1000, 1600, 2200, 2800, ..., 10000 ]
- stepPrices: [ 2, 2.1, 2.3, 2.7, ..., 10 ]

## Run Tests 🧪
```bash
npx hardhat test
```

### Coverage ☂️
```m
---------------------------|----------|----------|----------|----------|----------------|
File                       |  % Stmts | % Branch |  % Funcs |  % Lines |Uncovered Lines |
---------------------------|----------|----------|----------|----------|----------------|
 contracts/                |    89.81 |    82.78 |    86.54 |    89.53 |                |
  Locker.sol               |      100 |      100 |      100 |      100 |                |
  MCV2_Bond.sol            |    88.14 |    85.23 |    90.48 |    89.93 |... 199,202,221 |
  MCV2_ICommonToken.sol    |      100 |      100 |      100 |      100 |                |
  MCV2_MultiToken.sol      |        0 |        0 |        0 |        0 |... 53,54,56,63 |
  MCV2_Royalty.sol         |      100 |      100 |      100 |      100 |                |
  MCV2_Token.sol           |      100 |       50 |      100 |      100 |                |
  MerkleDistributor.sol    |      100 |    95.24 |      100 |      100 |                |
 contracts/lib/            |        0 |        0 |        0 |        0 |                |
  ERC1155Initializable.sol |        0 |        0 |        0 |        0 |... 490,491,493 |
 contracts/mock/           |      100 |      100 |      100 |      100 |                |
  TestToken.sol            |      100 |      100 |      100 |      100 |                |
---------------------------|----------|----------|----------|----------|----------------|
All files                  |    63.73 |    64.22 |    61.33 |    66.17 |                |
---------------------------|----------|----------|----------|----------|----------------|
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
|  Methods                                          ·                15 gwei/gas                ·       1587.30 usd/eth       │
······················|·····························|·············|·············|···············|···············|··············
|  Contract           ·  Method                     ·  Min        ·  Max        ·  Avg          ·  # calls      ·  usd (avg)  │
······················|·····························|·············|·············|···············|···············|··············
|  ERC20              ·  approve                    ·      48922  ·      49222  ·        49104  ·           25  ·       1.17  │
······················|·····························|·············|·············|···············|···············|··············
|  ERC20              ·  transfer                   ·          -  ·          -  ·        32163  ·            1  ·       0.77  │
······················|·····························|·············|·············|···············|···············|··············
|  Locker             ·  createLockUp               ·     116427  ·     150627  ·       139616  ·           20  ·       3.32  │
······················|·····························|·············|·············|···············|···············|··············
|  Locker             ·  unlock                     ·          -  ·          -  ·        64888  ·            5  ·       1.54  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Bond          ·  burn                       ·      96974  ·     132150  ·       117965  ·           23  ·       2.81  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Bond          ·  claimRoyalties             ·          -  ·          -  ·        80053  ·            3  ·       1.91  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Bond          ·  createToken                ·     336945  ·     531311  ·       524002  ·           94  ·      12.48  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Bond          ·  mint                       ·     102180  ·     191587  ·       169055  ·           50  ·       4.03  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Bond          ·  updateBondCreator          ·      28446  ·      31246  ·        30313  ·            6  ·       0.72  │
······················|·····························|·············|·············|···············|···············|··············
|  MCV2_Bond          ·  updateProtocolBeneficiary  ·          -  ·          -  ·        28970  ·            1  ·       0.69  │
······················|·····························|·············|·············|···············|···············|··············
|  MerkleDistributor  ·  claim                      ·      91301  ·      96103  ·        94821  ·           14  ·       2.26  │
······················|·····························|·············|·············|···············|···············|··············
|  MerkleDistributor  ·  createDistribution         ·     138807  ·     198259  ·       180567  ·           49  ·       4.30  │
······················|·····························|·············|·············|···············|···············|··············
|  MerkleDistributor  ·  refund                     ·          -  ·          -  ·        47098  ·            3  ·       1.12  │
······················|·····························|·············|·············|···············|···············|··············
|  TestToken          ·  approve                    ·      24259  ·      46543  ·        46078  ·          121  ·       1.10  │
······················|·····························|·············|·············|···············|···············|··············
|  TestToken          ·  transfer                   ·      46585  ·      51397  ·        50406  ·           65  ·       1.20  │
······················|·····························|·············|·············|···············|···············|··············
|  Deployments                                      ·                                           ·  % of limit   ·             │
····················································|·············|·············|···············|···············|··············
|  Locker                                           ·          -  ·          -  ·       970066  ·        3.2 %  ·      23.10  │
····················································|·············|·············|···············|···············|··············
|  MCV2_Bond                                        ·    3231793  ·    3231817  ·      3231805  ·       10.8 %  ·      76.95  │
····················································|·············|·············|···············|···············|··············
|  MCV2_MultiToken                                  ·          -  ·          -  ·      2112201  ·          7 %  ·      50.29  │
····················································|·············|·············|···············|···············|··············
|  MCV2_Token                                       ·          -  ·          -  ·      1046924  ·        3.5 %  ·      24.93  │
····················································|·············|·············|···············|···············|··············
|  MerkleDistributor                                ·          -  ·          -  ·      1724279  ·        5.7 %  ·      41.05  │
····················································|·············|·············|···············|···············|··············
|  TestToken                                        ·     758947  ·     758959  ·       758955  ·        2.5 %  ·      18.07  │
·---------------------------------------------------|-------------|-------------|---------------|---------------|-------------·
```
