// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {ERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from
    "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IStakingRewardsV2} from "@token/interfaces/IStakingRewardsV2.sol";

/// @title KSXVault Contract
/// @notice KSX ERC4626 Vault
/// @author Flocqst (florian@kwenta.io)
contract KSXVault is ERC4626 {

    /*//////////////////////////////////////////////////////////////
                               IMMUTABLES
    //////////////////////////////////////////////////////////////*/

    /// @notice Decimal offset used for calculating the conversion rate between
    /// KWENTA and KSX.
    /// @dev Set to 3 to ensure the initial fixed ratio of 1,000 KSX per KWENTA
    /// further protect against inflation attacks
    /// (https://docs.openzeppelin.com/contracts/4.x/erc4626#inflation-attack)
    uint8 public immutable offset;

    /// @notice Kwenta's StakingRewards contract
    IStakingRewardsV2 internal immutable STAKING_REWARDS;

    /// @notice KWENTA TOKEN
     /// @dev The underlying asset of this vault
    ERC20 private immutable KWENTA;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @notice Constructs the KSXVault contract
    /// @param _token Kwenta token address
    /// @param _stakingRewards Kwenta v2 staking rewards contract
    /// @param _offset offset in the decimal representation between the
    /// underlying asset's decimals and the vault decimals
    constructor(
        address _token,
        address _stakingRewards,
        uint8 _offset
    )
        ERC4626(IERC20(_token))
        ERC20("KSX Vault", "KSX")
    {
        offset = _offset;
        STAKING_REWARDS = IStakingRewardsV2(_stakingRewards);
        KWENTA = ERC20(_token);
    }

    /// @notice Returns the decimal offset for the vault
    /// @dev This function is used internally by the ERC4626 implementation
    /// @return The decimal offset value
    function _decimalsOffset() internal view virtual override returns (uint8) {
        return offset;
    }

    /*//////////////////////////////////////////////////////////////
                        DEPOSIT/MINT FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Deposit assets into the vault
    /// @dev Overrides the ERC4626 deposit function to include reward collection and staking
    /// @param assets The amount of assets to deposit
    /// @param receiver The address to receive the minted shares
    /// @return shares The amount of shares minted
    function deposit(uint256 assets, address receiver) public virtual override returns (uint256) {
        uint256 shares = super.deposit(assets, receiver);
        _collectAndStakeRewards();
        return shares;
    }

    /// @notice Mint shares of the vault
    /// @dev Overrides the ERC4626 mint function to include reward collection and staking
    /// @param shares The amount of shares to mint
    /// @param receiver The address to receive the minted shares
    /// @return assets The amount of assets deposited
    function mint(uint256 shares, address receiver) public virtual override returns (uint256) {
        uint256 assets = super.mint(shares, receiver);
        _collectAndStakeRewards();
        return assets;
    }

    /*//////////////////////////////////////////////////////////////
                        WITHDRAW/REDEEM FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Withdraw assets from the vault
    /// @dev Overrides the ERC4626 withdraw function to include unstaking of KWENTA
    /// @param assets The amount of assets to withdraw
    /// @param receiver The address to receive the assets
    /// @param owner The owner of the shares
    /// @return shares The amount of shares burned
    function withdraw(uint256 assets, address receiver, address owner) public virtual override returns (uint256) {
        _unstakeKWENTA(assets);
        return super.withdraw(assets, receiver, owner);
    }

    /// @notice Redeem shares of the vault
    /// @dev Overrides the ERC4626 redeem function to include unstaking of KWENTA
    /// @param shares The amount of shares to redeem
    /// @param receiver The address to receive the assets
    /// @param owner The owner of the shares
    /// @return assets The amount of assets withdrawn
    function redeem(uint256 shares, address receiver, address owner) public virtual override returns (uint256) {
        uint256 assets = previewRedeem(shares);
        _unstakeKWENTA(assets);
        return super.redeem(shares, receiver, owner);
    }

    /*//////////////////////////////////////////////////////////////
                        STAKING MANAGEMENT
    //////////////////////////////////////////////////////////////*/

    /// @notice Collect rewards and stake all available KWENTA
    /// @dev This function is called after every deposit and mint operation
    function _collectAndStakeRewards() internal {
        STAKING_REWARDS.getReward();

        uint256 totalToStake = KWENTA.balanceOf(address(this));
        if (totalToStake > 0) {
            STAKING_REWARDS.stake(totalToStake);
        }
    }

    /// @notice Unstake KWENTA tokens
    /// @dev This function is called before withdrawals and redemptions
    /// @param kwentaAmount The amount of KWENTA to unstake
    function _unstakeKWENTA(uint256 kwentaAmount) internal {
        STAKING_REWARDS.unstake(kwentaAmount);
    }

}
