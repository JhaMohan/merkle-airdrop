// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {MilitaryToken} from "../src/MilitaryToken.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 private root = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 private AMOUNT_TO_MINT = 4 * 25 * 1e18;

    function deployToken() public returns (MerkleAirdrop, MilitaryToken) {
        vm.startBroadcast();
        MilitaryToken militaryToken = new MilitaryToken();
        MerkleAirdrop merkleAirdrop = new MerkleAirdrop(root, militaryToken);
        militaryToken.mint(address(merkleAirdrop), AMOUNT_TO_MINT);
        vm.stopBroadcast();
        return (merkleAirdrop, militaryToken);
    }

    function run() public returns (MerkleAirdrop, MilitaryToken) {
        return deployToken();
    }
}
