pragma solidity ^0.4.23;
import "./DataStorageOwnable.sol";

contract DataStorage is DataStorageOwnable{

    event StartCultivation(address indexed user, address indexed batchNo);
    event InputResourcesProvided(address indexed user, address indexed batchNo);
    event DoneInspection(address indexed user, address indexed batchNo);
    event DoneProcessing(address indexed user, address indexed batchNo);
    event DistributionBegin(address indexed user, address indexed batchNo);
    event ProductAtRetailer(address indexed user, address indexed batchNo);


address public lastAccess;
address public batchNo;


event AuthorizedCaller(address caller);
event DeAuthorizeCaller(address caller);


mapping(address=>uint8) authorizedCaller;


constructor () public{
authorizedCaller[msg.sender]=1;
emit AuthorizedCaller(msg.sender);
}


modifier onlyAuthCaller(){

lastAccess=msg.sender;
require(authorizedCaller[msg.sender]==1);
//require(keccak256(abi.encodePacked(getUserRole(msg.sender)))==keccak256(abi.encodePacked(role)));
//require(keccak256(getNextStage(batchNo))==keccak256(role));

_;
}


struct user{
string name;
string contactNo;
bool isActive;
string profileHash;
/*This lets users upload pictures from a shared database such as IPFS*/
}

mapping(address=> user) userDetails;
mapping(address=>string) userRole;



function authorizeCaller(address caller) public onlyOwner returns(bool){

authorizedCaller[caller]=1;
emit AuthorizedCaller(caller);
return true;

}


function deAuthorizeCaller(address caller) public onlyOwner returns(bool){

authorizedCaller[caller]=0;

emit DeAuthorizeCaller(caller);

return true;
}

/* User Roles
		PROVIDER,
		FARMER,
		FARMINSPECTOR
		PROCESSOR,
		DISTRIBUTOR,
		RETAILER,
	    CONSUMER,
*/

struct basicDetails{
       string providerName;
	   string farmerName;
	   string farmAddress;
	   string processorName;
	   string distributorName;
	   }
	   
struct provider{
       string providerName;
       string providerAddress;
       string providerGst;
       string productGUID;
	   uint quantity;
	   uint purchaseDateTime;
	   }
	   
struct farmer{
		string farmerName;
		string farmAddress;
		string cropVariety;
		uint quantity;
	    string CropGrowthImageUpdate;
	/*It can be used to update the growth of a crop using IPFS
	from time to time */
		}
		
struct farmInspector{
		string cropSample;
		uint humidity;
		uint moisture;
		bool qualityStandardsMet;
		uint dateOfInspection;
	    string reportHash; 
	/*we can upload the quality report of a sample into IPFS and
    restore it wheneve needed */
		}
		
struct processor{
		string processorName;
		string processorGst;
		string processorAddress;
		string cropVariety;
		uint quantity;
		uint packageDateTime;
		}
		
struct distributor{
		string distributorName;
		string distributorGst;
		string destinationAddress;
		string productName;
		uint reqQuantity;
		uint purchaseDateTime;
        }

struct retailer{
		string retailerName;
		string retailerGst;
		string retailerAddress;
		string productName;
		uint reqQuantity;
		uint arrivalDateTime;
		}
		
    mapping (address => basicDetails) batchBasicDetails;
    mapping (address => provider) batchProvider;
    mapping (address => farmer) batchFarmer;
    mapping (address => farmInspector) batchFarmInspector;
    mapping (address => processor) batchProcessor;
    mapping (address => distributor) batchDistributor;
    mapping (address => retailer) batchRetailer;
    mapping (address => string) nextAction;


 //struct pointers
 user userDetail;
 basicDetails basicDetailsData;
 provider providerData;
 farmer farmerData;
 farmInspector farmInspectorData;
 processor processorData;
 distributor distributorData;
 retailer retailerData;
 
 //create a user 
 
        function setUser(address _userAddress,
                     string _name, 
                     string _contactNo, 
                     string _role, 
                     bool _isActive,
                     string _profileHash
                    ) public onlyAuthCaller returns(bool){
        
        /*store data into struct*/
        userDetail.name = _name;
        userDetail.contactNo = _contactNo;
        userDetail.isActive = _isActive;
        userDetail.profileHash=_profileHash;
        
        /*store data into mapping*/
        userDetails[_userAddress] = userDetail;
        userRole[_userAddress] = _role;
        
        return true;
    }  


// get user details

		function getUser(address _userAddress) public onlyAuthCaller view returns(string name, 
                                                                    string contactNo, 
                                                                    string role,
                                                                    bool isActive,
                                                                    string _profileHash
                                                                ){

        
        user memory tmpData = userDetails[_userAddress];
        
        return (tmpData.name, tmpData.contactNo, userRole[_userAddress], tmpData.isActive, tmpData.profileHash);
    }


// a function to get role of a userRole

        function getUserRole(address _userAddress) public onlyAuthCaller view returns(string)
    {
        return userRole[_userAddress];
    }


// function to get next stage for the batch

        function getNextStage(address _batchNo) public onlyAuthCaller view returns(string)
    {
        return nextAction[_batchNo];
    }


// function to set basic batch detials

        function setBasicBatchDetails(string _providerName,
                             string _farmerName,
                             string _farmAddress,
                             string _processorName,
                             string _distributorName
                             ) public onlyAuthCaller returns(address) {
        
        uint tmpData = uint(keccak256(msg.sender, now));
        batchNo = address(tmpData);
        
        basicDetailsData.providerName = _providerName;
        basicDetailsData.farmerName = _farmerName;
        basicDetailsData.farmAddress = _farmAddress;
        basicDetailsData.processorName = _processorName;
        basicDetailsData.distributorName = _distributorName;
        
        batchBasicDetails[batchNo] = basicDetailsData;
        
        emit StartCultivation(msg.sender,batchNo);
        
        nextAction[batchNo] = 'provider';   
        
        
        return batchNo;
    }
    
    
// function to get basic batch details 

        function getBasicBatchDetails(address _batchNo) public onlyAuthCaller view returns(string _providerName,
                             string _farmerName,
                             string _farmAddress,
                             string _processorName,
                             string _distributorName) {
        
        basicDetails memory tmpData = batchBasicDetails[_batchNo];
        
        return (tmpData.providerName,tmpData.farmerName,tmpData.farmAddress,tmpData.processorName,tmpData.distributorName);
    }
    
    
    
        function updateProviderData(address _batchNo,
                                 string _providerName,
                                 string _providerAddress,
                                 string _providerGst,
                                string _productGUID,
	                            uint _quantity
                                 ) public onlyAuthCaller returns(bool){
                                     
               if(keccak256(abi.encodePacked(getUserRole(msg.sender)))!=keccak256('provider'))  revert();
               if(keccak256(abi.encodePacked(getNextStage((_batchNo))))!=keccak256('provider')) revert();
                            providerData.providerName=_providerName;
                            providerData.providerGst=_providerGst;
                            providerData.providerAddress=_providerAddress;
                            providerData.productGUID=_productGUID;
                            providerData.quantity=_quantity;
                            providerData.purchaseDateTime=now;
                            
                emit InputResourcesProvided(msg.sender,_batchNo);            
                              
                batchProvider[_batchNo]=providerData;
                
                nextAction[_batchNo]='farmer';
                
                return true;
                                     
                                 }
    
    
    
        function getProviderData(address _batchNo) public onlyAuthCaller view returns(string _providerName,
                                                                                     string _providerAddress,
                                                                                    string _providerGst,
                                                                                    string _productGUID,
	                                                                                 uint _quantity,
	                                                                                 uint _purchaseDateTime) {
	                                                                                     
	                       provider memory tmpData=batchProvider[_batchNo];
	                   
	   return(tmpData.providerName,tmpData.providerAddress,tmpData.providerGst,tmpData.productGUID,tmpData.quantity,
	          tmpData.purchaseDateTime);
	                                                                                     
	                                                                                 }
    
    
    
    

        function updateFarmerData( address _batchNo,
                                 string _farmerName,
                                 string _farmAddress,
                                 string _cropVariety,
		                         uint _quantity,
		                         string _CropGrowthImageUpdate
                                 ) public onlyAuthCaller returns(bool){
                if(keccak256(abi.encodePacked(getUserRole(msg.sender)))!=keccak256('farmer'))  revert();
               if(keccak256(abi.encodePacked(getNextStage((_batchNo))))!=keccak256('farmer')) revert();          
                                     
                farmerData.farmerName=_farmerName;
                farmerData.farmAddress=_farmAddress;
                farmerData.cropVariety=_cropVariety;
                farmerData.quantity=_quantity;
                farmerData.CropGrowthImageUpdate=_CropGrowthImageUpdate;
                batchFarmer[_batchNo]=farmerData;
                
                nextAction[_batchNo] = 'farmInspector';
                               
                  return true; 
                        }
                        
        function getFarmerData(address _batchNo) public onlyAuthCaller view returns(string farmerName,
		                                                                            string farmAddress,
		                                                                            string cropVariety,
		                                                                            uint quantity,
		                                                                            string CropGrowthImageUpdate
            ) {
            
            farmer memory tmpData=batchFarmer[_batchNo];
            return (tmpData.farmerName,tmpData.farmAddress,tmpData.cropVariety,tmpData.quantity,tmpData.CropGrowthImageUpdate);
            
            }
    
    
    
        function updateFarmInspectorData(address _batchNo,
                                   string _cropSample,
                                   uint _humidity,
                                   uint _moisture,
                                   bool _qualityStandardsMet,
                                   string _reportHash
                                   ) public onlyAuthCaller returns(bool){
                                       
               if(keccak256(abi.encodePacked(getUserRole(msg.sender)))!=keccak256('farmInspector'))  revert();
               if(keccak256(abi.encodePacked(getNextStage((_batchNo))))!=keccak256('farmInspector')) revert();          
                                       
                farmInspectorData.cropSample=_cropSample;
                farmInspectorData.humidity=_humidity;
                farmInspectorData.moisture=_moisture;
                farmInspectorData.qualityStandardsMet=_qualityStandardsMet;
                farmInspectorData.reportHash=_reportHash;
                farmInspectorData.dateOfInspection=now;
                
                batchFarmInspector[_batchNo]=farmInspectorData;
                
                nextAction[_batchNo]='processor';
                
                emit DoneInspection(msg.sender,_batchNo);  
                
                return true;
                                       
                                       
                         }


        function getFarmInspectorData(address _batchNo) public onlyAuthCaller view returns(string cropSample,
		                                                                                uint humidity,
		                                                                                uint moisture,
		                                                                                bool qualityStandardsMet,
		                                                                                string reportHash,
		                                                                                uint dateOfInspection){
		                                                                                    
		      farmInspector memory tmpData=batchFarmInspector[_batchNo];
		      return (tmpData.cropSample,tmpData.humidity,tmpData.moisture,tmpData.qualityStandardsMet,
		              tmpData.reportHash,tmpData.dateOfInspection);
                        }
                        
                        
                        
        function updateProcessorData(address _batchNo,
                                  string _processorName,
                                  string _processorGst,
		                          string _processorAddress,
		                          string _cropVariety,
		                          uint _quantity) public onlyAuthCaller returns(bool){
		                              
		      if(keccak256(abi.encodePacked(getUserRole(msg.sender)))!=keccak256('processor'))  revert();
               if(keccak256(abi.encodePacked(getNextStage((_batchNo))))!=keccak256('processor')) revert();
		                              
		                              
		      processorData.processorName=_processorName;
		      processorData.processorGst=_processorGst;
		      processorData.processorAddress=_processorAddress;
		      processorData.cropVariety=_cropVariety;
		      processorData.quantity=_quantity;
		      processorData.packageDateTime=now;
		      
		      batchProcessor[_batchNo]=processorData;
		      
		      nextAction[_batchNo]='distributor';
		      
		      emit DoneProcessing(msg.sender,_batchNo); 
		      return true;
		      
		                          }
		                          
		  
		 function getProcessorData(address _batchNo) public onlyAuthCaller view returns(string _processorName,
		                                                                                string _processorGst,
		                                                                                string _processorAddress,
		                                                                                string _cropVariety,
		                                                                                uint _quantity,
		                                                                                uint _packageDatetime) {
		                                                                                    
		                  processor memory tmpData=batchProcessor[_batchNo];
              return(tmpData.processorName,tmpData.processorGst,tmpData.processorAddress,tmpData.cropVariety,tmpData.quantity,
                     tmpData.packageDateTime);
		                  
		                          }            
		                  
		                  
		  function updateDistributorData(address _batchNo,
		                              string _distributorName,
		                              string _distributorGst,
		                              string _destinationAddress,
		                              string _productName,
		                              uint _reqQuantity) public onlyAuthCaller returns(bool){
		                                  
		       if(keccak256(abi.encodePacked(getUserRole(msg.sender)))!=keccak256('distributor'))  revert();
               if(keccak256(abi.encodePacked(getNextStage((_batchNo))))!=keccak256('distributor')) revert();                
		                                  
		                                  
		              distributorData.distributorName=_distributorName;
		              distributorData.distributorGst=_distributorGst;
		              distributorData.destinationAddress=_destinationAddress;
		              distributorData.productName=_productName;
		              distributorData.reqQuantity=_reqQuantity;
		             
		              distributorData.purchaseDateTime=now;
		           batchDistributor[_batchNo]=distributorData;  
		           
		           nextAction[_batchNo]='retailer';
		           
		           emit DistributionBegin(msg.sender,_batchNo);
		           return(true);
		                           }         
		                  
		                  
	/*	  function getDistributorData(address _batchNo) public onlyAuthCaller view returns(string _distributorName,
		                                                                           string _distributorGst,
		                                                                           string _destinationAddress,
		                                                                           string _productName,
		                                                                           uint _reqQuantity,
		                                                                           uint _purchaseDateTime
		                                                                           ){
		                                                                               
		               distributor memory tmpData= batchDistributor[_batchNo];
		               
		  return(tmpData.distributorName,tmpData.distributorGst,tmpData.destinationAddress,tmpData.productName,tmpData.reqQuantity,
		         tmpData.purchaseDateTime);
		                                                                               
		                                                                           }                                                     
		                                                                               
		                                                                               
	   function updateRetailerData(address _batchNo,
		                            string _retailerName,
		                            string _retailerGst,
		                            string _retailerAddress,
		                            string _productName,
	 	                            uint _reqQuantity) public onlyAuthCaller returns(bool){
	 	                                
		       if(keccak256(abi.encodePacked(getUserRole(msg.sender)))!=keccak256('retailer'))  revert();
               if(keccak256(abi.encodePacked(getNextStage((_batchNo))))!=keccak256('retailer')) revert();     
		                            
		                                
		       retailerData.retailerName=_retailerName;
		       retailerData.retailerGst=_retailerGst;
		       retailerData.retailerAddress=_retailerAddress;
		       retailerData.productName=_productName;
		       retailerData.reqQuantity=_reqQuantity;
		       retailerData.arrivalDateTime=now;
		       
		       batchRetailer[_batchNo]=retailerData;
		       
		       nextAction[_batchNo]='done';
		       
		        emit ProductAtRetailer(msg.sender,_batchNo);
		       return true;
		                                
		                            }                                                                           
		                                                                                        
		      function getRetailerData(address _batchNo) public onlyAuthCaller view returns(string _retailerName,
		                                                                                    string _retailerGst,
		                                                                                    string _retailerAddress,
		                                                                                    string _productName,
	 	                                                                                    uint _reqQuantity,
		                                                                                    uint _arrivalDateTime
		                                                                                    )   {
		                        retailer memory tmpData=batchRetailer[_batchNo];
		    return(tmpData.retailerName,tmpData.retailerGst,tmpData.retailerAddress,tmpData.productName,
		           tmpData.reqQuantity,tmpData.arrivalDateTime);                    
		                                                                                       
		                                                                                    }        
		                  


}