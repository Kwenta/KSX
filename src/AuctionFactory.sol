// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Auction} from "./Auction.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

/// @title Auction Factory Contract for USDC-KWENTA Auctions
/// @author Flocqst (florian@kwenta.io)
contract AuctionFactory {
    /// @notice Address of the auction implementation contract
    address public auctionImplementation;

    /// @notice Array of all auctions created
    address[] public auctions;

    /// @notice Emitted when a new auction is created
    /// @param auctionContract The address of the newly created auction contract
    /// @param owner The address of the account that created the auction
    /// @param numAuctions The total number of auctions created
    /// @param allAuctions Array of all auction contract addresses
    event AuctionCreated(
        address auctionContract,
        address owner,
        uint256 numAuctions,
        address[] allAuctions
    );

    /// @notice Constructs the AuctionFactory with the address of the auction implementation contract
    /// @param _auctionImplementation The address of the auction implementation contract
    constructor(address _auctionImplementation) {
        auctionImplementation = _auctionImplementation;
    }

    /// @notice Creates a new auction by cloning the auction implementation contract
    /// @param _owner The address of the DAO that owns the auction
    /// @param _usdc The address for the USDC ERC20 token
    /// @param _kwenta The address for the KWENTA ERC20 token
    /// @param _startingBid The starting bid amount
    /// @param _bidBuffer The initial bid buffer amount
    /// @dev The newly created auction contract is initialized and added to the auctions array
    function createAuction(
        address _owner,
        address _usdc,
        address _kwenta,
        uint256 _startingBid,
        uint256 _bidBuffer
    ) external {
        address clone = Clones.clone(auctionImplementation);
        Auction(clone).initialize(
            _owner, _usdc, _kwenta, _startingBid, _bidBuffer
        );
        Auction newAuction =
            new Auction(_owner, _usdc, _kwenta, _startingBid, _bidBuffer);
        auctions.push(address(newAuction));

        emit AuctionCreated(
            address(newAuction), msg.sender, auctions.length, auctions
        );
    }

    /// @notice Returns the array of all auction contract addresses
    function getAllAuctions() external view returns (address[] memory) {
        return auctions;
    }
}
