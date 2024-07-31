// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import { Auction } from './Auction.sol';
import "@openzeppelin/contracts/proxy/Clones.sol";


contract AuctionFactory {
    address public auctionImplementation;
    address[] public auctions;

    event AuctionCreated(address auctionContract, address owner, uint numAuctions, address[] allAuctions);

    constructor(address _auctionImplementation) {
        auctionImplementation = _auctionImplementation;
    }

    function createAuction(
        address _pDAO,
        address _usdc,
        address _kwenta,
        uint256 _startingBid,
        uint256 _bidBuffer
    ) external {
        address clone = Clones.clone(auctionImplementation);
        Auction(clone).initialize(_pDAO, _usdc, _kwenta, _startingBid, _bidBuffer);
        Auction newAuction = new Auction(_pDAO, _usdc, _kwenta, _startingBid, _bidBuffer);
        auctions.push(address(newAuction));

        emit AuctionCreated(address(newAuction), msg.sender, auctions.length, auctions);
    }

    function getAllAuctions() external view returns (address[] memory) {
        return auctions;
    }
}
