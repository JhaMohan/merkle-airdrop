// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract SignatureVerifierEIP191 {
    function getSignerEIP191(uint256 message, uint8 v, bytes32 r, bytes32 s) public view returns (address) {
        // Arguments when calculating hash to validate
        // 1: bytes(0x19): the initial 0x19 bytes
        // 2: bytes(0): the version type
        // 3: version specific data,for version 0,it's the intended validator address
        // 4-6: Application specific data

        bytes1 prefixData = bytes1(0x19);
        bytes1 eip191Version = bytes1(0);
        address intendedValidatorAddress = address(this);
        bytes32 applicationSpecificData = bytes32(message);

        bytes32 hashedMessage =
            keccak256(abi.encodePacked(prefixData, eip191Version, intendedValidatorAddress, applicationSpecificData));

        address signer = ecrecover(hashedMessage, v, r, s);
        return signer;
    }

    function verifySignerSimple(uint256 message, uint8 _v, bytes32 _r, bytes32 _s, address signer)
        public
        view
        returns (bool)
    {
        address actualSigner = getSignerEIP191(message, _v, _r, _s);
        require(actualSigner == signer);
        return true;
    }
}
