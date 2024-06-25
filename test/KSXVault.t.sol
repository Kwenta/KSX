// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Test} from "forge-std/Test.sol";
import {KSXVault} from "../src/KSXVault.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/** @PR:REVIEW no tests for vault **/
/** @PR:REVIEW add pDAO test **/
/** @PR:REVIEW add share name **/
/** @PR:REVIEW add share symbol **/
/** @PR:REVIEW add use bootstrap everywhere instead of `Test` **/

contract KSXVaultTest is Test {
    function setUp() public {}
}

contract MockERC20 is ERC20 {
    constructor(string memory name_, string memory symbol_)
        ERC20(name_, symbol_)
    {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
