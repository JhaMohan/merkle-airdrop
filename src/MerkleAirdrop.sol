// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MerkleAirdrop is EIP712 {
    using SafeERC20 for IERC20;
    // some list of token
    // allow someone in the list to claim tokens

    /*//////////////////////////////////////////////////////////////
                                 ERROR
    //////////////////////////////////////////////////////////////*/
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();

    address[] claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address claimer => bool claimed) private s_hasClaimed;

    bytes32 private constant CLAIM_TYPE_HASH = keccak256("AirdropClaim(address account,uint256 amount)");

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    event Claim(address user, uint256 amount);

    constructor(bytes32 merkleRoot, IERC20 airdropToken) EIP712('AirDrop','1'){
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    // CEI
    function claim(address account, uint256 amount, bytes32[] calldata merkleProof,uint8 v,bytes32 r,bytes32 s) external {
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }
        // validate signature
        if(!_validateSignature(account,getMessageHash(account,amount),v,r,s)) {
            revert MerkleAirdrop__InvalidSignature();
        }

        // check
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }
        // effect
        s_hasClaimed[account] = true;
        emit Claim(account, amount);

        // interaction
        i_airdropToken.safeTransfer(account, amount);
    }

    function getMessageHash(address account,uint256 amount) public view returns(bytes32) {
       return _hashTypedDataV4(keccak256(abi.encode(CLAIM_TYPE_HASH,AirdropClaim({account:account,amount:amount}))));
    }


    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }

    function _validateSignature(address account,bytes32 digest,uint8 v,bytes32 r,bytes32 s) internal pure returns(bool) {
       (address actualSigner, ,)  = ECDSA.tryRecover(digest,v,r,s);
       return account == actualSigner;
    }

}
