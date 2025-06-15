// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {BrewitBadge} from "./Badge.sol";
import {SignatureCheckerLib} from "solady/utils/SignatureCheckerLib.sol";
import {Ownable} from "solady/auth/Ownable.sol";
import {EIP712} from "solady/utils/EIP712.sol";

contract BadgeMinter is Ownable, EIP712 {
    error InvalidSignature();
    error ZeroAddress();

    event SignerUpdated(address indexed oldSigner, address indexed newSigner);

    BrewitBadge immutable badge;
    bytes32 public constant MINT_TYPEHASH = keccak256("Mint(address to,uint256 tokenId)");

    address public signer;

    constructor(BrewitBadge _badge, address owner) {
        _initializeOwner(owner);
        badge = _badge;
    }

    function mintBadge(address account, uint256 tokenId, bytes calldata signature) public {
        bytes32 messageHash = _hashTypedData(keccak256(abi.encode(MINT_TYPEHASH, account, tokenId)));
        if (!SignatureCheckerLib.isValidSignatureNowCalldata(signer, messageHash, signature)) {
            revert InvalidSignature();
        }
        badge.mint(account, tokenId);
    }

    function setSigner(address _signer) public onlyOwner {
        if (_signer == address(0)) revert ZeroAddress();
        address oldSigner = signer;
        signer = _signer;
        emit SignerUpdated(oldSigner, _signer);
    }

    function _domainNameAndVersion() internal pure override returns (string memory, string memory) {
        return ("BadgeMinter", "1");
    }
}