// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Voting.sol";

contract VotingTest is Test {
    Voting public voting;

    address public owner = address(1);
    address public alice = address(2); // eligible voter
    address public bob = address(3); // ineligible voter
    address public candidate1 = address(4);
    address public candidate2 = address(5);

    uint256 public sessionId = 1;

    function setUp() public {
        vm.prank(owner);
        voting = new Voting();

        // Assign ownership manually since Voting uses Ownable(msg.sender)
        vm.startPrank(owner);
        voting.createSession(sessionId, block.timestamp + 10, block.timestamp + 100);
        voting.registerCandidate(sessionId, candidate1, "Alice");
        voting.registerCandidate(sessionId, candidate2, "Bob");

        address[] memory voters = new address[](1);
        voters[0] = alice;
        voting.updateEligibility(sessionId, voters, true);
        vm.stopPrank();
    }

    function test_Revert_When_Voting_Not_Started() public {
        vm.startPrank(alice);
        vm.expectRevert("Voting is not open");
        voting.vote(sessionId, candidate1);
        vm.stopPrank();
    }

    function test_Revert_When_Not_Eligible() public {
        vm.warp(block.timestamp + 20); // session active
        vm.startPrank(bob);
        vm.expectRevert("Not eligible");
        voting.vote(sessionId, candidate1);
        vm.stopPrank();
    }

    function test_Revert_When_DoubleVote() public {
        vm.warp(block.timestamp + 20);
        vm.startPrank(alice);
        voting.vote(sessionId, candidate1);
        vm.expectRevert("Already voted");
        voting.vote(sessionId, candidate2);
        vm.stopPrank();
    }

    function test_Revert_When_Voting_InvalidCandidate() public {
        vm.warp(block.timestamp + 20);
        vm.startPrank(alice);
        vm.expectRevert("Candidate not registered");
        voting.vote(sessionId, address(99));
        vm.stopPrank();
    }

    function test_Voting_Success() public {
        vm.warp(block.timestamp + 20);
        vm.startPrank(alice);
        voting.vote(sessionId, candidate1);
        vm.stopPrank();

        uint256 count = voting.getVoteCount(sessionId, candidate1);
        assertEq(count, 1);
    }

    function test_GetWinner() public {
        vm.warp(block.timestamp + 20);
        vm.startPrank(alice);
        voting.vote(sessionId, candidate2); // alice votes for candidate2
        vm.stopPrank();

        (address winnerAddr, string memory winnerName, uint256 votes) = voting.getWinner(sessionId);

        assertEq(winnerAddr, candidate2);
        assertEq(winnerName, "Bob");
        assertEq(votes, 1);
    }
}
