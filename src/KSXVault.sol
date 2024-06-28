// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {ERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from
    "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {FixedPointMathLib} from "lib/solady/src/utils/FixedPointMathLib.sol";

/// @title KSXVault Contract
/// @notice KSX ERC4626 Vault
/// @author Flocqst (florian@kwenta.io)
contract KSXVault is ERC4626 {

    /*//////////////////////////////////////////////////////////////
                               IMMUTABLES
    //////////////////////////////////////////////////////////////*/

    /// @notice Decimal offset used for calculating the conversion rate between
    /// KWENTA and KSX.
    /// @dev Set to 3 to ensure the initial fixed ratio of 1,000 KSX per KWENTA
    /// further protect against inflation attacks
    /// (https://docs.openzeppelin.com/contracts/4.x/erc4626#inflation-attack)
    uint8 public immutable offset;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @notice Constructs the KSXVault contract
    /// @param _token Kwenta token address
    /// @param _offset offset in the decimal representation between the
    /// underlying asset's decimals and the vault decimals
    constructor(
        address _token,
        uint8 _offset
    )
        ERC4626(IERC20(_token))
        ERC20("KSX Vault", "KSX")
    {
        offset = _offset;
    }

    function _decimalsOffset() internal view virtual override returns (uint8) {
        return offset;
    }

    /*//////////////////////////////////////////////////////////////
                        STAKING MANAGEMENT
    //////////////////////////////////////////////////////////////*/

    /// @notice Claim KWENTA rewards
    function _claimKWENTARewards() internal returns (uint256) {
        // Implement the logic to claim KWENTA rewards
    }

    /// @notice Stake KWENTA tokens
    function _stakeKWENTA(uint256 kwentaAmount) internal {
        // Implement the logic to stake KWENTA tokens back into the vault
    }

    /// @notice Modifier to compound unstaked KWENTA tokens before executing the
    /// function
    modifier compoundUnstakedKWENTA() {
        // StakingV2 harvest rewards
        // TokenDistributor claim USDC
        // Swap USDC for KWENTA and stake
        _;
    }

}
