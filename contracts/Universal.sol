// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "./DToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Universal is Ownable, ReentrancyGuard {
    DToken public immutable dToken;
    
    // Payment required for each message (0.0001 ETH)
    uint256 public constant MESSAGE_COST = 0.0001 ether;
    
    // Events
    event MessageSent(address indexed sender, address indexed recipient, string message, uint256 payment);
    event CrossChainMessageSent(address indexed sender, uint256 destinationChain, address recipient, string message);
    event PaymentReceived(address indexed user, uint256 amount);
    
    // Errors
    error InsufficientPayment();
    error InvalidRecipient();
    error InvalidMessage();
    
    // Structs
    struct Message {
        address sender;
        address recipient;
        string content;
        uint256 timestamp;
        uint256 payment;
        bool crossChain;
        uint256 destinationChain;
    }
    
    // State variables
    mapping(address => Message[]) public userMessages;
    mapping(address => Message[]) public receivedMessages;
    Message[] public allMessages;
    
    modifier requirePayment() {
        if (!dToken.hasFeaturePayment(msg.sender)) revert InsufficientPayment();
        _;
    }

    constructor(address payable _dToken) Ownable(msg.sender) {
        dToken = DToken(_dToken);
    }
    
    /**
     * @dev Send a message - requires 0.0001 ETH payment
     * @param recipient The recipient address
     * @param message The message content
     */
    function sendMessage(address recipient, string memory message) external requirePayment nonReentrant {
        if (recipient == address(0)) revert InvalidRecipient();
        if (bytes(message).length == 0) revert InvalidMessage();
        
        // Use DToken payment
        dToken.useFeature(msg.sender);
        
        // Create message
        Message memory newMessage = Message({
            sender: msg.sender,
            recipient: recipient,
            content: message,
            timestamp: block.timestamp,
            payment: MESSAGE_COST,
            crossChain: false,
            destinationChain: block.chainid
        });
        
        userMessages[msg.sender].push(newMessage);
        receivedMessages[recipient].push(newMessage);
        allMessages.push(newMessage);
        
        emit MessageSent(msg.sender, recipient, message, MESSAGE_COST);
        emit PaymentReceived(msg.sender, MESSAGE_COST);
    }
    
    /**
     * @dev Send a cross-chain message - requires 0.0001 ETH payment
     * @param destinationChain The destination chain ID
     * @param recipient The recipient address on destination chain
     * @param message The message content
     */
    function sendCrossChainMessage(
        uint256 destinationChain,
        address recipient,
        string memory message
    ) external requirePayment nonReentrant {
        if (recipient == address(0)) revert InvalidRecipient();
        if (bytes(message).length == 0) revert InvalidMessage();
        if (destinationChain == block.chainid) revert InvalidRecipient();
        
        // Use DToken payment
        dToken.useFeature(msg.sender);
        
        // Create cross-chain message
        Message memory newMessage = Message({
            sender: msg.sender,
            recipient: recipient,
            content: message,
            timestamp: block.timestamp,
            payment: MESSAGE_COST,
            crossChain: true,
            destinationChain: destinationChain
        });
        
        userMessages[msg.sender].push(newMessage);
        allMessages.push(newMessage);
        
        emit CrossChainMessageSent(msg.sender, destinationChain, recipient, message);
        emit PaymentReceived(msg.sender, MESSAGE_COST);
    }
    
    /**
     * @dev Get user's sent messages
     * @param user The user address
     * @return Array of sent messages
     */
    function getUserMessages(address user) external view returns (Message[] memory) {
        return userMessages[user];
    }
    
    /**
     * @dev Get user's received messages
     * @param user The user address
     * @return Array of received messages
     */
    function getReceivedMessages(address user) external view returns (Message[] memory) {
        return receivedMessages[user];
    }
    
    /**
     * @dev Get all messages (paginated)
     * @param offset Starting index
     * @param limit Number of messages to return
     * @return Array of messages
     */
    function getAllMessages(uint256 offset, uint256 limit) external view returns (Message[] memory) {
        uint256 total = allMessages.length;
        if (offset >= total) return new Message[](0);
        
        uint256 end = offset + limit;
        if (end > total) end = total;
        
        Message[] memory result = new Message[](end - offset);
        for (uint256 i = offset; i < end; i++) {
            result[i - offset] = allMessages[i];
        }
        
        return result;
    }
    
    /**
     * @dev Get total message count
     * @return count The total number of messages
     */
    function getTotalMessages() external view returns (uint256 count) {
        return allMessages.length;
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
        return MESSAGE_COST;
    }
}