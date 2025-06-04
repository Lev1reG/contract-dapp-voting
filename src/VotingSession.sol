// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VotingSession {
    address public admin;

    struct Session {
        uint256 start;
        uint256 end;
        bool initialized;
    }

    mapping(uint256 => Session) public sessions;

    event VotingSessionCreated(uint256 indexed sessionId, uint256 start, uint256 end);
    event VotingSessionEnded(uint256 indexed sessionId, uint256 endTime);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this.");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function createSession(uint256 sessionId, uint256 start, uint256 end) external onlyAdmin {
        require(!sessions[sessionId].initialized, "Already created");
        require(end > start && end > block.timestamp, "Invalid time");

        sessions[sessionId] = Session(start, end, true);
        emit VotingSessionCreated(sessionId, start, end);
    }

    function endSession(uint256 sessionId) external onlyAdmin {
        require(sessions[sessionId].initialized, "Not initialized");
        sessions[sessionId].end = block.timestamp;
        emit VotingSessionEnded(sessionId, block.timestamp);
    }

    function isVotingOpen(uint256 sessionId) public view returns (bool) {
        Session memory s = sessions[sessionId];
        return s.initialized && block.timestamp >= s.start && block.timestamp <= s.end;
    }
}
