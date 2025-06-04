// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/VotingSession.sol";

contract VotingSessionTest is Test {
    VotingSession public voting;
    address admin = address(1);
    address nonAdmin = address(2);

    function setUp() public {
        vm.prank(admin);
        voting = new VotingSession();
    }

    function testStartVotingByAdmin() public {
        vm.prank(admin);
        voting.startVoting(block.timestamp + 10, block.timestamp + 100);
        assertTrue(voting.sessionInitialized());
    }

    function test_Revert_StartVotingByNonAdmin() public {
        vm.prank(nonAdmin);
        vm.expectRevert("Only admin can call this.");
        voting.startVoting(block.timestamp + 10, block.timestamp + 100);
    }

    function test_Revert_StartWithInvalidTimes() public {
        vm.prank(admin);
        vm.expectRevert("End must be after start.");
        voting.startVoting(block.timestamp + 100, block.timestamp + 10);
    }

    function testIsVotingOpen() public {
        vm.prank(admin);
        voting.startVoting(block.timestamp + 1, block.timestamp + 10);

        vm.warp(block.timestamp + 5);
        assertTrue(voting.isVotingOpen());

        vm.warp(block.timestamp + 11);
        assertFalse(voting.isVotingOpen());
    }

    function testEndVotingManually() public {
        vm.prank(admin);
        voting.startVoting(block.timestamp + 1, block.timestamp + 10);

        vm.prank(admin);
        voting.endVoting();

        assertLe(voting.votingEnd(), block.timestamp);
    }

    function testGetRemainingTime() public {
        vm.prank(admin);
        voting.startVoting(block.timestamp + 1, block.timestamp + 10);

        vm.warp(block.timestamp + 5);
        uint256 remaining = voting.getRemainingTime();
        assertEq(remaining, 5);
    }
}
