// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title SToken
 * @dev ERC20 token for Sonic Network - SonicGuardian platform
 * @notice This token is required for using SonicGuardian features (1 S token per feature)
 */
contract SToken is ERC20Pausable, Ownable, ReentrancyGuard {
    // Token details
    uint256 public constant INITIAL_SUPPLY = 1000000 * 10**18; // 1 million S tokens
    uint256 public constant FEATURE_COST = 1 * 10**18; // 1 S token per feature
    
    // Feature contracts that can spend tokens
    mapping(address => bool) public authorizedContracts;
    
    // Events
    event ContractAuthorized(address indexed contractAddress, bool authorized);
    event FeatureUsed(address indexed user, address indexed contractAddress, uint256 cost);
    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(address indexed from, uint256 amount);
    
    // Errors
    error UnauthorizedContract();
    error InsufficientSTokens();
    error InvalidAmount();
    error ContractNotAuthorized();
    
    modifier onlyAuthorized() {
        if (!authorizedContracts[msg.sender]) revert UnauthorizedContract();
        _;
    }
    
    constructor() ERC20("SonicGuardian Token", "SGS") Ownable(msg.sender) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
    
    /**
     * @dev Authorize a contract to spend S tokens for features
     * @param contractAddress The address of the contract to authorize
     * @param authorized Whether to authorize or deauthorize
     */
    function authorizeContract(address contractAddress, bool authorized) external onlyOwner {
        authorizedContracts[contractAddress] = authorized;
        emit ContractAuthorized(contractAddress, authorized);
    }
    
    /**
     * @dev Use S tokens for a feature (called by authorized contracts)
     * @param user The user using the feature
     * @param cost The cost in S tokens (should be FEATURE_COST)
     */
    function useFeature(address user, uint256 cost) external onlyAuthorized nonReentrant {
        if (cost != FEATURE_COST) revert InvalidAmount();
        if (balanceOf(user) < cost) revert InsufficientSTokens();
        
        _transfer(user, address(this), cost);
        emit FeatureUsed(user, msg.sender, cost);
    }
    
    /**
     * @dev Check if user has enough S tokens for a feature
     * @param user The user to check
     * @return hasEnough Whether user has enough tokens
     */
    function hasEnoughForFeature(address user) external view returns (bool hasEnough) {
        return balanceOf(user) >= FEATURE_COST;
    }
    
    /**
     * @dev Get the cost of using a feature
     * @return cost The cost in S tokens
     */
    function getFeatureCost() external pure returns (uint256 cost) {
        return FEATURE_COST;
    }
    
    /**
     * @dev Mint new tokens (owner only)
     * @param to The address to mint to
     * @param amount The amount to mint
     */
    function mint(address to, uint256 amount) external onlyOwner {
        if (amount == 0) revert InvalidAmount();
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }
    
    /**
     * @dev Burn tokens from contract balance
     * @param amount The amount to burn
     */
    function burn(uint256 amount) external onlyOwner {
        if (amount == 0) revert InvalidAmount();
        if (balanceOf(address(this)) < amount) revert InsufficientSTokens();
        
        _burn(address(this), amount);
        emit TokensBurned(address(this), amount);
    }
    
    /**
     * @dev Withdraw accumulated S tokens (owner only)
     * @param amount The amount to withdraw
     */
    function withdrawTokens(uint256 amount) external onlyOwner nonReentrant {
        if (amount == 0) revert InvalidAmount();
        if (balanceOf(address(this)) < amount) revert InsufficientSTokens();
        
        _transfer(address(this), owner(), amount);
    }
    
    /**
     * @dev Pause token transfers
     */
    function pause() external onlyOwner { _pause(); }
    
    /**
     * @dev Unpause token transfers
     */
    function unpause() external onlyOwner { _unpause(); }
    
    // ERC20Pausable handles paused state during token transfers
    
    /**
     * @dev Get contract balance of S tokens
     * @return balance The contract's S token balance
     */
    function getContractBalance() external view returns (uint256 balance) {
        return balanceOf(address(this));
    }
    
    /**
     * @dev Get total supply
     * @return supply The total supply of S tokens
     */
    function getTotalSupply() external view returns (uint256 supply) {
        return totalSupply();
    }
}
