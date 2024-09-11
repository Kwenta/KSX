// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @title USDC-KWENTA Auction Contract
/// @author Flocqst (florian@kwenta.io)
contract Auction is Ownable, Initializable {
    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted when the auction starts
    event Start();

    /// @notice Emitted when a bid is placed
    /// @param sender The address of the bidder
    /// @param amount The amount of the bid
    event Bid(address indexed sender, uint256 amount);

    /// @notice Emitted when a bidder withdraws their non-winning bids
    /// @param bidder The address of the bidder
    /// @param amount The amount of funds withdrawn
    event Withdraw(address indexed bidder, uint256 amount);

    /// @notice Emitted when the auction ends
    /// @param winner The address of the winner
    /// @param amount The amount of the winning bid
    event End(address winner, uint256 amount);

    /// @notice Emitted when the bid increment is updated
    /// @param newBidIncrement The new bid increment value
    event BidBufferUpdated(uint256 newBidIncrement);

    /// @notice Emitted when bidding is locked
    event BiddingLocked();

    /// @notice Emitted when bidding is unlocked
    event BiddingUnlocked();

    /// @notice Emitted when funds are withdrawn by the owner
    /// @param owner The address of the owner
    /// @param usdcAmount The amount of USDC withdrawn
    /// @param kwentaAmount The amount of KWENTA withdrawn
    event FundsWithdrawn(
        address indexed owner, uint256 usdcAmount, uint256 kwentaAmount
    );

    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice Thrown when trying to start the auction when it is already started
    error AuctionAlreadyStarted();

    /// @notice Thrown when trying to bid or settle on an auction that has not started yet
    error AuctionNotStarted();

    /// @notice Thrown when trying to bid on an auction that has already ended
    error AuctionAlreadyEnded();

    /// @notice Throw when the bid amount is too low to be accepted
    /// @param highestBidPlusBuffer The required minimum bid amount
    error BidTooLow(uint256 highestBidPlusBuffer);

    /// @notice Thrown when trying to settle an auction that has not ended yet
    error AuctionNotEnded();

    /// @notice Thrown when trying to settle an auction that has already been settled
    error AuctionAlreadySettled();

    /// @notice Thrown when trying to lock bidding when it is already locked
    error BiddingLockedErr();

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    /// @notice Contract for USDC ERC20 token
    IERC20 public usdc;

    /// @notice Contract for KWENTA ERC20 token
    IERC20 public kwenta;

    /// @notice The amount of USDC to be auctioned
    uint256 public auctionAmount;

    /// @notice The starting bid amount
    uint256 public startingBid;

    /// @notice The minimum amount that a bid must be above the current highest bid
    uint256 public bidBuffer;

    /// @notice The timestamp at which the auction ends
    uint256 public endAt;

    /// @notice Indicates if the auction has started.
    bool public started;

    /// @notice Indicates if the auction has been settled.
    bool public settled;

    /// @notice Indicates if bidding is locked
    bool public locked;

    /// @notice The address of the highest bidder
    address public highestBidder;

    /// @notice The amount of the highest bid
    uint256 public highestBid;

    /// @notice Mapping of bidders to their bids
    mapping(address => uint256) public bids;

    /*///////////////////////////////////////////////////////////////
                        CONSTRUCTOR / INITIALIZER
    ///////////////////////////////////////////////////////////////*/

    /// @dev Actual contract construction will take place in the initialize function via proxy
    /// @param initialOwner The address of the owner of this contract
    /// @param _usdc The address for the USDC ERC20 token
    /// @param _kwenta The address for the KWENTA ERC20 token
    /// @param _startingBid The starting bid amount
    /// @param _bidBuffer The initial bid buffer amount
    constructor(
        address initialOwner,
        address _usdc,
        address _kwenta,
        uint256 _startingBid,
        uint256 _bidBuffer
    ) Ownable(initialOwner) {
        usdc = IERC20(_usdc);
        kwenta = IERC20(_kwenta);

        highestBid = _startingBid;
        bidBuffer = _bidBuffer;
    }

    /// @notice Initializes the auction contract
    /// @param initialOwner The address of the owner of this contract
    /// @param _usdc The address for the USDC ERC20 token
    /// @param _kwenta The address for the KWENTA ERC20 token
    /// @param _startingBid The starting bid amount
    /// @param _bidBuffer The initial bid buffer amount
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

    /*///////////////////////////////////////////////////////////////
                        AUCTION OPERATIONS
    ///////////////////////////////////////////////////////////////*/

    /// @notice Starts the auction
    /// @param _auctionAmount The amount of USDC to be auctioned
    /// @dev Can only be called by the owner once
    function start(uint256 _auctionAmount) external onlyOwner {
        if (started) revert AuctionAlreadyStarted();

        usdc.transferFrom(msg.sender, address(this), _auctionAmount);
        auctionAmount = _auctionAmount;

        started = true;
        endAt = block.timestamp + 1 days;

        emit Start();
    }

    /// @notice Places a bid in the auction.
    /// @param amount The amount of KWENTA to bid.
    /// @dev The auction must be started, not ended, and the bid must be higher than the current highest bid plus buffer
    function bid(uint256 amount) external Lock {
        if (!started) revert AuctionNotStarted();
        if (block.timestamp >= endAt) revert AuctionAlreadyEnded();
        if (amount < highestBid + bidBuffer) {
            revert BidTooLow(highestBid + bidBuffer);
        }

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

    /// @notice Withdraws the callers non-winning bids
    function withdraw() external {
        uint256 bal = bids[msg.sender];
        bids[msg.sender] = 0;

        kwenta.transfer(msg.sender, bal);

        emit Withdraw(msg.sender, bal);
    }

    /// @notice Settles the auction
    function settleAuction() external {
        if (!started) revert AuctionNotStarted();
        if (block.timestamp < endAt) revert AuctionNotEnded();
        if (settled) revert AuctionAlreadySettled();

        settled = true;

        if (highestBidder != address(0)) {
            usdc.transfer(highestBidder, auctionAmount);
            kwenta.transfer(owner(), highestBid);
        } else {
            usdc.transfer(owner(), auctionAmount);
        }

        emit End(highestBidder, highestBid);
    }

    /// @notice Updates the minimum bid increment
    /// @param _bidBuffer The new bid buffer value
    function setBidIncrement(uint256 _bidBuffer) external onlyOwner {
        bidBuffer = _bidBuffer;
        emit BidBufferUpdated(_bidBuffer);
    }

    /// @notice Modifier to ensure that bidding is not locked
    modifier Lock() {
        if (locked) revert BiddingLockedErr();
        _;
    }

    /// @notice Locks bidding, preventing any new bids
    function lockBidding() external onlyOwner {
        locked = true;
        emit BiddingLocked();
    }

    /// @notice Unlocks bidding, allowing new bids to be placed
    function unlockBidding() external onlyOwner {
        locked = false;
        emit BiddingUnlocked();
    }

    /// @notice Withdraws all funds from the contract
    /// @dev Only callable by the owner. This is a safety feature only to be used in emergencies
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
