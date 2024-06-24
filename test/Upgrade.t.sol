// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Bootstrap, KSXVault} from "test/utils/Bootstrap.sol";
import {IKSXVault} from "src/interfaces/IKSXVault.sol";
import {MockVaultUpgrade} from "test/utils/mocks/MockVaultUpgrade.sol";

contract UpgradeTest is Bootstrap {
    function setUp() public {
        initializeOptimism();
    }
}

contract MockUpgrade is UpgradeTest {
    MockVaultUpgrade mockVaultUpgrade;

    function deployMockVault() internal {
        mockVaultUpgrade = new MockVaultUpgrade(
            address(TOKEN),
            address(pDAO)
        );
    }

    function test_upgrade() public {
        string memory message = "hi";

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
}

contract UpgradeVault is UpgradeTest {}

contract RemoveUpgradability is UpgradeTest {
    function test_removeUpgradability() public {

        MockVaultUpgrade mockVaultUpgrade = new MockVaultUpgrade(
            address(TOKEN),
            address(0) // set pDAO to zero address to effectively remove upgradability
        );

        vm.prank(pDAO);

        ksxVault.upgradeToAndCall(address(mockVaultUpgrade), "");

        vm.prank(pDAO);

        vm.expectRevert(abi.encodeWithSelector(IKSXVault.NonUpgradeable.selector));

        ksxVault.upgradeToAndCall(address(mockVaultUpgrade), "");
    }
}
