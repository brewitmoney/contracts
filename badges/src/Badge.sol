// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ITokenRenderer} from "./interfaces/ITokenRenderer.sol";

import {ERC1155} from "solady/tokens/ERC1155.sol";
import {OwnableRoles} from "solady/auth/OwnableRoles.sol";

contract BrewitBadge is ERC1155, OwnableRoles {
    error Soulbound();
    error AlreadyMinted();
    error InvalidQuantity();

    event RendererUpdated(address indexed oldRenderer, address indexed newRenderer);
    event ContractURIUpdated(string oldURI, string newURI);

    uint256 public constant MINTER_ROLE = _ROLE_0;

    ITokenRenderer public renderer;
    string public contractURI;

    constructor(ITokenRenderer _renderer, address owner, string memory _contractURI) {
        renderer = _renderer;
        _initializeOwner(owner);
        contractURI = _contractURI;
    }

    function name() public view virtual returns (string memory) {
        return "Brewit Badges";
    }

    function symbol() public view virtual returns (string memory) {
        return "BREWIT_BADGE";
    }

    function uri(uint256 id) public view virtual override returns (string memory) {
        return renderer.tokenURI(id);
    }

    function setRenderer(ITokenRenderer _renderer) public onlyOwner {
        emit RendererUpdated(address(renderer), address(_renderer));
        renderer = _renderer;
    }

    function setContractURI(string memory _contractURI) public onlyOwner {
        emit ContractURIUpdated(contractURI, _contractURI);
        contractURI = _contractURI;
    }

    function mint(address account, uint256 id) public onlyRoles(MINTER_ROLE) {
        _mint(account, id, 1, "");
    }

    function _beforeTokenTransfer(address from, address to, uint256[] memory ids, uint256[] memory, bytes memory)
        internal
        view
        override
    {
        if (from != address(0)) {
            revert Soulbound();
        }
        if (ids.length != 1) {
            revert InvalidQuantity();
        }
        if (balanceOf(to, ids[0]) > 0) {
            revert AlreadyMinted();
        }
    }

    function _useBeforeTokenTransfer() internal pure override returns (bool) {
        return true;
    }
}