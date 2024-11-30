// SPDX-License-Identifier:MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {MilitaryToken} from "../src/MilitaryToken.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";
import {ZkSyncChainChecker} from "foundry-devops/src/ZkSyncChainChecker.sol";

contract MerkleAirdropTest is ZkSyncChainChecker, Test {
    MerkleAirdrop public merkleAirdrop;
    MilitaryToken public militaryToken;

    uint256 private AMOUNT_TO_CLAIM = 25 * 1e18;
    uint256 private AMOUNT_TO_MINT = AMOUNT_TO_CLAIM * 4;
    bytes32 private firstOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 private secondOne = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] private PROOF = [firstOne, secondOne];
    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    address gasPayer;
    address user;
    uint256 userPrivKey;

    function setUp() external {
        if (!isZkSyncChain()) {
            // deploy with script
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (merkleAirdrop, militaryToken) = deployer.run();
        } else {
            militaryToken = new MilitaryToken();
            merkleAirdrop = new MerkleAirdrop(ROOT, militaryToken);
            militaryToken.mint(address(merkleAirdrop), AMOUNT_TO_MINT);
        }

        (user, userPrivKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    function testUserCanClaim() public {
        uint256 startingBalance = militaryToken.balanceOf(user);
        console.log("startingBalance", startingBalance);

        bytes32 messageHash = merkleAirdrop.getMessageHash(user,AMOUNT_TO_CLAIM);
        // sing message
        // vm.prank(user);
        (uint8 v,bytes32 r,bytes32 s) = vm.sign(userPrivKey,messageHash);

        vm.prank(gasPayer);
        merkleAirdrop.claim(user, AMOUNT_TO_CLAIM, PROOF,v,r,s);

        uint256 afterBalance = militaryToken.balanceOf(user);
        console.log("afterbalance", afterBalance);
        assertEq(afterBalance - startingBalance, AMOUNT_TO_CLAIM);
    }
}
