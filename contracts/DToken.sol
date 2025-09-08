// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title DToken
 * @dev ETH-based payment system for Doma Network - DomaGuardian platform
 * @notice This contract handles ETH payments for using DomaGuardian features (0.0001 ETH per feature)
 */
contract DToken is Ownable, ReentrancyGuard {
    using Address for address payable;
    
    // Payment details
    uint256 public constant FEATURE_COST = 0.0001 ether; // 0.0001 ETH per feature
    
    // Feature contracts that can collect payments
    mapping(address => bool) public authorizedContracts;
    
    // User payment tracking
    mapping(address => uint256) public userPayments;
    mapping(address => uint256) public userFeatureUsage;
    
    // Events
    event ContractAuthorized(address indexed contractAddress, bool authorized);
    event FeatureUsed(address indexed user, address indexed contractAddress, uint256 cost);
    event PaymentReceived(address indexed user, uint256 amount);
    event PaymentWithdrawn(address indexed owner, uint256 amount);
    
    // Errors
    error UnauthorizedContract();
    error InsufficientPayment();
    error InvalidAmount();
    error TransferFailed();
    error ContractNotAuthorized();
    
    modifier onlyAuthorized() {
        if (!authorizedContracts[msg.sender]) revert UnauthorizedContract();
        _;
    }
    
    constructor() Ownable(msg.sender) {}
    
    /**
     * @dev Authorize a contract to collect ETH payments for features
     * @param contractAddress The address of the contract to authorize
     * @param authorized Whether to authorize or deauthorize
     */
    function authorizeContract(address contractAddress, bool authorized) external onlyOwner {
        authorizedContracts[contractAddress] = authorized;
        emit ContractAuthorized(contractAddress, authorized);
    }
    
    /**
     * @dev Pay ETH for a feature (called by users)
     */
    function payForFeature() external payable nonReentrant {
        if (msg.value != FEATURE_COST) revert InsufficientPayment();
        
        userPayments[msg.sender] += msg.value;
        emit PaymentReceived(msg.sender, msg.value);
    }
    
    /**
     * @dev Use a feature (called by authorized contracts)
     * @param user The user using the feature
     */
    function useFeature(address user) external onlyAuthorized nonReentrant {
        if (userPayments[user] < FEATURE_COST) revert InsufficientPayment();
        
        userPayments[user] -= FEATURE_COST;
        userFeatureUsage[user] += 1;
        
        emit FeatureUsed(user, msg.sender, FEATURE_COST);
    }
    
    /**
     * @dev Check if user has paid for a feature
     * @param user The user to check
     * @return hasPaid Whether user has paid for a feature
     */
    function hasFeaturePayment(address user) external view returns (bool hasPaid) {
        return userPayments[user] >= FEATURE_COST;
    }
    
    /**
     * @dev Get the cost of using a feature
     * @return cost The cost in ETH
     */
    function getFeatureCost() external pure returns (uint256 cost) {
        return FEATURE_COST;
    }
    
    /**
     * @dev Get user's current payment balance
     * @param user The user to check
     * @return balance The user's payment balance
     */
    function getUserPaymentBalance(address user) external view returns (uint256 balance) {
        return userPayments[user];
    }
    
    /**
     * @dev Get user's total feature usage count
     * @param user The user to check
     * @return usage The total number of features used
     */
    function getUserFeatureUsage(address user) external view returns (uint256 usage) {
        return userFeatureUsage[user];
    }
    
    /**
     * @dev Withdraw accumulated ETH (owner only)
     * @param amount The amount to withdraw (0 means withdraw all)
     */
    function withdrawETH(uint256 amount) external onlyOwner nonReentrant {
        uint256 contractBalance = address(this).balance;
        
        if (amount == 0) {
            amount = contractBalance;
        }
        
        if (amount > contractBalance) revert InvalidAmount();
        if (amount == 0) revert InvalidAmount();
        
        payable(owner()).sendValue(amount);
        emit PaymentWithdrawn(owner(), amount);
    }
    
    /**
     * @dev Get contract balance
     * @return balance The contract's ETH balance
     */
    function getContractBalance() external view returns (uint256 balance) {
        return address(this).balance;
    }
    
    /**
     * @dev Emergency function to receive ETH
     */
    receive() external payable {
        userPayments[msg.sender] += msg.value;
        emit PaymentReceived(msg.sender, msg.value);
    }
    
    /**
     * @dev Fallback function
     */
    fallback() external payable {
        userPayments[msg.sender] += msg.value;
        emit PaymentReceived(msg.sender, msg.value);
    }
}
