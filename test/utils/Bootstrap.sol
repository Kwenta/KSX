// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test} from "lib/forge-std/src/Test.sol";
import {console2} from "lib/forge-std/src/console2.sol";
import {
    OptimismGoerliParameters,
    OptimismParameters,
    Setup
} from "script/Deploy.s.sol";
import {KSXVault} from "src/KSXVault.sol";
import {Constants} from "test/utils/Constants.sol";

contract Bootstrap is Test, Constants {

    using console2 for *;

    // decimal offset
    uint256 public decimalsOffset;

    // deployed contracts
    KSXVault internal ksxVault;

    IERC20 public TOKEN;

    // testing addresses
    address constant alice = address(0xAAAA);
    address constant bob = address(0xBBBB);

    function initializeLocal(address _token, uint8 _decimalsOffset) internal {
        BootstrapLocal bootstrap = new BootstrapLocal();
        (address ksxVaultAddress) = bootstrap.init(_token, _decimalsOffset);

        decimalsOffset = _decimalsOffset;
        TOKEN = IERC20(_token);
        ksxVault = KSXVault(ksxVaultAddress);
    }

}

contract BootstrapLocal is Setup {

    function init(
        address _token,
        uint8 _decimalsOffset
    )
        public
        returns (address)
    {
        (KSXVault ksxvault) = Setup.deploySystem(_token, _decimalsOffset);

        return (address(ksxvault));
    }

}
