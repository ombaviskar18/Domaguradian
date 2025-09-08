// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "./DToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract SocialAnalysis is Ownable, ReentrancyGuard {
    DToken public immutable dToken;
    
    // Payment required for each analysis (0.0001 ETH)
    uint256 public constant ANALYSIS_COST = 0.0001 ether;
    
    // Events
    event SocialAnalysisRequested(address indexed user, string tokenAddress, uint256 payment);
    event SocialAnalysisCompleted(address indexed user, string tokenAddress, uint256 sentimentScore, string analysis);
    event PaymentReceived(address indexed user, uint256 amount);
    
    // Errors
    error InsufficientPayment();
    error InvalidTokenAddress();
    
    // Structs
    struct SocialRequest {
        address user;
        string tokenAddress;
        uint256 payment;
        bool completed;
        uint256 sentimentScore;
        string analysis;
        uint256 timestamp;
    }
    
    // State variables
    mapping(address => SocialRequest[]) public userRequests;
    
    modifier requirePayment() {
        if (!dToken.hasFeaturePayment(msg.sender)) revert InsufficientPayment();
        _;
    }

    constructor(address payable _dToken) Ownable(msg.sender) {
        dToken = DToken(_dToken);
    }
    
    /**
     * @dev Request social analysis - requires 0.0001 ETH payment
     * @param tokenAddress The token address to analyze social sentiment
     */
    function requestSocialAnalysis(string memory tokenAddress) external requirePayment nonReentrant {
        if (bytes(tokenAddress).length == 0) revert InvalidTokenAddress();
        
        // Use DToken payment
        dToken.useFeature(msg.sender);
        
        // Create analysis request
        SocialRequest memory newRequest = SocialRequest({
            user: msg.sender,
            tokenAddress: tokenAddress,
            payment: ANALYSIS_COST,
            completed: false,
            sentimentScore: 0,
            analysis: "",
            timestamp: block.timestamp
        });
        
        userRequests[msg.sender].push(newRequest);
        
        emit SocialAnalysisRequested(msg.sender, tokenAddress, ANALYSIS_COST);
        emit PaymentReceived(msg.sender, ANALYSIS_COST);
    }
    
    /**
     * @dev Complete social analysis (called by owner/backend)
     * @param user The user who requested the analysis
     * @param requestIndex Index of the request in user's requests array
     * @param sentimentScore The calculated sentiment score (0-100)
     * @param analysis The analysis report
     */
    function completeSocialAnalysis(
        address user,
        uint256 requestIndex,
        uint256 sentimentScore,
        string memory analysis
    ) external onlyOwner {
        require(requestIndex < userRequests[user].length, "Invalid request index");
        require(!userRequests[user][requestIndex].completed, "Analysis already completed");
        
        userRequests[user][requestIndex].completed = true;
        userRequests[user][requestIndex].sentimentScore = sentimentScore;
        userRequests[user][requestIndex].analysis = analysis;
        
        emit SocialAnalysisCompleted(
            user,
            userRequests[user][requestIndex].tokenAddress,
            sentimentScore,
            analysis
        );
    }
    
    /**
     * @dev Get user's social analysis requests
     * @param user The user address
     * @return Array of social analysis requests
     */
    function getUserRequests(address user) external view returns (SocialRequest[] memory) {
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