// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import { ERC4626 } from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import { ERC20, IERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title Kwenta Example Contract
/// @notice KSX ERC4626 Vault
/// @author Flocqst (florian@kwenta.io)
contract KSXVault is ERC4626 {
    constructor(address _token) ERC4626(IERC20(_token)) ERC20("KSX Vault", "KSX") {

    }
}
