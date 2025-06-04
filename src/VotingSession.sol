// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VotingSession {
    address public admin;

    uint256 public votingStart;
    uint256 public votingEnd;
    bool public sessionInitialized;

    event VotingSessionStarted(uint256 startTime, uint256 endTime);
    event VotingSessionEnded(uint256 endTime);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this.");
        _;
    }

    modifier sessionOngoing() {
        require(isVotingOpen(), "Voting is not open.");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function startVoting(uint256 startTime, uint256 endTime) external onlyAdmin {
        require(!sessionInitialized, "Session already started.");
        require(endTime > startTime, "End must be after start.");
        require(endTime > block.timestamp, "End must be in future.");

        votingStart = startTime;
        votingEnd = endTime;
        sessionInitialized = true;

        emit VotingSessionStarted(startTime, endTime);
    }

    function endVoting() external onlyAdmin {
        require(sessionInitialized, "No session to end.");
        votingEnd = block.timestamp;
        emit VotingSessionEnded(votingEnd);
    }

    function isVotingOpen() public view returns (bool) {
        return sessionInitialized && block.timestamp >= votingStart && block.timestamp <= votingEnd;
    }

    function getRemainingTime() external view returns (uint256) {
        if (block.timestamp >= votingEnd) return 0;
        return votingEnd - block.timestamp;
    }
}
