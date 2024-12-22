// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {PlayPitch} from "./PlayPitch.sol";

contract PlayPitchFactory{
    address public owner;
    bool public pause;

    struct GameFund{
        address GameFundAddress;
        address owner;
        uint256 creationTime;
        string name;
    }

    GameFund[] public gamefunds;
    mapping (address => GameFund[]) public userGameFunds;

    modifier onlyOwner(){
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier NotPaused(){
        require(!pause, "Factory is paused" );
        _;
    }

    constructor(){
        owner = msg.sender;
    }

    function createGameFund(
        string memory _name,
        string memory _description,
        uint256 _goal,
        uint256 _deadline
    ) external NotPaused{
        PlayPitch newGameFund = new PlayPitch(
            msg.sender,
            _name,
            _description,
            _goal,
            _deadline
        );
        address GameFundAddress = address(newGameFund);

        GameFund memory gamefund = GameFund({
            GameFundAddress : GameFundAddress,
            owner : msg.sender,
            name : _name,
            creationTime: block.timestamp
        });

        gamefunds.push(gamefund);
        userGameFunds[msg.sender].push(gamefund);

    }

    function getUserGameFunds(address _user) external view returns (GameFund[] memory){
        return userGameFunds[_user];
    }

    function getallGameFunds() external view returns(GameFund[] memory){
        return gamefunds;
    }

    function togglePaused() external onlyOwner{
        pause = !pause;
    }
}