// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PlayPitch{
    string public name;
    string public description;
    uint256 public goal;
    uint256 public deadline;
    address public owner;
    bool public pause;

    enum GameFundState {Active, Successful, Failed} //gamefund should be of these three states only
    GameFundState public state;

    struct Tier{
        string name;
        uint256 amount;
        uint256 backers;

    }

    struct Backer{
        uint256 totalContribution;
        mapping (uint256 =>bool) fundedTiers;
    }

    Tier[] public tiers; //store tiers created by owner
    mapping (address => Backer) public backers;

    modifier onlyOwner(){ // adding modifier so that selective functions are accessed by owner
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier GameFundOpen(){ //modifier so that some functions are execuatble when gamefund is active
        require(state == GameFundState.Active, "GameFund is not Active.");
        _;
    }

    modifier notPaused(){
        require(!pause, "Contract is paused");
        _;
    }

    constructor(
        address _owner,
        string memory _name,
        string memory _description,
        uint256 _goal,
        uint256 _deadline
    ) {
            name = _name;
            description = _description;
            goal = _goal;
            deadline = block.timestamp + (_deadline * 1 days);
            owner = _owner;
            state  = GameFundState.Active;
    }

//a user can fund our gampaign
    function fund(uint256 _tierIndex) public payable GameFundOpen {
        require(_tierIndex < tiers.length, "Invalid tier.");
        require(msg.value == tiers[_tierIndex].amount,"Incorrect amount");

        tiers[_tierIndex].backers++;
        backers[msg.sender].totalContribution += msg.value;
        backers[msg.sender].fundedTiers[_tierIndex] = true;
        checkAndUpdateGameFundState();
    }

    function withDraw() public onlyOwner {
        checkAndUpdateGameFundState();
        require(state == GameFundState.Successful, "GameFund not successful.");

        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");

        payable(owner).transfer(balance);
    }

//get contract balance(how much is already funded for the Gamepaign) which is a READ function 
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    function addTier(
        string memory _name,
        uint256 _amount
    ) public onlyOwner {
        require(_amount > 0, "Amount must be greater than 0.");
        tiers.push(Tier(_name, _amount, 0));
    }

    function removeTier(uint256 _index) public  onlyOwner{
        require(_index < tiers.length, "Tier does not exist");
        tiers[_index] = tiers[tiers.length - 1];
        tiers.pop();

    }

//function to update state of gamefund

    function checkAndUpdateGameFundState() internal {
        if(state == GameFundState.Active){
            if(block.timestamp >= deadline){
                state = address(this).balance >= goal? GameFundState.Successful : GameFundState.Failed;
            }
            else {
                state = address(this).balance >= goal? GameFundState.Successful : GameFundState.Active;
            }
        }
    }

    function refund() public { // to refund to user if gamefund fails
        checkAndUpdateGameFundState();
        require(state == GameFundState.Failed, "Refund not available.");
        uint256 amount = backers[msg.sender].totalContribution;
        require(amount > 0, "No contribution to refund");

        backers[msg.sender].totalContribution = 0;
        payable (msg.sender).transfer(amount);
    }

    function hasFundedTier(address _backer, uint256 _tierIndex) public view returns(bool) { //check if user has funded tier or not
        return backers[_backer].fundedTiers[_tierIndex];
    }

    function getTiers() public view returns (Tier[] memory){
        return tiers;
    }

    function togglePause() public onlyOwner {
        pause = !pause;
    }

    function getGameFundStatus () public view returns(GameFundState){
        if (state == GameFundState.Active && block.timestamp > deadline) {
            return address(this).balance >= goal ? GameFundState.Successful : GameFundState.Failed;

        }
        return state;
    }

    function extendDeadLine(uint256 _daystoadd) public onlyOwner GameFundOpen{
        deadline += _daystoadd * 1 days;
    }
}

