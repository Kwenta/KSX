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

    // pDAO address
    address public pDAO;

    // deployed contracts
    KSXVault internal ksxVault;

    IERC20 public TOKEN;

    function initializeLocal(address _token, address _pDAO) internal {
        BootstrapLocal bootstrap = new BootstrapLocal();
        (address ksxVaultAddress) = bootstrap.init(_token, _pDAO);

        pDAO = _pDAO;
        TOKEN = IERC20(_token);
        ksxVault = KSXVault(ksxVaultAddress);
    }

    function initializeOptimism() internal {
        BootstrapOptimism bootstrap = new BootstrapOptimism();
        (address ksxVaultAddress, address _TokenAddress, address _pDAOAddress) =
            bootstrap.init();

        pDAO = _pDAOAddress;
        TOKEN = IERC20(_TokenAddress);
        ksxVault = KSXVault(ksxVaultAddress);
    }

}

contract BootstrapLocal is Setup {

    function init(address _token, address _pDAO) public returns (address) {
        (KSXVault ksxvault) = Setup.deploySystem({token: _token, pDAO: _pDAO});

        return (address(ksxvault));
    }

}

contract BootstrapOptimism is Setup, OptimismParameters {

    function init() public returns (address, address, address) {
        (KSXVault ksxvault) = Setup.deploySystem({token: KWENTA, pDAO: PDAO});

        return (address(ksxvault), KWENTA, PDAO);
    }

}

contract BootstrapOptimismGoerli is Setup, OptimismGoerliParameters {

    function init() public returns (address, address, address) {
        (KSXVault ksxvault) = Setup.deploySystem({token: KWENTA, pDAO: PDAO});

        return (address(ksxvault), KWENTA, PDAO);
    }

}
