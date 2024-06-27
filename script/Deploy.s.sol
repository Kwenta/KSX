// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

// proxy
import {ERC1967Proxy as Proxy} from
    "lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";

// contracts
import {KSXVault} from "src/KSXVault.sol";

// parameters
import {OptimismGoerliParameters} from
    "script/utils/parameters/OptimismGoerliParameters.sol";
import {OptimismParameters} from
    "script/utils/parameters/OptimismParameters.sol";

// forge utils
import {Script} from "lib/forge-std/src/Script.sol";

/// @title Kwenta KSX deployment script
/// @author Flocqst (florian@kwenta.io)
contract Setup is Script {

    function deploySystem(
        address token,
        uint8 decimalOffset
    )
        public
        returns (KSXVault ksxVault)
    {
        ksxVault = new KSXVault(token, decimalOffset);

        // deploy ERC1967 proxy and set implementation to ksxVault
        Proxy proxy = new Proxy(address(ksxVault), "");

        // "wrap" proxy in IKSXVault interface
        ksxVault = KSXVault(address(proxy));
    }

}
