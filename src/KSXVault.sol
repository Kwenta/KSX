// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {ERC4626Upgradeable} from
    "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol";
import {ERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from
    "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC20Metadata} from
    "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import {IKSXVault} from "src/interfaces/IKSXVault.sol";

import {UUPSUpgradeable} from
    "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @title KSXVault Contract
/// @notice KSX ERC4626 Vault
/// @author Flocqst (florian@kwenta.io)
contract KSXVault is IKSXVault, ERC4626Upgradeable, UUPSUpgradeable {

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

    /*///////////////////////////////////////////////////////////////
                        CONSTRUCTOR / INITIALIZER
    ///////////////////////////////////////////////////////////////*/

    /// @dev disable default constructor to disable the implementation contract
    /// Actual contract construction will take place in the initialize function
    /// via proxy
    /// @custom:oz-upgrades-unsafe-allow constructor
    /// @param _pDAO Kwenta owned/operated multisig address that can authorize
    /// upgrades
    constructor(address _pDAO) {
        _disableInitializers();

        /// @dev pDAO address can be the zero address to
        /// make the KSX vault non-upgradeable
        pDAO = _pDAO;
    }

    /// @notice Initializes the contract
    /// @param _token The address for the KWENTA ERC20 token
    function initialize(address _token) external initializer {
        __ERC20_init("KSX Vault", "KSX");
        __ERC4626_init(IERC20(_token));
        __UUPSUpgradeable_init();
    }

    /*//////////////////////////////////////////////////////////////
                           UPGRADE MANAGEMENT
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc UUPSUpgradeable
    function _authorizeUpgrade(address /* _newImplementation */ )
        internal
        view
        override
    {
        if (pDAO == address(0)) revert NonUpgradeable();
        if (msg.sender != pDAO) revert OnlyPDAO();
    }

}
