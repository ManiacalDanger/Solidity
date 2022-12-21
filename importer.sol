//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7.0;
contract Charity{
    address payable public charityOwner;
    string public charityName;
    uint256 public requiredAmount;
    string public description;
    uint256 public minAmount;
    uint256 public amountCollected;
    string[] public tags;
    bool public isOpen;
    address [] public donors;
    uint256 public noOfDonors;
    //to check if the owner has donated before or not
    mapping (address=>bool) public hasDonated;
    constructor (
        address payable _charityOwner, 
        string memory _charityName, 
        uint256 _requiredAmount,
        string memory _fundDescription,
        uint256 _minAmount
    ){
        //charity variable of contract=charity variable received fron the user
        charityOwner=payable(_charityOwner);
        charityName=_charityName;
        requiredAmount=_requiredAmount;
        description=_fundDescription;
        minAmount=_minAmount;
        //its an array of string which currently has zero donors/ empty
        //telling that its currently empty...no need to initialize anything now
        tags=new string[] (0);
        isOpen=true;
        noOfDonors=0;
        //using the same idea as behind tag
        donors=new address[] (0);
        amountCollected=0;
    }
    //deploy the payment method and to set the limit say 
    //someone can donate min Rs 500
    function pay() external payable{
        //for storing the current value donated
        if(msg.value<minAmount){
            revert();//that is...it doesnt accept the amt donated which
            //is less than minAmount say user is trying to donate Rs300
            //return back the money..no transaction should occur
        }
        //to verify whether the amount is still being collected
        //i.e is whether the contract is still open or not
        if(isOpen!=true){
            revert();
        }
        //the person who has created the charity can also donate to it, 
        //however, this is not a feasible situation as normally a person 
        //will not be donating to themselves, so implement a fix in the pay 
        //function such that the charity creator cannot donate to themselves.
        if(charityOwner==msg.sender){
            revert();
        }
        amountCollected+=msg.value;
        donors.push(msg.sender);
        if(amountCollected>=requiredAmount){
            //close the contract
            isOpen=false;
            //transfer the amount to charity owner after form is closed
            charityOwner.transfer(address(this).balance);
        }
        //the address of the donors will get repeated in the donors array, 
        //hence implementing a fix for that.
        if(!hasDonated[msg.sender]){
            donors.push(msg.sender);
            noOfDonors++;
        }hasDonated[msg.sender]=true;
    }

    //To know how much amount is collected in %
    //required for front end
    function getCollectionPercentage() public view returns(uint256){
        return ((amountCollected*100/requiredAmount));
        //no float datatype...as we work with absolute values
        //different compilers may interpret the decimal valuea by either 
        //considering the actuall decimal or just round it off...
        //lot of mishandling of ethers
    }

    //to add tags when we use create charity and then return it
    function addTags(string[] memory _s)public{
        for(uint256 i=0;i<_s.length;i++){
            tags.push(_s[i]);//push i th element of tags 
        }
    }
    function getTags() public view returns(string[] memory){
        return tags;
    }
    
    //To show the number of donors
    function getNoOfDonors() public view returns(uint256){
        return noOfDonors;
    }
    //To show the domors address who donated  
    function getDonors() public view returns(address[] memory){
        return donors;
    }

    //function called withdraw which when called will transfer whatever 
    //balance is present inside the contract at the moment to the 
    //contract creator (owner) and will close the fund (contract).
    function withdraw() public payable{
        charityOwner.transfer(address(this).balance);
        isOpen=false;
    }
}