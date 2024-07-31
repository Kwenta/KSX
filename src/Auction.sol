// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";


contract Auction is Ownable, Initializable {
    event Start();
    event Bid(address indexed sender, uint256 amount);
    event Withdraw(address indexed bidder, uint256 amount);
    event End(address winner, uint256 amount);
    event BidBufferUpdated(uint256 newBidIncrement);
    event BiddingLocked();
    event BiddingUnlocked();
    event FundsWithdrawn(address indexed owner, uint256 usdcAmount, uint256 kwentaAmount);

    error AuctionAlreadyStarted();
    error AuctionNotStarted();
    error AuctionAlreadyEnded();
    error BidTooLow(uint256 highestBidPlusBuffer);
    error AuctionNotEnded();
    error AuctionEnded();
    error BiddingLockedErr();

    IERC20 public usdc;
    IERC20 public kwenta;
    uint256 public auctionAmount;
    uint256 public startingBid;
    /// @notice The minimum amount that a bid must be above the current highest bid
    uint256 public bidBuffer;

    uint256 public endAt;
    bool public started;
    bool public ended;
    bool public locked;

    address public highestBidder;
    uint256 public highestBid;
    mapping(address => uint256) public bids;

    constructor(address initialOwner, address _usdc, address _kwenta, uint256 _startingBid, uint256 _bidBuffer) Ownable(initialOwner) {
        usdc = IERC20(_usdc);
        kwenta = IERC20(_kwenta);

        highestBid = _startingBid;
        bidBuffer = _bidBuffer;
    }

    function initialize(
        address initialOwner, 
        address _usdc, 
        address _kwenta, 
        uint256 _startingBid, 
        uint256 _bidBuffer
    ) public initializer {
        _transferOwnership(initialOwner);

        usdc = IERC20(_usdc);
        kwenta = IERC20(_kwenta);

        highestBid = _startingBid;
        bidBuffer = _bidBuffer;
    }

    function start(uint256 _auctionAmount) external onlyOwner{
        if (started) revert AuctionAlreadyStarted();

        usdc.transferFrom(msg.sender, address(this), _auctionAmount);
        auctionAmount = _auctionAmount;

        started = true;
        endAt = block.timestamp + 1 days;

        emit Start();
    }

    function bid(uint256 amount) external Lock {
        if (!started) revert AuctionNotStarted();
        if (block.timestamp >= endAt) revert AuctionAlreadyEnded();
        if (amount <= highestBid + bidBuffer) revert BidTooLow(highestBid + bidBuffer);

        kwenta.transferFrom(msg.sender, address(this), amount);

        if (highestBidder != address(0)) {
            bids[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = amount;

        // Extend the auction if it is ending in less than an hour
        if (endAt - block.timestamp < 1 hours) {
            endAt = block.timestamp + 1 hours;
        }

        emit Bid(msg.sender, amount);
    }

    function withdraw() external {
        uint256 bal = bids[msg.sender];
        bids[msg.sender] = 0;

        kwenta.transfer(msg.sender, bal);

        emit Withdraw(msg.sender, bal);
    }

    function settleAuction() external {
        if (!started) revert AuctionNotStarted();
        if (block.timestamp < endAt) revert AuctionNotEnded();
        if (ended) revert AuctionEnded();

        ended = true;

        if (highestBidder != address(0)) {
            usdc.transfer(highestBidder, auctionAmount);
            kwenta.transfer(owner(), highestBid);
        } else {
            usdc.transfer(owner(), auctionAmount);
        }

        emit End(highestBidder, highestBid);
    }

    function setBidIncrement(uint256 _bidBuffer) external onlyOwner {
        bidBuffer = _bidBuffer;
        emit BidBufferUpdated(_bidBuffer);
    }

    modifier Lock() {
        if (locked) revert BiddingLockedErr();
        _;
    }

    function lockBidding() external onlyOwner {
        locked = true;
        emit BiddingLocked();
    }

    function unlockBidding() external onlyOwner {
        locked = false;
        emit BiddingUnlocked();
    }

    function withdrawFunds() external onlyOwner {
        uint256 usdcBalance = usdc.balanceOf(address(this));
        uint256 kwentaBalance = kwenta.balanceOf(address(this));

        if (usdcBalance > 0) {
            usdc.transfer(owner(), usdcBalance);
        }

        if (kwentaBalance > 0) {
            kwenta.transfer(owner(), kwentaBalance);
        }

        emit FundsWithdrawn(owner(), usdcBalance, kwentaBalance);
    }
}
