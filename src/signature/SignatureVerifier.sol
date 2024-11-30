// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract SignatureVerifier {
    function getSignerSimple(uint256 message, uint8 _v, bytes32 _r, bytes32 _s) public pure returns (address) {
        bytes32 hashedMessage = bytes32(message); // if string,we'd use keccak256(abi.encodedPacked(string))
        address signer = ecrecover(hashedMessage, _v, _r, _s);
        return signer;
    }

    function verifySignerSimple(uint256 message, uint8 _v, bytes32 _r, bytes32 _s, address signer)
        public
        pure
        returns (bool)
    {
        address actualSigner = getSignerSimple(message, _v, _r, _s);
        require(actualSigner == signer);
        return true;
    }
}
