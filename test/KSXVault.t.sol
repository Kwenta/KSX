// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Test} from "forge-std/Test.sol";
import {Bootstrap, KSXVault} from "test/utils/Bootstrap.sol";

contract KSXVaultTest is Bootstrap {

    MockERC20 depositToken;

    function setUp() public {
        depositToken = new MockERC20("Deposit Token", "DT");
        initializeLocal(address(depositToken), DECIMAL_OFFSET);

        depositToken.mint(alice, 10 ether);
        depositToken.mint(bob, 10 ether);
    }

    // Asserts decimals offset is correctly set to 3
    function test_vault_decimalsOffset() public {
        assertEq(ksxVault.offset(), 3);
    }

    // Asserts correct deposit at 1000 shares ratio
    // Converts asset values to shares and deposits assets into the vault
    function test_vault_deposit() public {
        uint256 amount = 1 ether;
        vm.startPrank(alice);
        depositToken.approve(address(ksxVault), amount);
        ksxVault.deposit(1 ether, alice);
        assertEq(ksxVault.balanceOf(alice), amount * (10 ** ksxVault.offset()));
        assertEq(depositToken.balanceOf(address(ksxVault)), amount);
        vm.stopPrank();
    }

    // Asserts correct mint at 1000 shares ratio
    // Mints a specified number of shares and requires the equivalent asset
    // value to be deposited
    function test_vault_mint() public {
        uint256 amount = 1 ether;
        vm.startPrank(alice);
        depositToken.approve(address(ksxVault), amount);
        ksxVault.mint(1 ether, alice);
        assertEq(ksxVault.balanceOf(alice), amount);
        assertEq(
            depositToken.balanceOf(address(ksxVault)),
            amount / (10 ** ksxVault.offset())
        );
        vm.stopPrank();
    }

    // Withdraws a specified amount of assets from the vault by burning the
    // equivalent shares
    function test_withdraw() public {
        uint256 amount = 1 ether;
        vm.startPrank(alice);
        depositToken.approve(address(ksxVault), amount);
        ksxVault.deposit(amount, alice);
        assertEq(ksxVault.balanceOf(alice), amount * (10 ** ksxVault.offset()));
        assertEq(depositToken.balanceOf(address(ksxVault)), amount);

        ksxVault.withdraw(amount, alice, alice);
        assertEq(ksxVault.balanceOf(alice), 0);
        assertEq(depositToken.balanceOf(address(ksxVault)), 0);
        assertEq(depositToken.balanceOf(alice), 10 ether);
        vm.stopPrank();
    }

    function test_redeem() public {
        uint256 amount = 1 ether;
        vm.startPrank(alice);
        depositToken.approve(address(ksxVault), amount);
        ksxVault.mint(1 ether, alice);
        assertEq(ksxVault.balanceOf(alice), amount);
        assertEq(
            depositToken.balanceOf(address(ksxVault)),
            amount / (10 ** ksxVault.offset())
        );

        ksxVault.redeem(amount, alice, alice);
        assertEq(ksxVault.balanceOf(alice), 0);
        assertEq(depositToken.balanceOf(address(ksxVault)), 0);
        assertEq(depositToken.balanceOf(alice), 10 ether);
        vm.stopPrank();
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
