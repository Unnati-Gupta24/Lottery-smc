// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery{

    address manager;
    address payable[] public players;

    constructor(){
        manager = msg.sender;
    }

    function alreadyEnterCheck() private view returns(bool){
        for(uint i=0;i<players.length;i++){
            if(players[i]==msg.sender){
                return true;
            }
        }
    return false;
    }

    function enter() payable public{
        require(msg.sender != manager,"Manager cannot enter");
        require(alreadyEnterCheck() == false,"You have already registered");
        require(msg.value > 1 ether,"Minimum amount should be paid");
        players.push(payable(msg.sender));
    }

//this is not the right way to generate a random number because 
//1) it leads to concensus issue meaning every node will give different random no. resulting in clash among all nodes.
//2) miner manipulation means any hacker can easily predict the outcome and increase his chances.
//using chainlink we can have a better approach but for now let's use it
    function random() private view returns(uint){
        return uint(sha256(abi.encodePacked(block.difficulty,block.timestamp,players)));
    }

    function pickWinner() public {
        require(msg.sender == manager,"Only manager can pick winner");
        uint index = random() % players.length;
        payable(players[index]).transfer(getBalance());
        players = new address payable[](0);
    }

    function getBalance() private view returns(uint){
        return address(this).balance;
    }
     
    function getPlayers() public view returns(address payable[] memory){
        return players;
    }
     
    function getManager() public view returns(address){
        return manager;
    }
}
