// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Test} from "forge-std/Test.sol";
import {Bootstrap, KSXVault} from "test/utils/Bootstrap.sol";

contract KSXVaultTest is Bootstrap {

    function setUp() public {
        MockERC20 depositToken = new MockERC20("Deposit Token", "DT");
        initializeLocal(address(depositToken), PDAOADDR);
    }

    function test_share_name() public {
        assertEq(ksxVault.name(), "KSX Vault");
    }

    function test_share_symbol() public {
        assertEq(ksxVault.symbol(), "KSX");
    }

}

contract MockERC20 is ERC20 {

    constructor(
        string memory name_,
        string memory symbol_
    )
        ERC20(name_, symbol_)
    {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

}
