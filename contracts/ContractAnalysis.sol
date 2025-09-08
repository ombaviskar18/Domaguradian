// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "./DToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract ContractAnalysis is Ownable, ReentrancyGuard {
    DToken public immutable dToken;
    
    // Payment required for each analysis (0.0001 ETH)
    uint256 public constant ANALYSIS_COST = 0.0001 ether;
    
    // Events
    event ContractAnalysisRequested(address indexed user, string contractAddress, uint256 payment);
    event ContractAnalysisCompleted(address indexed user, string contractAddress, uint256 riskScore, string analysis);
    event PaymentReceived(address indexed user, uint256 amount);
    
    // Errors
    error InsufficientPayment();
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
    
    modifier requirePayment() {
        if (!dToken.hasFeaturePayment(msg.sender)) revert InsufficientPayment();
        _;
    }

    constructor(address payable _dToken) Ownable(msg.sender) {
        dToken = DToken(_dToken);
    }
    
    /**
     * @dev Request contract analysis - requires 0.0001 ETH payment
     * @param contractAddress The contract address to analyze
     */
    function requestContractAnalysis(string memory contractAddress) external requirePayment nonReentrant {
        if (bytes(contractAddress).length == 0) revert InvalidContractAddress();
        
        // Use DToken payment
        dToken.useFeature(msg.sender);
        
        // Create analysis request
        AnalysisRequest memory newRequest = AnalysisRequest({
            user: msg.sender,
            contractAddress: contractAddress,
            payment: ANALYSIS_COST,
            completed: false,
            riskScore: 0,
            analysis: "",
            timestamp: block.timestamp
        });
        
        userRequests[msg.sender].push(newRequest);
        
        emit ContractAnalysisRequested(msg.sender, contractAddress, ANALYSIS_COST);
        emit PaymentReceived(msg.sender, ANALYSIS_COST);
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
     * @dev Get user's ETH payment balance
     */
    function getUserPaymentBalance(address user) external view returns (uint256) {
        return dToken.getUserPaymentBalance(user);
    }
    
    /**
     * @dev Get the DToken address
     */
    function getDTokenAddress() external view returns (address) {
        return address(dToken);
    }
    
    /**
     * @dev Get feature cost
     */
    function getFeatureCost() external pure returns (uint256) {
        return ANALYSIS_COST;
    }
}