// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

/// utility contract for *testing* events. consolidates all events into one contract

contract ConsolidatedEvents {
    /*//////////////////////////////////////////////////////////////
                                AUCTION
    //////////////////////////////////////////////////////////////*/

    event Start();

    event Bid(address indexed sender, uint256 amount);

    event Withdraw(address indexed bidder, uint256 amount);

    event End(address winner, uint256 amount);

    event BidBufferUpdated(uint256 newBidIncrement);

    event BiddingFrozen();

    event BiddingResumed();

    event FundsWithdrawn(
        address indexed owner, uint256 usdcAmount, uint256 kwentaAmount
    );
}
