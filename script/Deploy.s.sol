// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

// proxy
import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
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
    )
        public
        returns (KSXVault ksxVault)
    {
        // Deploy KSX Vault Implementation
        address ksxVaultImplementation = address(new KSXVault(pDAO));
        ksxVault = KSXVault(
            address(
                new Proxy(
                    ksxVaultImplementation,
                    abi.encodeWithSignature("initialize(address)", token)
                )
            )
        );
    }

}

/// @dev steps to deploy and verify on Optimism:
/// (1) load the variables in the .env file via `source .env`
/// (2) run `forge script script/Deploy.s.sol:DeployOptimism --rpc-url
/// $OPTIMISM_RPC_URL --etherscan-api-key $OPTIMISM_ETHERSCAN_API_KEY
/// --broadcast --verify -vvvv`
contract DeployOptimism is Setup, OptimismParameters {

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        Setup.deploySystem({token: KWENTA, pDAO: PDAO});

        vm.stopBroadcast();
    }

}

/// @dev steps to deploy and verify on Optimism Goerli:
/// (1) load the variables in the .env file via `source .env`
/// (2) run `forge script script/Deploy.s.sol:DeployOptimismGoerli --rpc-url
/// $OPTIMISM_GOERLI_RPC_URL --etherscan-api-key $OPTIMISM_ETHERSCAN_API_KEY
/// --broadcast --verify -vvvv`
contract DeployOptimismGoerli is Setup, OptimismGoerliParameters {

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        Setup.deploySystem({token: KWENTA, pDAO: PDAO});

        vm.stopBroadcast();
    }

}
