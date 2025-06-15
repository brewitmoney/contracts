// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface ITokenRenderer {
    function tokenURI(uint256 tokenId) external view returns (string memory);
}