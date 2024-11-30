// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from '../src/MerkleAirdrop.sol';
import {DevOpsTools} from 'foundry-devops/src/DevOpsTools.sol';

contract ClaimAirdrop is Script {
  address CLAIM_ACCOUNT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
  uint256 CLAIM_AMOUNT = 25 * 1e18;
  bytes32 PROOF_ONE=0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
  bytes32 PROOF_TWO=0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
  bytes32[] proof = [PROOF_ONE, PROOF_TWO];
  bytes private SIGNATURE = hex'31c2824f493a58e3f11be5506cd4ad1262c67205082aae421c1812e49400026068713d562d08302367d7e7ce3ef6ba4246a94322adde853d555963c72ba74c851c';

  error ClaimAirdrop__InvalidSignatureLength();

  function claimAirdrop(address airDrop) public {
    vm.startBroadcast();
    (uint8 v,bytes32 r,bytes32 s) = splitSignature(SIGNATURE);
    MerkleAirdrop(airDrop).claim(CLAIM_ACCOUNT,CLAIM_AMOUNT,proof,v,r,s);
    vm.stopBroadcast();
  }

  function run() external {
    address latestDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirdrop",block.chainid);
    claimAirdrop(latestDeployed);
  }

  function splitSignature(bytes memory signature) public pure returns(uint8 v,bytes32 r,bytes32 s) {
    require(signature.length == 65,"invalid signature length");
    if(signature.length != 65) {
      revert ClaimAirdrop__InvalidSignatureLength();
    }

    assembly {
      r := mload(add(signature,32))
      s := mload(add(signature,64))
      v := byte(0,mload(add(signature,96)))
    }

  } 
}