// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract SignatureVerifierEIP712 {
    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
    }
    // bytes32 salt; not required

    // The hash of the EIP721 domain struct
    bytes32 constant EIP712DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    // Here is where things get a bit hairy
    // Since we want to make sure signatures ONLY work for our contract, on our chain, with our application
    // We need to define some variables
    // Often, it's best to make these immutables so they can't ever change
    EIP712Domain eip_712_domain_separator_struct;
    bytes32 public immutable i_domain_separator;

    constructor() {
        // Here, we define what our "domain" struct looks like.
        eip_712_domain_separator_struct = EIP712Domain({
            name: "SignatureVerifier", // this can be whatever you want
            version: "1", // this can be whatever you want
            chainId: 1, // ideally this is your chainId
            verifyingContract: address(this) // ideally, you set this as "this", but you could make it whatever contract
                // you want to use to verify signatures
        });

        // Then, we define who is going to verify our signatures? Now that we know what the format of our domain is
        i_domain_separator = keccak256(
            abi.encode(
                EIP712DOMAIN_TYPEHASH,
                keccak256(bytes(eip_712_domain_separator_struct.name)),
                keccak256(bytes(eip_712_domain_separator_struct.version)),
                eip_712_domain_separator_struct.chainId,
                eip_712_domain_separator_struct.verifyingContract
            )
        );
    }

    struct Message {
        uint256 number;
    }

    bytes32 public constant MESSAGE_TYPEHASH = keccak256("Message(uint256 number)");

    function getSignerEIP712(uint256 message, uint8 _v, bytes32 _r, bytes32 _s) public view returns (address) {
        // Arguments when calculating hash to validate
        // 1: byte(0x19) - the initial 0x19 byte
        // 2: byte(1) - the version byte
        // 3: hashstruct of domain separator (includes the typehash of the domain struct)
        // 4: hashstruct of message (includes the typehash of the message struct)

        bytes1 prefix = bytes1(0x19);
        bytes1 eip712Version = bytes1(0x01); // EIP-712 is version 1 of EIP-191
        bytes32 hashStructOfDomainSeparator = i_domain_separator;

        // hash the message struct
        bytes32 hashedMessage = keccak256(abi.encode(MESSAGE_TYPEHASH, Message({number: message})));

        // And finally, combine them all
        bytes32 digest = keccak256(abi.encodePacked(prefix, eip712Version, hashStructOfDomainSeparator, hashedMessage));
        return ecrecover(digest, _v, _r, _s);
    }

    function verifySigner712(uint256 message, uint8 _v, bytes32 _r, bytes32 _s, address signer)
        public
        view
        returns (bool)
    {
        address actualSigner = getSignerEIP712(message, _v, _r, _s);

        require(signer == actualSigner);
        return true;
    }
}
