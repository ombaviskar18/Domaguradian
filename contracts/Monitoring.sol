// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "./DToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Monitoring is Ownable, ReentrancyGuard {
    DToken public immutable dToken;
    
    // Payment required for each monitoring setup (0.0001 ETH)
    uint256 public constant MONITORING_COST = 0.0001 ether;
    
    // Events
    event MonitoringRequested(address indexed user, string tokenAddress, uint256 payment);
    event MonitoringSetup(address indexed user, string tokenAddress, uint256 alertThreshold);
    event AlertTriggered(address indexed user, string tokenAddress, string alertType, uint256 value);
    event PaymentReceived(address indexed user, uint256 amount);
    
    // Errors
    error InsufficientPayment();
    error InvalidTokenAddress();
    error MonitoringNotActive();
    
    // Structs
    struct MonitoringRequest {
        address user;
        string tokenAddress;
        uint256 payment;
        bool active;
        uint256 alertThreshold;
        uint256 timestamp;
        uint256 alertCount;
    }
    
    // State variables
    mapping(address => MonitoringRequest[]) public userMonitoring;
    mapping(string => address[]) public tokenMonitors; // tokenAddress => users monitoring it
    
    modifier requirePayment() {
        if (!dToken.hasFeaturePayment(msg.sender)) revert InsufficientPayment();
        _;
    }

    constructor(address payable _dToken) Ownable(msg.sender) {
        dToken = DToken(_dToken);
    }
    
    /**
     * @dev Request monitoring setup - requires 0.0001 ETH payment
     * @param tokenAddress The token address to monitor
     * @param alertThreshold Price change threshold for alerts (in basis points)
     */
    function requestMonitoring(string memory tokenAddress, uint256 alertThreshold) external requirePayment nonReentrant {
        if (bytes(tokenAddress).length == 0) revert InvalidTokenAddress();
        
        // Use DToken payment
        dToken.useFeature(msg.sender);
        
        // Create monitoring request
        MonitoringRequest memory newRequest = MonitoringRequest({
            user: msg.sender,
            tokenAddress: tokenAddress,
            payment: MONITORING_COST,
            active: true,
            alertThreshold: alertThreshold,
            timestamp: block.timestamp,
            alertCount: 0
        });
        
        userMonitoring[msg.sender].push(newRequest);
        tokenMonitors[tokenAddress].push(msg.sender);
        
        emit MonitoringRequested(msg.sender, tokenAddress, MONITORING_COST);
        emit MonitoringSetup(msg.sender, tokenAddress, alertThreshold);
        emit PaymentReceived(msg.sender, MONITORING_COST);
    }
    
    /**
     * @dev Trigger alert for monitored token (called by owner/backend)
     * @param tokenAddress The token address that triggered the alert
     * @param alertType Type of alert (e.g., "PRICE_SPIKE", "WHALE_MOVEMENT", "VOLUME_SURGE")
     * @param value The value that triggered the alert
     */
    function triggerAlert(
        string memory tokenAddress,
        string memory alertType,
        uint256 value
    ) external onlyOwner {
        address[] memory monitors = tokenMonitors[tokenAddress];
        
        for (uint256 i = 0; i < monitors.length; i++) {
            address user = monitors[i];
            MonitoringRequest[] storage requests = userMonitoring[user];
            
            for (uint256 j = 0; j < requests.length; j++) {
                if (keccak256(bytes(requests[j].tokenAddress)) == keccak256(bytes(tokenAddress)) && 
                    requests[j].active) {
                    requests[j].alertCount += 1;
                    emit AlertTriggered(user, tokenAddress, alertType, value);
                }
            }
        }
    }
    
    /**
     * @dev Stop monitoring for a token
     * @param requestIndex Index of the monitoring request to stop
     */
    function stopMonitoring(uint256 requestIndex) external {
        require(requestIndex < userMonitoring[msg.sender].length, "Invalid request index");
        require(userMonitoring[msg.sender][requestIndex].active, "Monitoring already stopped");
        
        userMonitoring[msg.sender][requestIndex].active = false;
    }
    
    /**
     * @dev Get user's monitoring requests
     * @param user The user address
     * @return Array of monitoring requests
     */
    function getUserMonitoring(address user) external view returns (MonitoringRequest[] memory) {
        return userMonitoring[user];
    }
    
    /**
     * @dev Get users monitoring a specific token
     * @param tokenAddress The token address
     * @return Array of user addresses
     */
    function getTokenMonitors(string memory tokenAddress) external view returns (address[] memory) {
        return tokenMonitors[tokenAddress];
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
        return MONITORING_COST;
    }
}