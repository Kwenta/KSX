// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {ERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from
    "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {FixedPointMathLib} from "lib/solady/src/utils/FixedPointMathLib.sol";
import {IStakingRewardsV2} from "src/interfaces/IStakingRewardsV2.sol";

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

    /// @notice Synthetix v3 perps market proxy contract
    IStakingRewardsV2 internal immutable STAKING_REWARDS;

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
    }

    function _decimalsOffset() internal view virtual override returns (uint8) {
        return offset;
    }

    /*//////////////////////////////////////////////////////////////
                        STAKING MANAGEMENT
    //////////////////////////////////////////////////////////////*/

    /// @notice Claim KWENTA rewards
    function _claimKWENTARewards() internal returns (uint256) {
        // Implement the logic to claim KWENTA rewards
    }

    /// @notice Stake KWENTA tokens
    function _stakeKWENTA(uint256 kwentaAmount) internal {
        STAKING_REWARDS.stake(kwentaAmount);
    }

    /// @notice Modifier to compound unstaked KWENTA tokens before executing the
    /// function
    modifier compoundUnstakedKWENTA() {
        // StakingV2 harvest rewards
        // TokenDistributor claim USDC
        // Swap USDC for KWENTA and stake
        _;
    }


    /** @dev See {IERC4626-deposit}. */
    function deposit(uint256 assets, address receiver) public virtual override returns (uint256) {
        uint256 maxAssets = maxDeposit(receiver);
        if (assets > maxAssets) {
            revert ERC4626ExceededMaxDeposit(receiver, assets, maxAssets);
        }

        uint256 shares = previewDeposit(assets);
        _deposit(_msgSender(), receiver, assets, shares);

        return shares;
    }

    /** @dev See {IERC4626-mint}.
     *
     * As opposed to {deposit}, minting is allowed even if the vault is in a state where the price of a share is zero.
     * In this case, the shares will be minted without requiring any assets to be deposited.
     */
    function mint(uint256 shares, address receiver) public virtual override returns (uint256) {
        uint256 maxShares = maxMint(receiver);
        if (shares > maxShares) {
            revert ERC4626ExceededMaxMint(receiver, shares, maxShares);
        }

        uint256 assets = previewMint(shares);
        _deposit(_msgSender(), receiver, assets, shares);

        return assets;
    }

    /** @dev See {IERC4626-withdraw}. */
    function withdraw(uint256 assets, address receiver, address owner) public virtual override returns (uint256) {
        uint256 maxAssets = maxWithdraw(owner);
        if (assets > maxAssets) {
            revert ERC4626ExceededMaxWithdraw(owner, assets, maxAssets);
        }

        uint256 shares = previewWithdraw(assets);
        _withdraw(_msgSender(), receiver, owner, assets, shares);

        return shares;
    }

    /** @dev See {IERC4626-redeem}. */
    function redeem(uint256 shares, address receiver, address owner) public virtual override returns (uint256) {
        uint256 maxShares = maxRedeem(owner);
        if (shares > maxShares) {
            revert ERC4626ExceededMaxRedeem(owner, shares, maxShares);
        }

        uint256 assets = previewRedeem(shares);
        _withdraw(_msgSender(), receiver, owner, assets, shares);

        return assets;
    }

}
