pragma solidity >=0.4.23 <0.7.0;
import "./DataStorage.sol";
import "./Ownable.sol";

contract FoodSupplyChain is Ownable
{
    event StartCultivation(address indexed user, address indexed batchNo);
    event InputResourcesProvided(address indexed user, address indexed batchNo);
    event DoneInspection(address indexed user, address indexed batchNo);
    event DoneProcessing(address indexed user, address indexed batchNo);
    event DistributionBegin(address indexed user, address indexed batchNo);
    event ProductAtRetailer(address indexed user, address indexed batchNo);


    /*Modifier*/
    modifier isValidPerformer(address batchNo, string role) {

        require(keccak256(supplyChainStorage.getUserRole(msg.sender)) == keccak256(role));
        require(keccak256(supplyChainStorage.getNextStage(batchNo)) == keccak256(role));
        _;
    }

    /* Storage Variables */
    DataStorage supplyChainStorage;

    constructor(address _supplyChainAddress) public {
        supplyChainStorage = DataStorage(_supplyChainAddress);
    }

    /* Get Next Action  */

    function getNextAction(address _batchNo) public view returns(string action)
    {
       (action) = supplyChainStorage.getNextStage(_batchNo);
       return (action);
    }


    /* get Basic Details */

    function getBasicBatchDetails(address _batchNo) public view returns (string _providerName,
                                                                    string _farmerName,
                                                                    string _farmAddress,
                                                                    string _processorName,
                                                                    string _distributorName) {
        /* Call Storage Contract */
      (_providerName,_farmerName,_farmAddress,_processorName,_distributorName) = supplyChainStorage.getBasicBatchDetails(_batchNo);
        return (_providerName,_farmerName,_farmAddress,_processorName,_distributorName);
    }

    /* add basic Batch details */

    function addBasicBatchDetails(string _providerName,
                                  string _farmerName,
                                  string _farmAddress,
                                  string _processorName,
                                  string _distributorName
                            ) public returns(address) {

        address batchNo = supplyChainStorage.setBasicBatchDetails(_providerName,_farmerName,_farmAddress,_processorName,_distributorName);

        emit StartCultivation(msg.sender,batchNo);

        return (batchNo);
    }


/* Provider updates the Data*/
    function updateProviderData (address _batchNo,
                                string _providerName,
                                 string _providerAddress,
                                 string _providerGst,
                                string _productGUID,
	                            uint _quantity) public isValidPerformer(_batchNo,'provider') returns(bool){
	                                
	     bool status=supplyChainStorage.updateProviderData(_batchNo,_providerName,_providerAddress,
	                                                    _providerGst,_productGUID,_quantity)  ;
	           emit InputResourcesProvided(msg.sender,_batchNo);
	           return status; }
	           
	           
    /* get Provider Data */

    function getProviderData(address _batchNo) public view returns (string _providerName,
                                                                    string _providerAddress,
                                                                    string _providerGst,
                                                                    string _productGUID,
	                                                                uint _quantity,
	                                                                uint _purchaseDateTime) {
        /* Call Storage Contract */
        (_providerName,_providerAddress,_providerGst,_productGUID,_quantity,_purchaseDateTime) = supplyChainStorage.getProviderData(_batchNo);
        return (_providerName,_providerAddress,_providerGst,_productGUID,_quantity,_purchaseDateTime);
    }


    function updateFarmerData(address _batchNo,
                             string _farmerName,
		                     string _farmAddress,
	                         string _cropVariety,
	                         uint _quantity,
	                         string _CropGrowthImageUpdate)
                                public isValidPerformer(_batchNo,'farmer') returns(bool) {
                                    
        /* Call Storage Contract */
        bool status = supplyChainStorage.updateFarmerData(_batchNo,_farmerName,_farmAddress,_cropVariety,
                                                        _quantity,_CropGrowthImageUpdate);

        return (status);
    }


    

    function getFarmerData(address _batchNo) public view returns (string _farmerName,
		                                                           string _farmAddress,
	                                                              string _cropVariety,
	                                                           uint _quantity,
	                                                           string _CropGrowthImageUpdate) {
        /* Call Storage Contract */
      (_farmerName,_farmAddress,_cropVariety,_quantity,_CropGrowthImageUpdate) =  supplyChainStorage.getFarmerData(_batchNo);
        return (_farmerName,_farmAddress,_cropVariety,_quantity,_CropGrowthImageUpdate);
        
        
    }

    
    function updateFarmInspectorData(address _batchNo,
                                    string _cropSample,
		                            uint _humidity,
		                            uint _moisture,
		                            bool _qualityStandardsMet,
	                                string _reportHash
                                      ) public isValidPerformer(_batchNo,'farmInspector') returns(bool){
                                          
            bool status=supplyChainStorage.updateFarmInspectorData(_batchNo,_cropSample,_humidity,_moisture,
                                                                _qualityStandardsMet,_reportHash);
                   emit DoneInspection(msg.sender,_batchNo);                                             
                    return status;                                            
                                          
                                      }
    
    function getFarmInspectorData(address _batchNo) public view returns(string _cropSample,
		                                                                uint _humidity,
		                                                                uint _moisture,
		                                                                bool _qualityStandardsMet,
	                                                                    string _reportHash,
	                                                                    uint _dateOfInspection){
	                                                                        
	(_cropSample,_humidity,_moisture,_qualityStandardsMet,_reportHash,_dateOfInspection)=supplyChainStorage.getFarmInspectorData(_batchNo);
	
	return (_cropSample,_humidity,_moisture,_qualityStandardsMet,_reportHash,_dateOfInspection);
	                                                                        
	               }
	               
	               
	               
	  function updateProcessorData(address _batchNo,
	                              string _processorName,
		                          string _processorGst,
		                          string _processorAddress,
		                          string _cropVariety,
	                           	  uint _quantity) public isValidPerformer(_batchNo,'processor') returns(bool){
	                           	      
	       bool status=supplyChainStorage.updateProcessorData(_batchNo,_processorName,_processorGst,
	                                                       _processorAddress,_cropVariety,_quantity);
	                                                       
	               emit DoneProcessing(msg.sender,_batchNo);                                        
	               return status;                                        
	                           	  }
    
      function getProcessorData(address _batchNo) public view returns(string _processorName,
		                                                              string _processorGst,
		                                                              string _processorAddress,
		                                                              string _cropVariety,
	                           	                                      uint _quantity,
	                           	                                      uint _packageDateTime){
	 (_processorName,_processorGst,_processorAddress,_cropVariety,_quantity,_packageDateTime)=supplyChainStorage.getProcessorData(_batchNo);
	 
	       return (_processorName,_processorGst,_processorAddress,_cropVariety,_quantity,_packageDateTime);                     	                                          
	                           	                                          
	                           	                                      }
	                           	                                      
	  function updateDistributorData(address _batchNo,
	                                string _distributorName,
		                            string _distributorGst,
		                            string _destinationAddress,
		                            string _productName,
		                            uint _reqQuantity) public isValidPerformer(_batchNo,'distributor') returns(bool){
		                                
		 bool status=supplyChainStorage.updateDistributorData(_batchNo,_distributorName,_distributorGst,
		                                                   _destinationAddress,_productName,_reqQuantity);
		                                                   
		          emit DistributionBegin(msg.sender,_batchNo);
		          return status;
		                            }
		                            
  function getDistributorData(address _batchNo) public view returns(string _distributorName,
		                                                       string _distributorGst,
		                                                       string _destinationAddress,
		                                                       string _productName,
		                                                       uint _reqQuantity,
		                                                       uint _purchaseDateTime){
	
	(_distributorName,_distributorGst,_destinationAddress,_productName,_reqQuantity,_purchaseDateTime)=supplyChainStorage.getDistributorData(_batchNo);	                                                           
		                                                           
		return (_distributorName,_distributorGst,_destinationAddress,_productName,_reqQuantity,_purchaseDateTime);                                                            
		                                                       }
		                                                       
	
/*	function updateRetailerData(address _batchNo,
		                        string _retailerName,
		                        string _retailerGst,
		                        string _retailerAddress,
		                        string _productName,
	 	                        uint _reqQuantity) public isValidPerformer(_batchNo,'retailer') returns(bool){
	 	                            
	 	bool status=supplyChainStorage.updateRetailerData(_batchNo,_retailerName,_retailerGst,
	 	                                              _retailerAddress,_productName,_reqQuantity);
	 	         emit ProductAtRetailer(msg.sender,_batchNo);
	 	         
	 	         return status;
	 	                            
	 	                        }	                                                       
    
     function getRetailerData(address _batchNo) public view returns(string _retailerName,
		                                                            string _retailerGst,
		                                                            string _retailerAddress,
		                                                            string _productName,
	 	                                                            uint _reqQuantity,
	 	                                                            uint _arrivalDateTime){
	 	                                                                
	 (_retailerName,_retailerGst, _retailerAddress,_productName,_reqQuantity,_arrivalDateTime)=supplyChainStorage.getRetailerData(_batchNo);
	 
	 return (_retailerName,_retailerGst, _retailerAddress,_productName,_reqQuantity,_arrivalDateTime);
	 	                                                            }
	 */	                                                          
 	                                                            
}
