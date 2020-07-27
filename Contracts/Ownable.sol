pragma solidity >=0.4.23 <0.7.0;

contract ownable{
address public owner;

event OwnershipRenounced(address indexed PreviousOwner);
event OwnershipTransferred(address indexed PreviousOwner, address indexed newOwner);


constructor() public{
owner=msg.sender;
}

modifier onlyOwner(){
require(msg.sender==owner);
_;
}


function transferOwnership(address newOwner) public onlyOwner {

require(newOwner != address(0));
emit OwnershipTransferred(owner, newOwner);
owner=newOwner;
}

function renounceOwnership() public onlyOwner{
emit OwnershipRenounced(owner);
owner=address(0);
}
}

