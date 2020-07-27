pragma solidity >=0.4.23 <0.7.0;

contract DataStorageOwnable{

address public owner;

constructor() public{
owner=msg.sender;
}

modifier onlyOwner{
require(owner==msg.sender);
_;
}

event OwnershipRenounced(address indexed prevOwner);
event OwnershipTransferred(address newOwner, address prevOwner);


function transferOwnership(address newOwner) public{
require(newOwner!=address(0));
emit OwnershipTransferred(newOwner,owner);
owner=newOwner;
}

function renounceOwnership() public{
emit OwnershipRenounced(owner);
owner=address(0);
}

}