// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/VotingSession.sol";

contract VotingSessionTest is Test {
    VotingSession public session;

    address public admin = address(1);
    address public attacker = address(2);
    uint256 public sessionId = 123;

    function setUp() public {
        vm.prank(admin);
        session = new VotingSession();
    }

    function test_CreateSession_Valid() public {
        vm.prank(admin);
        session.createSession(sessionId, block.timestamp + 10, block.timestamp + 100);

        (uint256 start, uint256 end, bool initialized) = session.sessions(sessionId);
        assertTrue(initialized);
        assertEq(start, block.timestamp + 10);
        assertEq(end, block.timestamp + 100);
    }

    function test_Revert_CreateSession_Twice() public {
        vm.prank(admin);
        session.createSession(sessionId, block.timestamp + 10, block.timestamp + 100);

        vm.expectRevert("Already created");
        vm.prank(admin);
        session.createSession(sessionId, block.timestamp + 20, block.timestamp + 200);
    }

    function test_Revert_CreateSession_InvalidTime() public {
        vm.prank(admin);
        vm.expectRevert("Invalid time");
        session.createSession(sessionId, block.timestamp + 100, block.timestamp + 50); // end < start
    }

    function test_Revert_NonAdmin_CreateSession() public {
        vm.prank(attacker);
        vm.expectRevert("Only admin can call this.");
        session.createSession(sessionId, block.timestamp + 10, block.timestamp + 100);
    }

    function test_IsVotingOpen_TrueAndFalseCases() public {
        vm.prank(admin);
        session.createSession(sessionId, block.timestamp + 10, block.timestamp + 50);

        vm.warp(block.timestamp + 5);
        assertFalse(session.isVotingOpen(sessionId));

        vm.warp(block.timestamp + 15);
        assertTrue(session.isVotingOpen(sessionId));

        vm.warp(block.timestamp + 60);
        assertFalse(session.isVotingOpen(sessionId));
    }

    function test_EndSession() public {
        vm.prank(admin);
        session.createSession(sessionId, block.timestamp + 10, block.timestamp + 100);

        vm.warp(block.timestamp + 20);
        vm.prank(admin);
        session.endSession(sessionId);

        (, uint256 endedAt,) = session.sessions(sessionId);
        assertEq(endedAt, block.timestamp);
    }

    function test_Revert_EndSession_Unauthorized() public {
        vm.prank(admin);
        session.createSession(sessionId, block.timestamp + 10, block.timestamp + 100);

        vm.prank(attacker);
        vm.expectRevert("Only admin can call this.");
        session.endSession(sessionId);
    }
}
