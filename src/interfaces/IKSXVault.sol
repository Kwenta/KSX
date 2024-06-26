// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

/// @title Kwenta KSXVault Interface
/// @author Flocqst (florian@kwenta.io)
interface IKSXVault {

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice thrown when attempting to update
    /// the KSXVault when caller is not the Kwenta pDAO
    error OnlyPDAO();

    /// @notice thrown when attempting to upgrade
    /// the KSXVault when the KSXVault is not upgradeable
    /// @dev the KSXVault is not upgradeable when
    /// the pDAO has been set to the zero address
    error NonUpgradeable();

}
