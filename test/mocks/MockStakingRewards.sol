// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MockStakingRewards {
    IERC20 public stakingToken;
    mapping(address => uint256) public stakedBalances;
    uint256 public totalStaked;

    constructor(address _stakingToken) {
        stakingToken = IERC20(_stakingToken);
    }

    function stake(uint256 amount) external {
        require(stakingToken.transferFrom(msg.sender, address(this), amount), "Stake failed");
        stakedBalances[msg.sender] += amount;
        totalStaked += amount;
    }

    function unstake(uint256 amount) external {
        require(stakedBalances[msg.sender] >= amount, "Insufficient staked balance");
        stakedBalances[msg.sender] -= amount;
        totalStaked -= amount;
        require(stakingToken.transfer(msg.sender, amount), "Unstake transfer failed");
    }

    function getReward() external {
        // For simplicity, we're not implementing reward logic in this mock
    }

    // Helper function to check staked balance
    function stakedBalanceOf(address account) external view returns (uint256) {
        return stakedBalances[account];
    }
}