// SPDX-License-Identifier: BSD-3-Clause

pragma solidity ^0.8.20;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol"; // include Context

/**
 * @title MCV2_Royalty
 * @dev This contract implements royalty functionality for the Mint Club V2 protocol.
 */
abstract contract MCV2_Royalty is Ownable {
    using SafeERC20 for IERC20;

    error MCV2_Royalty__NothingToClaim();

    uint256 private constant RATIO_BASE = 10000; // 100.00%
    uint256 private constant PROTOCOL_CUT = 2000;
    uint256 internal constant MAX_ROYALTY_RANGE = 5000; // The max is set at 50% to offer flexibility in tokenomics

    address public constant BURN_ADDRESS = address(0x000000000000000000000000000000000000dEaD);
    address public protocolBeneficiary;

    // User => ReserveToken => Royalty Balance
    mapping(address => mapping(address => uint256)) public userTokenRoyaltyBalance;
    mapping(address => mapping(address => uint256)) public userTokenRoyaltyClaimed; // INFO

    event RoyaltyClaimed(address indexed user, address reserveToken, uint256 amount);

    /**
     * @dev Initializes the MCV2_Royalty contract.
     * @param protocolBeneficiary_ The address of the protocol beneficiary.
     * @param msgSender The address of the contract deployer.
     */
    constructor(address protocolBeneficiary_, address msgSender) Ownable(msgSender) {
        updateProtocolBeneficiary(protocolBeneficiary_);
    }

    /**
     * @dev Updates the protocol beneficiary address.
     * @param protocolBeneficiary_ The new address of the protocol beneficiary.
     */
    function updateProtocolBeneficiary(address protocolBeneficiary_) public onlyOwner {
        protocolBeneficiary = protocolBeneficiary_;
    }

    // MARK: - Internal utility functions

    /**
     * @dev Calculates the royalty amount based on the reserve amount and royalty ratio.
     * @param reserveAmount The amount of the reserve token.
     * @param royaltyRatio The royalty ratio.
     * @return The calculated royalty amount.
     */
    function getRoyalty(uint256 reserveAmount, uint16 royaltyRatio) internal pure returns (uint256) {
        return reserveAmount * royaltyRatio / RATIO_BASE;
    }

    /**
     * @dev Adds royalty to the beneficiary and the protocol.
     * @param beneficiary The address of the royalty beneficiary.
     * @param reserveToken The address of the reserve token.
     * @param royaltyAmount The royalty amount to be added.
     */
    function addRoyalty(address beneficiary, address reserveToken, uint256 royaltyAmount) internal {
        uint256 protocolCut = royaltyAmount * PROTOCOL_CUT / RATIO_BASE;
        userTokenRoyaltyBalance[beneficiary][reserveToken] += royaltyAmount - protocolCut;
        userTokenRoyaltyBalance[protocolBeneficiary][reserveToken] += protocolCut;
    }

    // MARK: - External functions

    /**
     * @dev Claims the accumulated royalties for a specific reserve token.
     * @param reserveToken The address of the reserve token.
     */
    function claimRoyalties(address reserveToken) external {
        address msgSender = _msgSender();
        uint256 amount = userTokenRoyaltyBalance[msgSender][reserveToken];
        if (amount == 0) revert MCV2_Royalty__NothingToClaim();

        userTokenRoyaltyBalance[msgSender][reserveToken] = 0;
        userTokenRoyaltyClaimed[msgSender][reserveToken] += amount; // INFO

        IERC20(reserveToken).safeTransfer(msgSender, amount);

        emit RoyaltyClaimed(msgSender, reserveToken, amount);
    }

    /**
     * @dev Burns the accumulated royalties for a specific reserve token and sends them to the BURN_ADDRESS.
     * @dev Anyone can call this function to burn the accumulated royalties for a specific reserve token.
     * @param reserveToken The address of the reserve token.
     */
    function burnRoyalties(address reserveToken) external {
        uint256 amount = userTokenRoyaltyBalance[BURN_ADDRESS][reserveToken];
        if (amount == 0) revert MCV2_Royalty__NothingToClaim();

        userTokenRoyaltyBalance[BURN_ADDRESS][reserveToken] = 0;
        userTokenRoyaltyClaimed[BURN_ADDRESS][reserveToken] += amount; // INFO

        IERC20(reserveToken).safeTransfer(BURN_ADDRESS, amount);

        emit RoyaltyClaimed(BURN_ADDRESS, reserveToken, amount);
    }

    // MARK: - Utility view functions

    /**
     * @dev Retrieves the royalty information for a specific wallet and reserve token.
     * @param wallet The address of the wallet.
     * @param reserveToken The address of the reserve token.
     * @return The royalty balance and claimed amount for the wallet and reserve token.
     */
    function getRoyaltyInfo(address wallet, address reserveToken) external view returns (uint256, uint256) {
        return (userTokenRoyaltyBalance[wallet][reserveToken], userTokenRoyaltyClaimed[wallet][reserveToken]);
    }
}
