// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./verifier.sol";

contract VotingSystem {
    Verifier public verifier;
    
    struct Vote {
        bool hasVoted;
        uint256 timestamp;
    }
    
    struct VotingSession {
        string title;
        uint256 startTime;
        uint256 endTime;
        uint256 yesVotes;
        uint256 noVotes;
        mapping(address => Vote) votes;
        bool isActive;
    }
    
    mapping(uint256 => VotingSession) public votingSessions;
    uint256 public votingSessionCount;
    
    event VotingSessionCreated(uint256 indexed sessionId, string title, uint256 startTime, uint256 endTime);
    event VoteCast(uint256 indexed sessionId, address indexed voter, bool vote, uint256 timestamp);

    constructor(address _verifierAddress) {
        verifier = Verifier(_verifierAddress);
    }

    function createVotingSession(string memory _title, uint256 _duration) public {
        uint256 sessionId = votingSessionCount++;
        VotingSession storage session = votingSessions[sessionId];
        session.title = _title;
        session.startTime = block.timestamp;
        session.endTime = block.timestamp + _duration;
        session.isActive = true;

        emit VotingSessionCreated(sessionId, _title, session.startTime, session.endTime);
    }

    function castVote(
        uint256 _sessionId,
        Verifier.Proof memory proof,
        uint[3] memory input
    ) public {
        VotingSession storage session = votingSessions[_sessionId];
        require(session.isActive, "Voting session is not active");
        require(block.timestamp >= session.startTime && block.timestamp <= session.endTime, "Voting is not open");
        require(!session.votes[msg.sender].hasVoted, "Already voted in this session");
        
        // 驗證零知識證明
        require(verifier.verifyTx(proof, input), "Invalid proof");
        
        bool voteValue = input[1] == 1;  // 假設投票值在 input[1]
        
        session.votes[msg.sender] = Vote(true, block.timestamp);
        
        if (voteValue) {
            session.yesVotes++;
        } else {
            session.noVotes++;
        }
        
        emit VoteCast(_sessionId, msg.sender, voteValue, block.timestamp);
    }

    function getVoteCount(uint256 _sessionId) public view returns (uint256, uint256) {
        VotingSession storage session = votingSessions[_sessionId];
        return (session.yesVotes, session.noVotes);
    }

    function closeVotingSession(uint256 _sessionId) public {
        VotingSession storage session = votingSessions[_sessionId];
        require(session.isActive, "Voting session is not active");
        require(block.timestamp > session.endTime, "Voting session has not ended yet");
        session.isActive = false;
    }
}