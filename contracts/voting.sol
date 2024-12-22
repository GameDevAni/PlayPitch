// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



contract Voting {
    struct Proposal {
        string description;
        uint voteCount;
    }

    address public admin;
    mapping(address => bool) public hasVoted;
    Proposal[] public proposals;

    constructor(string[] memory proposalNames) {
        admin = msg.sender;
        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                description: proposalNames[i],
                voteCount: 0
            }));
        }
    }

    function vote(uint proposalIndex) external {
        require(!hasVoted[msg.sender], "You have already voted.");
        require(proposalIndex < proposals.length, "Invalid proposal.");

        hasVoted[msg.sender] = true;
        proposals[proposalIndex].voteCount += 1;
    }

    function getProposals() external view returns (Proposal[] memory) {
        return proposals;
    }

    function getWinner() external view returns (string memory) {
        uint winningVoteCount = 0;
        uint winningIndex = 0;

        for (uint i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winningIndex = i;
            }
        }

        return proposals[winningIndex].description;
}
}
