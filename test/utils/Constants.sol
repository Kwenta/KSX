// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

/// @title Contract for defining constants used in testing
contract Constants {
    /*//////////////////////////////////////////////////////////////
                            AUCTION CONSTANTS
    //////////////////////////////////////////////////////////////*/

    uint256 internal constant AUCTION_TEST_VALUE = 1000e6;

    uint256 internal constant TEST_VALUE = 100 ether;

    uint256 internal constant STARTING_BID = 10 ether;

    uint256 internal constant BID_BUFFER = 1 ether;

    address internal constant OWNER = address(0x01);

    address internal constant ACTOR1 = address(0xa1);

    address internal constant ACTOR2 = address(0xa2);

    address internal constant BAD_ACTOR = address(0xa3);

    address internal constant PDAOADDR =
        0xe826d43961a87fBE71C91d9B73F7ef9b16721C07;

    uint8 internal constant DECIMAL_OFFSET = 3;

    uint256 internal constant BASE_BLOCK_NUMBER = 8_225_680;
}
