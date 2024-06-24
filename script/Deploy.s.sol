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
        address pDAO
    ) public returns (KSXVault ksxVault) {
        ksxVault = new KSXVault({
            _token: token,
            _pDAO: pDAO
        });

        // deploy ERC1967 proxy and set implementation to ksxVault
        Proxy proxy = new Proxy(address(ksxVault), "");

        // "wrap" proxy in IKSXVault interface
        ksxVault = KSXVault(address(proxy));
    }
}

/// @dev steps to deploy and verify on Optimism:
/// (1) load the variables in the .env file via `source .env`
/// (2) run `forge script script/Deploy.s.sol:DeployOptimism_Synthetix --rpc-url $OPTIMISM_RPC_URL --etherscan-api-key $OPTIMISM_ETHERSCAN_API_KEY --broadcast --verify -vvvv`
contract DeployOptimism_Synthetix is Setup, OptimismParameters {
    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        Setup.deploySystem({
            token: KWENTA,
            pDAO: PDAO
        });

        vm.stopBroadcast();
    }
}

/// @dev steps to deploy and verify on Optimism Goerli:
/// (1) load the variables in the .env file via `source .env`
/// (2) run `forge script script/Deploy.s.sol:DeployOptimismGoerli_Synthetix --rpc-url $OPTIMISM_GOERLI_RPC_URL --etherscan-api-key $OPTIMISM_ETHERSCAN_API_KEY --broadcast --verify -vvvv`
contract DeployOptimismGoerli_Synthetix is Setup, OptimismGoerliParameters {
    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        Setup.deploySystem({
            token: KWENTA,
            pDAO: PDAO
        });

        vm.stopBroadcast();
    }
}
