// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {IKSXVault} from "src/interfaces/IKSXVault.sol";
import {Bootstrap, KSXVault} from "test/utils/Bootstrap.sol";
import {MockVaultUpgrade} from "test/utils/mocks/MockVaultUpgrade.sol";

contract UpgradeTest is Bootstrap {

    address public _pDAO = 0xe826d43961a87fBE71C91d9B73F7ef9b16721C07;
    address public _token = 0x0b2C639c533813f4Aa9D7837CAf62653d097Ff85;

    function setUp() public {
        initializeLocal(_token, _pDAO);
    }

}

contract MockUpgrade is UpgradeTest {

    MockVaultUpgrade mockVaultUpgrade;

    function deployMockVault() internal {
        mockVaultUpgrade = new MockVaultUpgrade(address(TOKEN), address(pDAO));
    }

    function test_upgrade(string memory message) public {
        bool success;
        bytes memory response;

        (success,) = address(ksxVault).call(
            abi.encodeWithSelector(MockVaultUpgrade.echo.selector, message)
        );
        assert(!success);

        deployMockVault();

        vm.prank(pDAO);

        ksxVault.upgradeToAndCall(address(mockVaultUpgrade), "");

        (success, response) = address(ksxVault).call(
            abi.encodeWithSelector(mockVaultUpgrade.echo.selector, message)
        );
        assert(success);
        assertEq(abi.decode(response, (string)), message);
    }

    function test_upgrade_only_pDAO() public {
        deployMockVault();

        vm.prank(BAD_ACTOR);

        vm.expectRevert(abi.encodeWithSelector(IKSXVault.OnlyPDAO.selector));

        ksxVault.upgradeToAndCall(address(mockVaultUpgrade), "");
    }

    function test_removeUpgradability() public {
        mockVaultUpgrade = new MockVaultUpgrade(
            address(TOKEN),
            address(0) // set pDAO to zero address to effectively remove
                // upgradability
        );

        vm.prank(pDAO);

        ksxVault.upgradeToAndCall(address(mockVaultUpgrade), "");

        vm.prank(pDAO);

        vm.expectRevert(
            abi.encodeWithSelector(IKSXVault.NonUpgradeable.selector)
        );

        ksxVault.upgradeToAndCall(address(mockVaultUpgrade), "");
    }

}
