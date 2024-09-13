// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

/// @title Contract for defining constants used in testing
contract Constants {

    uint256 public constant BASE_BLOCK_NUMBER = 8_225_680;

    address internal constant ACTOR = address(0xa1);

    address internal constant BAD_ACTOR = address(0xa2);

    address public constant PDAOADDR =
        0xe826d43961a87fBE71C91d9B73F7ef9b16721C07;

}
