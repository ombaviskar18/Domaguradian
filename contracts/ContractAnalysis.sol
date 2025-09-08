// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "./SToken.sol";

contract ContractAnalysis {
    SToken public immutable S_TOKEN;
    
    // Payment required for each analysis (1 S token)
    uint256 public constant ANALYSIS_PAYMENT = 1 * 10**18; // 1 S token
    
    // Events
    event ContractAnalysisRequested(address indexed user, string contractAddress, uint256 payment);
    event ContractAnalysisCompleted(address indexed user, string contractAddress, uint256 riskScore, string analysis);
    event PaymentReceived(address indexed user, uint256 amount);
    error Unauthorized();
    error InsufficientSTokens();
    error InvalidContractAddress();
    
    // Structs
    struct AnalysisRequest {
        address user;
        string contractAddress;
        uint256 payment;
        bool completed;
        uint256 riskScore;
        string analysis;
        uint256 timestamp;
    }
    
    // State variables
    mapping(address => AnalysisRequest[]) public userRequests;
    address public owner;
    
    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }
    
    modifier requireSTokens() {
        if (!S_TOKEN.hasEnoughForFeature(msg.sender)) revert InsufficientSTokens();
        _;
    }

    constructor(address sTokenAddress) {
        S_TOKEN = SToken(sTokenAddress);
        owner = msg.sender;
    }

    /**
     * @dev Initialize the contract with S token authorization
     */
    function initialize() external onlyOwner {
        // This will be called after deployment to authorize this contract to use S tokens
        // The owner needs to call S_TOKEN.authorizeContract(address(this), true)
    }
    
    /**
     * @dev Request contract analysis - requires 1 S token for each analysis
     * @param contractAddress The contract address to analyze
     */
    function requestContractAnalysis(string memory contractAddress) external requireSTokens {
        if (bytes(contractAddress).length == 0) revert InvalidContractAddress();
        
        // Use 1 S token for the analysis
        S_TOKEN.useFeature(msg.sender, ANALYSIS_PAYMENT);
        
        // Create analysis request
        AnalysisRequest memory newRequest = AnalysisRequest({
            user: msg.sender,
            contractAddress: contractAddress,
            payment: ANALYSIS_PAYMENT,
            completed: false,
            riskScore: 0,
            analysis: "",
            timestamp: block.timestamp
        });
        
        userRequests[msg.sender].push(newRequest);
        
        emit ContractAnalysisRequested(msg.sender, contractAddress, ANALYSIS_PAYMENT);
        emit PaymentReceived(msg.sender, ANALYSIS_PAYMENT);
    }
    
    /**
     * @dev Complete contract analysis (called by owner/backend)
     * @param user The user who requested the analysis
     * @param requestIndex Index of the request in user's requests array
     * @param riskScore The calculated risk score (0-100)
     * @param analysis The analysis report
     */
    function completeAnalysis(
        address user,
        uint256 requestIndex,
        uint256 riskScore,
        string memory analysis
    ) external onlyOwner {
        require(requestIndex < userRequests[user].length, "Invalid request index");
        require(!userRequests[user][requestIndex].completed, "Analysis already completed");
        
        userRequests[user][requestIndex].completed = true;
        userRequests[user][requestIndex].riskScore = riskScore;
        userRequests[user][requestIndex].analysis = analysis;
        
        emit ContractAnalysisCompleted(
            user,
            userRequests[user][requestIndex].contractAddress,
            riskScore,
            analysis
        );
    }
    
    /**
     * @dev Get user's analysis requests
     * @param user The user address
     * @return Array of analysis requests
     */
    function getUserRequests(address user) external view returns (AnalysisRequest[] memory) {
        return userRequests[user];
    }
    

    
    /**
     * @dev Get S token balance of this contract
     */
    function getContractSTokenBalance() external view returns (uint256) {
        return S_TOKEN.balanceOf(address(this));
    }
    
    /**
     * @dev Get user's S token balance
     */
    function getUserSTokenBalance(address user) external view returns (uint256) {
        return S_TOKEN.balanceOf(user);
    }
    
    /**
     * @dev Transfer ownership
     * @param newOwner The new owner address
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid new owner");
        owner = newOwner;
    }
    
    /**
     * @dev Get the S token address
     */
    function getSTokenAddress() external view returns (address) {
        return address(S_TOKEN);
    }
}
