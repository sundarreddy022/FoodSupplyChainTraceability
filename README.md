# FoodSupplyChainTraceability
Implementation Steps:
1. Initialize the Remix IDE and Compile the Smart Contracts ‘DataStorage.sol’ & ‘SupplyChainUser.sol’.
2. Setup the Ganache local Server and add a new workspace at which your own Personal Blockchain is created. The workspace is initialized with a ‘Genesis Block’.
3. Deploy the ‘DataStorage.sol’ smart contract using Web3 Provider environment and enter the endpoint(port number) provided by Ganache.
4. The Contract is created at a memory address and a Block is added after the ‘Genesis Block’ in your personal Blockchain.
5. Deploy the ‘SupplyChainUser.sol’  by passing the address of the ‘DataStorage.sol’ from the memory. This allows all entities to participate and add Blocks at the same    address.

This is only the implementation of back-end functioning of the solution. The user interface and Dapp is yet to be developed. The System is designed keeping in mind various user interfaces and abstractions at different user levels. The functioning of the solution can be verified by following the implementation steps above which uses only three smart contracts. The other smart contracts are designed to enable the user level interactions among various participants in the Blockchain.
