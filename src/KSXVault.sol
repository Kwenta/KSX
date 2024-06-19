// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {ERC4626} from
    "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {ERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {FixedPointMathLib} from "lib/solady/src/utils/FixedPointMathLib.sol";

/// @title Kwenta Example Contract
/// @notice KSX ERC4626 Vault
/// @author Flocqst (florian@kwenta.io)
contract KSXVault is ERC4626 {

    /// @notice Decimal offset used for calculating the conversion rate between KWENTA and KSX.
    /// @dev Set to 3 to ensure the initial fixed ratio of 1,000 KSX per KWENTA
    uint256 public immutable decimalsOffset;

    constructor(address _token, uint256 _decimalsOffset)
        ERC4626(IERC20(_token))
        ERC20("KSX Vault", "KSX")
    {
        decimalsOffset = _decimalsOffset;
    }


    function convertToShares(uint256 assets) public view virtual override returns (uint256 shares) {
            uint256 o = decimalsOffset;
            if (o == 0) {
                return FixedPointMathLib.fullMulDiv(assets, totalSupply() + 1, totalAssets() + 1);
            }
            return FixedPointMathLib.fullMulDiv(assets, totalSupply() + 10 ** o, totalAssets() + 1);
    }

}
