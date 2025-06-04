// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol"; // Add console import
import "../src/Voting.sol";

contract VotingTest is Test {
    Voting voting;
    address owner = address(0xABCD);
    address alice = address(0x1111);
    address bob = address(0x2222);
    uint256 sessionId = 1;

    function setUp() public {
        // Label wallet[0] sebagai owner
        vm.prank(owner);
        voting = new Voting();
        console.log("Voting contract deployed at:", address(voting));
    }

    function testRegisterAndVote() public {
        console.log("=== Starting testRegisterAndVote ===");
        
        // 1. Register dua kandidat
        vm.prank(owner);
        voting.registerCandidate(sessionId, alice, "Alice");
        console.log("Registered candidate Alice:", alice);

        vm.prank(owner);
        voting.registerCandidate(sessionId, bob, "Bob");
        console.log("Registered candidate Bob:", bob);

        // 2. Alice vote ke Bob
        vm.prank(alice);
        voting.vote(sessionId, bob);
        console.log("Alice voted for Bob");

        // 3. Bob vote ke dirinya sendiri
        vm.prank(bob);
        voting.vote(sessionId, bob);
        console.log("Bob voted for himself");

        // 4. Cek hasil voteCount
        uint256 countBob = voting.getVoteCount(sessionId, bob);
        console.log("Bob's vote count:", countBob);
        assertEq(countBob, 2);

        // 5. Cek getCandidates mengembalikan array benar
        (address[] memory addrs, string[] memory names) = voting.getCandidates(
            sessionId
        );
        console.log("Total candidates:", addrs.length);
        for (uint i = 0; i < addrs.length; i++) {
            console.log("Candidate %s: %s at address %s", i, names[i], addrs[i]);
        }
        assertEq(addrs.length, 2);
        assertEq(names[0], "Alice");
        assertEq(names[1], "Bob");
        
        console.log("=== testRegisterAndVote completed successfully ===");
    }

    function testCannotVoteTwice() public {
        console.log("=== Starting testCannotVoteTwice ===");
        
        vm.prank(owner);
        voting.registerCandidate(sessionId, alice, "Alice");
        console.log("Registered candidate Alice:", alice);

        vm.prank(alice);
        voting.vote(sessionId, alice);
        console.log("Alice voted for herself");

        // Alice coba vote lagi → revert
        console.log("Attempting to vote again with Alice (should revert)...");
        vm.prank(alice);
        vm.expectRevert("Already voted in this session");
        voting.vote(sessionId, alice);
        
        console.log("=== testCannotVoteTwice completed successfully ===");
    }
}
