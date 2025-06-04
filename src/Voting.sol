// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./VotingSession.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Voting is VotingSession, Ownable(msg.sender) {
    struct Candidate {
        address addr;
        string name;
    }

    mapping(uint256 => Candidate[]) public sessionCandidates;
    mapping(uint256 => mapping(address => uint256)) public voteCounts;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    mapping(uint256 => mapping(address => bool)) public isEligible;

    event CandidateRegistered(uint256 indexed sessionId, address indexed candidate, string name);
    event Voted(uint256 indexed sessionId, address indexed candidate, address indexed voter);
    event VoterEligibilityUpdated(uint256 indexed sessionId, address voter, bool eligible);

    modifier votingOpen(uint256 sessionId) {
        require(isVotingOpen(sessionId), "Voting is not open");
        _;
    }

    function updateEligibility(uint256 sessionId, address[] calldata voters, bool eligible) external onlyOwner {
        for (uint256 i = 0; i < voters.length; i++) {
            isEligible[sessionId][voters[i]] = eligible;
            emit VoterEligibilityUpdated(sessionId, voters[i], eligible);
        }
    }

    function registerCandidate(uint256 sessionId, address candidateAddr, string memory name) external onlyOwner {
        require(candidateAddr != address(0), "Invalid candidate address");
        sessionCandidates[sessionId].push(Candidate(candidateAddr, name));
        emit CandidateRegistered(sessionId, candidateAddr, name);
    }

    function vote(uint256 sessionId, address candidateAddr) external votingOpen(sessionId) {
        require(isEligible[sessionId][msg.sender], "Not eligible");
        require(!hasVoted[sessionId][msg.sender], "Already voted");

        bool found = false;
        for (uint256 i = 0; i < sessionCandidates[sessionId].length; i++) {
            if (sessionCandidates[sessionId][i].addr == candidateAddr) {
                found = true;
                break;
            }
        }
        require(found, "Candidate not registered");

        voteCounts[sessionId][candidateAddr] += 1;
        hasVoted[sessionId][msg.sender] = true;

        emit Voted(sessionId, candidateAddr, msg.sender);
    }

    function getCandidates(uint256 sessionId) external view returns (address[] memory addrs, string[] memory names) {
        uint256 len = sessionCandidates[sessionId].length;
        addrs = new address[](len);
        names = new string[](len);
        for (uint256 i = 0; i < len; i++) {
            addrs[i] = sessionCandidates[sessionId][i].addr;
            names[i] = sessionCandidates[sessionId][i].name;
        }
    }

    function getVoteCount(uint256 sessionId, address candidateAddr) external view returns (uint256) {
        return voteCounts[sessionId][candidateAddr];
    }

    function getWinner(uint256 sessionId)
        external
        view
        returns (address winner, string memory name, uint256 highestVotes)
    {
        uint256 maxVotes = 0;
        for (uint256 i = 0; i < sessionCandidates[sessionId].length; i++) {
            address candidateAddr = sessionCandidates[sessionId][i].addr;
            uint256 votes = voteCounts[sessionId][candidateAddr];
            if (votes > maxVotes) {
                maxVotes = votes;
                winner = candidateAddr;
                name = sessionCandidates[sessionId][i].name;
            }
        }
        highestVotes = maxVotes;
    }
}
