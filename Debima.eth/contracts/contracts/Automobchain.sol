// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Automobchain {
    address owner;

    constructor() {
        owner = msg.sender;
    }
    //Add yourself as a renter 
    struct Renter {
        address payable walletAddress;
        string firstName;
        string lastName;
        bool canRent;
        bool active;
        uint balance;
        uint due;
        uint start;
        uint end;
    }

    mapping (address => Renter) public renters;

    function addRenter(address payable walletAddress, string memory firstName, string memory lastName, bool canRent, bool active, uint balance, uint due, uint
     start, uint end) public {
        renters[walletAddress] = Renter(walletAddress, firstName, lastName, canRent, active, balance, due, start, end);
    }

    //check out car
    function checkOut(address walletAddress) public{
        require(renters[walletAddress].due == 0, "You have a pending balance.");
        require(renters[walletAddress].canRent == true, "You cannot rent at this time.");
        renters[walletAddress].active = true;
        renters[walletAddress].start = block.timestamp;
        renters[walletAddress].canRent = false;
    }

    //check in a car
    function checkIn(address walletAddress) public{
        require(renters[walletAddress].active == true, "Please checkout a car first.");
        renters[walletAddress].active = false;
        renters[walletAddress].end = block.timestamp;
        //set the amount due
        setDue(walletAddress);
    }

    //get total duration of car use
    function renterTimespan(uint start, uint end) internal pure returns (uint) {
        return end - start; 
    }

    function getTotalDuration(address walletAddress) public view returns(uint) {
        require(renters[walletAddress].active == false, "car is currently checked out.");
        //uint timespan = renterTimespan(renters[walletAddress].start, renters[walletAddress].end);
        //uint timespanInMinutes = timespan / 60;
        //return timespanInMinutes;
        return 6;
    }

    //get contract balance
    function balanceOf() view public returns(uint){
        return address(this).balance;
    }

    //get renter's balance
    function balanceOfRenter(address walletAddress) public view returns(uint){
        return renters[walletAddress].balance;
    }

    //set due amount
    function setDue(address walletAddress) internal{
        uint timespanMinutes = getTotalDuration(walletAddress);
        uint fiveMinuteIncrements = timespanMinutes / 5;
        renters[walletAddress].due = fiveMinuteIncrements * 5000000000000000;
    }

    function canRentBike(address walletAddress) public view returns (bool){
        return renters[walletAddress].canRent;
    } 


    //Deposit
    function deposit(address walletAddress) payable public{
        renters[walletAddress].balance += msg.value;
    }

    // Make payment
    function makePayment(address walletAddress) payable public{
        require(renters[walletAddress].due > 0, "You do not have anything due at this time.");
        require(renters[walletAddress].balance > msg.value, "Insufficient funds, Please make a deposit.");
        renters[walletAddress].balance -= msg.value;
        renters[walletAddress].canRent = true;
        renters[walletAddress].due = 0;
        renters[walletAddress].start = 0;
        renters[walletAddress].end = 0;
        
        
    }

}