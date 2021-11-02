pragma solidity ^0.8.7;
import './ABDKMath64x64.sol';

contract Assigment{
    struct User{
        int128 governanceToken;
         int128 lPToken;
         uint id;
         bool allowed;
         int128 UserBoost;
         int128 baseOfLogarithm;
    }
    mapping(address => User) allUsers;
    mapping(uint => address) usersAddresses;
    uint nextID;
    address admin;
    int128 currentBaseOfLogarithm;
    int128 public aggregateBoost;
    
    constructor(){
        admin = msg.sender;
        currentBaseOfLogarithm = 10;
        aggregateBoost = 0;
        
    }
    
    function addUsers(int128 amountLPToken, int128 amountGovernanceToken) public notAdmin()  {
       require(amountGovernanceToken<=10000, 'governanceToken is too large');
       require(amountLPToken<=10000, 'amountLPToken is too large');
        allUsers[msg.sender].governanceToken =  amountGovernanceToken;
        allUsers[msg.sender].lPToken =  amountLPToken;
        allUsers[msg.sender].id = nextID;
        usersAddresses[nextID] = msg.sender;
        nextID++;
        allUsers[msg.sender].allowed = true;
        allUsers[msg.sender].baseOfLogarithm = currentBaseOfLogarithm;
        
        
    }
    
    function SetBalance(int128 amountLPToken, int128 amountGovernanceToken) public onlyUsers(){
        require(amountGovernanceToken<=10000, 'governanceToken is too large');
        require(amountLPToken<=10000, 'amountLPToken is too large');
        allUsers[msg.sender].governanceToken =  amountGovernanceToken;
        allUsers[msg.sender].lPToken =  amountLPToken;
    }
    
    
    
    function CalculateBoost(address from) public {
        
        
        require(allUsers[from].allowed == true, 'user does not exist');
        int128 SolidityDemominator = 18446744073709400000;
        int128 denominator;
        int128 meter;
    
       meter = ABDKMath64x64.log_2((100*allUsers[from].governanceToken + allUsers[from].lPToken)) - ABDKMath64x64.log_2(100 * allUsers[from].governanceToken);
       denominator = ABDKMath64x64.log_2(allUsers[from].baseOfLogarithm);
       allUsers[from].UserBoost = SolidityDemominator + (ABDKMath64x64.div(meter, denominator));
       
    }
    
    function allCalculationBoost() public {
         for(uint i=0; i< nextID; i++){
            CalculateBoost(usersAddresses[i]);
         }
        
    }
    
    function SetLogarithmBase(int128 value) public onlyAdmin() {
        require(1 <= value && value <= 100, 'logarythm base must have in rage 1 do 100');
        currentBaseOfLogarithm = value;
    }
    
    function RebalanceAggregateBoost() public {
        for(uint i=0; i< nextID; i++){
            aggregateBoost = aggregateBoost + allUsers[usersAddresses[i]].lPToken * allUsers[usersAddresses[i]].UserBoost;
        }
    }
    function checkBoost() view public returns(int128) {
        return allUsers[msg.sender].UserBoost;
    }
    
    modifier onlyUsers() {
        require(allUsers[msg.sender].allowed == true, 'only users allowed');
       _;
    }
       modifier onlyAdmin() {
        require(msg.sender== admin, 'only admin allowed');
       _;
    }
         modifier notAdmin() {
        require(msg.sender != admin, 'admin cant');
       _;
    }
    
}