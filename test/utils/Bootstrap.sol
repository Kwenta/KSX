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
import {IStakingRewardsV2} from "@token/interfaces/IStakingRewardsV2.sol";

contract Bootstrap is Test, Constants {

    using console2 for *;

    // decimal offset
    uint256 public decimalsOffset;

    // deployed contracts
    KSXVault internal ksxVault;

    IERC20 public TOKEN;

    IStakingRewardsV2 public STAKING_REWARDS;

    // testing addresses
    address constant alice = address(0xAAAA);
    address constant bob = address(0xBBBB);

    function initializeLocal(address _token, address _stakingRewards, uint8 _decimalsOffset) internal {
        BootstrapLocal bootstrap = new BootstrapLocal();
        (address ksxVaultAddress) = bootstrap.init(_token, _stakingRewards, _decimalsOffset);

        decimalsOffset = _decimalsOffset;
        TOKEN = IERC20(_token);
        STAKING_REWARDS= IStakingRewardsV2(_stakingRewards);
        ksxVault = KSXVault(ksxVaultAddress);
    }

}

contract BootstrapLocal is Setup {

    function init(
        address _token,
        address _stakingRewards,
        uint8 _decimalsOffset
    )
        public
        returns (address)
    {
        (KSXVault ksxvault) = Setup.deploySystem(_token, _stakingRewards, _decimalsOffset);

        return (address(ksxvault));
    }

}
