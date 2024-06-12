// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {ERC4626} from
    "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {ERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

/// @title Kwenta Example Contract
/// @notice KSX ERC4626 Vault
/// @author Flocqst (florian@kwenta.io)
contract KSXVault is ERC4626, UUPSUpgradeable {
    /*//////////////////////////////////////////////////////////////
                               IMMUTABLES
    //////////////////////////////////////////////////////////////*/

    /// @notice Kwenta owned/operated multisig address that
    /// can authorize upgrades
    /// @dev if this address is the zero address, then the
    /// KSX vault will no longer be upgradeable
    /// @dev making immutable because the pDAO address
    /// will *never* change
    address internal immutable pDAO;

    constructor(address _token, address _pDAO)
        ERC4626(IERC20(_token))
        ERC20("KSX Vault", "KSX")
    {
        /// @dev pDAO address can be the zero address to
        /// make the KSX vault non-upgradeable
        pDAO = _pDAO;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        virtual
        override
    {}
}
