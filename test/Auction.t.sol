// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Test} from "forge-std/Test.sol";
import {Auction} from "../src/Auction.sol";
import {MockERC20} from "./mocks/MockERC20.sol";
import {MockUSDC} from "./mocks/MockUSDC.sol";
import {Constants} from "./utils/Constants.sol";
import {ConsolidatedEvents} from "./utils/ConsolidatedEvents.sol";

contract AuctionTest is Test, Constants, ConsolidatedEvents {
    Auction public auction;
    MockUSDC public usdc;
    MockERC20 public kwenta;

    function setUp() public {
        usdc = new MockUSDC();
        kwenta = new MockERC20("KWENTA", "KWENTA");

        usdc.mint(OWNER, AUCTION_TEST_VALUE);
        kwenta.mint(ACTOR1, TEST_VALUE);
        kwenta.mint(ACTOR2, TEST_VALUE);

        // Deploy Auction contract and start auction
        vm.prank(OWNER);
        auction = new Auction(
            OWNER, address(usdc), address(kwenta), STARTING_BID, BID_BUFFER
        );
    }

    /*//////////////////////////////////////////////////////////////
                                start
    //////////////////////////////////////////////////////////////*/

    function test_start_auction(uint256 amount) public {
        vm.assume(amount <= AUCTION_TEST_VALUE);
        // Start the auction
        startAuction(amount);

        // Asserts auction has been correctly started
        assertTrue(auction.started());
        assertEq(auction.auctionAmount(), amount);
        assertEq(usdc.balanceOf(address(auction)), amount);
    }

    function test_cannot_start_auction_already_started() public {
        // Start the auction
        startAuction(AUCTION_TEST_VALUE);
        assertTrue(auction.started());

        // Try starting the auction twice
        vm.prank(OWNER);
        vm.expectRevert(Auction.AuctionAlreadyStarted.selector);
        auction.start(AUCTION_TEST_VALUE);
    }

    function test_start_event() public {
        // Start the auction
        vm.startPrank(OWNER);
        usdc.approve(address(auction), AUCTION_TEST_VALUE);

        vm.expectEmit(true, true, true, true);
        emit Start();

        auction.start(AUCTION_TEST_VALUE);
        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////
                                bid
    //////////////////////////////////////////////////////////////*/

    function test_bid(uint256 amount) public {
        startAuction(AUCTION_TEST_VALUE);

        assertEq(auction.highestBid(), STARTING_BID);

        // bidding should revert if actor has insufficient balance
        if (amount > TEST_VALUE) {
            vm.startPrank(ACTOR1);
            kwenta.approve(address(auction), amount);

            vm.expectRevert();
            auction.bid(amount);
            vm.stopPrank();
        } else {
            vm.startPrank(ACTOR1);
            kwenta.approve(address(auction), amount);

            // bidding should revert if amount < highestBid + bidBuffer
            if (amount < auction.highestBid() + BID_BUFFER) {
                vm.expectRevert(
                    abi.encodeWithSelector(
                        Auction.BidTooLow.selector,
                        auction.highestBid() + BID_BUFFER
                    )
                );
                auction.bid(amount);
            } else {
                auction.bid(amount);

                // Asserts bid has been correctly placed
                assertEq(auction.highestBid(), amount);
                assertEq(auction.highestBidder(), ACTOR1);
                assertEq(kwenta.balanceOf(address(auction)), amount);
            }
            vm.stopPrank();
        }
    }

    function test_bid_updates_highest_bid_and_bidder(
        uint256 firstBidAmount,
        uint256 secondBidAmount
    ) public {
        firstBidAmount = bound(
            firstBidAmount, STARTING_BID + BID_BUFFER, TEST_VALUE - BID_BUFFER
        );
        secondBidAmount =
            bound(secondBidAmount, firstBidAmount + BID_BUFFER, TEST_VALUE);

        startAuction(AUCTION_TEST_VALUE);

        // Place first bid
        placeBid(ACTOR1, firstBidAmount);

        assertEq(auction.highestBid(), firstBidAmount);
        assertEq(auction.highestBidder(), ACTOR1);
        assertEq(kwenta.balanceOf(address(auction)), firstBidAmount);

        // Place second bid
        placeBid(ACTOR2, secondBidAmount);

        // Asserts highest bid and highest bidder has been updated
        assertEq(auction.highestBid(), secondBidAmount);
        assertEq(auction.highestBidder(), ACTOR2);

        assertEq(
            kwenta.balanceOf(address(auction)), firstBidAmount + secondBidAmount
        );
    }

    function test_bid_extends_auction() public {
        startAuction(AUCTION_TEST_VALUE);

        assertEq(auction.endAt(), block.timestamp + 1 days);

        // Asserts auction has not been extended (time remaining > 1 hour)
        placeBid(ACTOR1, 20 ether);
        assertEq(auction.endAt(), block.timestamp + 1 days);

        // fast forward to 30 minutes before end of auction
        vm.warp(block.timestamp + 1 days - 30 minutes);

        assertEq(auction.endAt(), block.timestamp + 30 minutes);

        // Asserts auction has been extended  (bid placed within 1 hour of auction end)
        placeBid(ACTOR2, 30 ether);
        assertEq(auction.endAt(), block.timestamp + 1 hours);
    }

    function test_cannot_place_bid_auction_not_started() public {
        assertFalse(auction.started());

        // Try placing a bid
        vm.startPrank(ACTOR1);
        kwenta.approve(address(auction), TEST_VALUE);

        vm.expectRevert(Auction.AuctionNotStarted.selector);
        auction.bid(TEST_VALUE);
        vm.stopPrank();
    }

    function test_cannot_place_bid_auction_ended() public {
        startAuction(AUCTION_TEST_VALUE);

        // fast forward 1 week
        vm.warp(block.timestamp + 1 weeks);

        // Try placing a bid
        vm.startPrank(ACTOR1);
        kwenta.approve(address(auction), TEST_VALUE);

        vm.expectRevert(Auction.AuctionAlreadyEnded.selector);
        auction.bid(TEST_VALUE);
        vm.stopPrank();
    }

    function test_bid_event() public {
        startAuction(AUCTION_TEST_VALUE);

        vm.startPrank(ACTOR1);
        kwenta.approve(address(auction), TEST_VALUE);

        vm.expectEmit(true, true, true, true);
        emit Bid(ACTOR1, TEST_VALUE);
        auction.bid(TEST_VALUE);
        vm.stopPrank();
    }

    function test_cannot_place_bid_bidding_locked() public {
        startAuction(AUCTION_TEST_VALUE);

        // Lock bidding
        vm.prank(OWNER);
        auction.lockBidding();

        // Try placing a bid
        vm.startPrank(ACTOR1);
        kwenta.approve(address(auction), TEST_VALUE);

        vm.expectRevert(Auction.BiddingLockedErr.selector);
        auction.bid(TEST_VALUE);
        vm.stopPrank();

        vm.prank(OWNER);
        auction.unlockBidding();

        placeBid(ACTOR1, TEST_VALUE);
    }

    function test_lock_bidding_event() public {
        startAuction(AUCTION_TEST_VALUE);

        vm.prank(OWNER);
        vm.expectEmit(true, true, true, true);
        emit BiddingLocked();
        auction.lockBidding();
    }

    function test_unlock_bidding_event() public {
        startAuction(AUCTION_TEST_VALUE);

        vm.prank(OWNER);
        vm.expectEmit(true, true, true, true);
        emit BiddingUnlocked();
        auction.unlockBidding();
    }

    /*//////////////////////////////////////////////////////////////
                                withdraw
    //////////////////////////////////////////////////////////////*/

    function test_withdraw(uint256 firstBidAmount, uint256 secondBidAmount)
        public
    {
        firstBidAmount = bound(
            firstBidAmount, STARTING_BID + BID_BUFFER, TEST_VALUE - BID_BUFFER
        );
        secondBidAmount =
            bound(secondBidAmount, firstBidAmount + BID_BUFFER, TEST_VALUE);

        startAuction(AUCTION_TEST_VALUE);

        // Checks initial kwenta balances
        assertEq(kwenta.balanceOf(ACTOR1), TEST_VALUE);
        assertEq(kwenta.balanceOf(ACTOR2), TEST_VALUE);

        // Place first bid
        placeBid(ACTOR1, firstBidAmount);

        // Actor has nothing to withdraw as he is the highest bidder
        assertEq(kwenta.balanceOf(ACTOR1), TEST_VALUE - firstBidAmount);
        assertEq(auction.highestBidder(), ACTOR1);
        assertEq(auction.bids(ACTOR1), 0);

        assertEq(kwenta.balanceOf(address(auction)), firstBidAmount);

        // Place second bid
        placeBid(ACTOR2, secondBidAmount);

        // Asserts ACTOR2 is now highest bidder and actor 1 can withdraw his bid
        assertEq(kwenta.balanceOf(ACTOR2), TEST_VALUE - secondBidAmount);
        assertEq(auction.highestBidder(), ACTOR2);
        assertEq(auction.bids(ACTOR1), firstBidAmount);
        assertEq(auction.bids(ACTOR2), 0);
        assertEq(
            kwenta.balanceOf(address(auction)), firstBidAmount + secondBidAmount
        );

        // Actor 1 withdraws his bid
        vm.prank(ACTOR1);
        auction.withdraw();

        assertEq(kwenta.balanceOf(ACTOR1), TEST_VALUE);
        assertEq(auction.bids(ACTOR1), 0);
        assertEq(kwenta.balanceOf(address(auction)), secondBidAmount);
    }

    function test_withdraw_event() public {
        startAuction(AUCTION_TEST_VALUE);

        placeBid(ACTOR1, 20 ether);
        placeBid(ACTOR2, 30 ether);

        vm.prank(ACTOR1);
        vm.expectEmit(true, true, true, true);
        emit Withdraw(ACTOR1, 20 ether);
        auction.withdraw();
    }

    /*//////////////////////////////////////////////////////////////
                                settleAuction
    //////////////////////////////////////////////////////////////*/

    function test_settle_auction() public {
        startAuction(AUCTION_TEST_VALUE);

        // Checks initial balances
        assertEq(usdc.balanceOf(ACTOR1), 0);
        assertEq(usdc.balanceOf(ACTOR2), 0);
        assertEq(usdc.balanceOf(address(auction)), AUCTION_TEST_VALUE);
        assertEq(kwenta.balanceOf(OWNER), 0);
        assertEq(kwenta.balanceOf(ACTOR1), TEST_VALUE);
        assertEq(kwenta.balanceOf(ACTOR2), TEST_VALUE);

        // Place bids
        placeBid(ACTOR1, 20 ether);
        placeBid(ACTOR2, 30 ether);
        placeBid(ACTOR1, 40 ether);

        // fast forward 1 week
        vm.warp(block.timestamp + 1 weeks);

        // settle auction
        auction.settleAuction();

        // Withdraw non winning bids
        vm.prank(ACTOR1);
        auction.withdraw();
        vm.prank(ACTOR2);
        auction.withdraw();

        // Asserts auction has been correctly settled
        assertEq(kwenta.balanceOf(OWNER), 40 ether);
        assertEq(kwenta.balanceOf(ACTOR1), TEST_VALUE - 40 ether);
        assertEq(kwenta.balanceOf(ACTOR2), TEST_VALUE);
        assertEq(kwenta.balanceOf(address(auction)), 0);
        assertEq(usdc.balanceOf(ACTOR1), AUCTION_TEST_VALUE);
        assertEq(usdc.balanceOf(ACTOR2), 0);
        assertEq(usdc.balanceOf(address(auction)), 0);
    }

    function test_settle_auction_no_bids() public {
        assertEq(usdc.balanceOf(OWNER), AUCTION_TEST_VALUE);

        startAuction(AUCTION_TEST_VALUE);

        assertEq(usdc.balanceOf(OWNER), 0);
        assertEq(usdc.balanceOf(address(auction)), AUCTION_TEST_VALUE);

        // fast forward 1 week
        vm.warp(block.timestamp + 1 weeks);

        // settle auction
        auction.settleAuction();

        // Asserts usdc returns to owner if no bids are placed
        assertEq(usdc.balanceOf(OWNER), AUCTION_TEST_VALUE);
        assertEq(usdc.balanceOf(address(auction)), 0);
    }

    function test_cannot_settle_unstarted_auction() public {
        // Try settling an auction that has not started
        vm.prank(OWNER);
        vm.expectRevert(Auction.AuctionNotStarted.selector);
        auction.settleAuction();
    }

    function test_cannot_settle_unfinished_auction() public {
        startAuction(AUCTION_TEST_VALUE);

        // Try settling an auction that has not ended
        vm.prank(OWNER);
        vm.expectRevert(Auction.AuctionNotEnded.selector);
        auction.settleAuction();
    }

    function test_cannot_settle_auction_twice() public {
        startAuction(AUCTION_TEST_VALUE);

        // fast forward 1 week
        vm.warp(block.timestamp + 1 weeks);

        // settle auction
        auction.settleAuction();

        // Try settling an auction that has already ended
        vm.expectRevert(Auction.AuctionAlreadySettled.selector);
        auction.settleAuction();
    }

    function test_settle_auction_event() public {
        startAuction(AUCTION_TEST_VALUE);

        placeBid(ACTOR1, TEST_VALUE);

        vm.warp(block.timestamp + 1 weeks);

        vm.expectEmit(true, true, true, true);
        emit End(ACTOR1, TEST_VALUE);
        auction.settleAuction();
    }

    /*//////////////////////////////////////////////////////////////
                                HELPERS
    //////////////////////////////////////////////////////////////*/

    function startAuction(uint256 amount) public {
        vm.startPrank(OWNER);
        usdc.approve(address(auction), amount);
        auction.start(amount);
        vm.stopPrank();
    }

    function placeBid(address account, uint256 amount) public {
        vm.startPrank(account);
        kwenta.approve(address(auction), amount);
        auction.bid(amount);
        vm.stopPrank();
    }
}
