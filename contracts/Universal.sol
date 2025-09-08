// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "./SToken.sol";

contract Universal {
    SToken public immutable S_TOKEN;
    address public owner;

    event HelloEvent(string, string);
    event MessageSent(address indexed user, string message, uint256 timestamp);
    error Unauthorized();
    error InsufficientSTokens();

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
     * @dev Send a message (requires 1 S token)
     * @param message The message to send
     */
    function sendMessage(string memory message) external requireSTokens {
        // Use 1 S token for sending a message
        S_TOKEN.useFeature(msg.sender, 1 * 10**18);
        
        emit HelloEvent("Hello: ", message);
        emit MessageSent(msg.sender, message, block.timestamp);
    }

    /**
     * @dev Get user's S token balance
     */
    function getUserSTokenBalance(address user) external view returns (uint256) {
        return S_TOKEN.balanceOf(user);
    }

    /**
     * @dev Get the S token address
     */
    function getSTokenAddress() external view returns (address) {
        return address(S_TOKEN);
    }
}
