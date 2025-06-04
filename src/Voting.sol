// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Voting is Ownable(msg.sender) {
    // --- Structs & Mappings ---
    struct Candidate {
        address addr;
        string name;
    }

    // sessionId → list kandidat
    mapping(uint256 => Candidate[]) public sessionCandidates;
    // sessionId → candidateAddr → voteCount
    mapping(uint256 => mapping(address => uint256)) public voteCounts;
    // sessionId → voterAddr → hasVoted? (bisa untuk cap one-vote-per-voter)
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    // --- Events ---
    event CandidateRegistered(
        uint256 indexed sessionId,
        address indexed candidate,
        string name
    );
    event Voted(
        uint256 indexed sessionId,
        address indexed candidate,
        address indexed voter
    );

    // --- Fungsi untuk register kandidat (oleh owner) ---
    function registerCandidate(
        uint256 sessionId,
        address candidateAddr,
        string memory name
    ) external onlyOwner {
        require(candidateAddr != address(0), "Invalid candidate address");
        // Tambahkan ke array kandidat
        sessionCandidates[sessionId].push(
            Candidate({addr: candidateAddr, name: name})
        );
        emit CandidateRegistered(sessionId, candidateAddr, name);
    }

    // --- Fungsi untuk voting ---
    function vote(uint256 sessionId, address candidateAddr) external {
        // Cek kandidat exist
        bool found = false;
        for (uint i = 0; i < sessionCandidates[sessionId].length; i++) {
            if (sessionCandidates[sessionId][i].addr == candidateAddr) {
                found = true;
                break;
            }
        }
        require(found, "Candidate not registered");

        // Cek apakah voter sudah vote di session ini
        require(
            !hasVoted[sessionId][msg.sender],
            "Already voted in this session"
        );

        // Catat vote
        voteCounts[sessionId][candidateAddr] += 1;
        hasVoted[sessionId][msg.sender] = true;

        emit Voted(sessionId, candidateAddr, msg.sender);
    }

    // --- View helper: ambil list kandidat (address & name) ---
    function getCandidates(
        uint256 sessionId
    ) external view returns (address[] memory addrs, string[] memory names) {
        uint256 len = sessionCandidates[sessionId].length;
        addrs = new address[](len);
        names = new string[](len);
        for (uint i = 0; i < len; i++) {
            addrs[i] = sessionCandidates[sessionId][i].addr;
            names[i] = sessionCandidates[sessionId][i].name;
        }
    }

    // --- View helper: ambil voteCount per kandidat ---
    function getVoteCount(
        uint256 sessionId,
        address candidateAddr
    ) external view returns (uint256) {
        return voteCounts[sessionId][candidateAddr];
    }
}
