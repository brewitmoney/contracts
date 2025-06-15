// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ITokenRenderer} from "./interfaces/ITokenRenderer.sol";
import {Ownable} from "solady/auth/Ownable.sol";
import {LibString} from "solady/utils/LibString.sol";

contract BasicRenderer is ITokenRenderer, Ownable {
    using LibString for uint256;

    string private baseURI;
    string private uriSuffix;

    mapping(uint256 => string) private _tokenURIs;

    constructor(address owner, string memory _baseURI) {
        _initializeOwner(owner);
        baseURI = _baseURI;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (bytes(_tokenURIs[tokenId]).length > 0) {
            return _tokenURIs[tokenId];
        }
        return string.concat(baseURI, tokenId.toString(), uriSuffix);
    }

    function setBaseURI(string memory _baseURI) public onlyOwner {
        baseURI = _baseURI;
    }

    function setURISuffix(string memory _uriSuffix) public onlyOwner {
        uriSuffix = _uriSuffix;
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) public onlyOwner {
        _tokenURIs[tokenId] = _tokenURI;
    }
}