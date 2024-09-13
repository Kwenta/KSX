// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {KSXVault} from "src/KSXVault.sol";

/// @title Example upgraded Vault contract for testing purposes
/// @author Flocqst (florian@kwenta.io)
contract MockVaultUpgrade is KSXVault {

    constructor(address _pDAO) KSXVault(_pDAO) {}

    function echo(string memory message) public pure returns (string memory) {
        return message;
    }

}
