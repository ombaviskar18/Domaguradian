// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./DToken.sol";

/**
 * @title DomainManagement
 * @dev Domain tokenization and management contract for DomainFi ecosystem
 * @notice Handles domain tokenization, rights management, and DomainFi operations
 */
contract DomainManagement is Ownable, ReentrancyGuard {
    DToken public immutable dToken;
    
    struct Domain {
        string name;
        address owner;
        bool isTokenized;
        uint256 tokenizedAt;
        mapping(string => address) rights; // right name => address with that right
        bool isActive;
    }
    
    struct DomainRights {
        string rightName;
        string description;
        address holder;
        uint256 grantedAt;
        uint256 expiresAt;
    }
    
    mapping(string => Domain) public domains;
    mapping(string => DomainRights[]) public domainRights;
    mapping(address => string[]) public userDomains;
    
    string[] public allDomains;
    
    // Events
    event DomainTokenized(string indexed domainName, address indexed owner, uint256 timestamp);
    event DomainRightGranted(string indexed domainName, string rightName, address indexed holder, uint256 expiresAt);
    event DomainRightRevoked(string indexed domainName, string rightName, address indexed holder);
    event DomainTransferred(string indexed domainName, address indexed from, address indexed to);
    event DomainStateSync(string indexed domainName, bool isActive);
    
    // Errors
    error DomainNotExists();
    error DomainAlreadyTokenized();
    error NotDomainOwner();
    error InsufficientPayment();
    error InvalidDomainName();
    error RightNotExists();
    error RightExpired();
    
    modifier onlyDomainOwner(string memory domainName) {
        if (domains[domainName].owner != msg.sender) revert NotDomainOwner();
        _;
    }
    
    modifier domainExists(string memory domainName) {
        if (bytes(domains[domainName].name).length == 0) revert DomainNotExists();
        _;
    }
    
    constructor(address payable _dToken) Ownable(msg.sender) {
        dToken = DToken(_dToken);
    }
    
    /**
     * @dev Tokenize a domain onto the blockchain
     * @param domainName The domain name to tokenize
     */
    function tokenizeDomain(string memory domainName) external nonReentrant {
        if (bytes(domainName).length == 0) revert InvalidDomainName();
        if (domains[domainName].isTokenized) revert DomainAlreadyTokenized();
        
        // Use DToken payment
        dToken.useFeature(msg.sender);
        
        Domain storage domain = domains[domainName];
        domain.name = domainName;
        domain.owner = msg.sender;
        domain.isTokenized = true;
        domain.tokenizedAt = block.timestamp;
        domain.isActive = true;
        
        allDomains.push(domainName);
        userDomains[msg.sender].push(domainName);
        
        emit DomainTokenized(domainName, msg.sender, block.timestamp);
    }
    
    /**
     * @dev Grant specific rights for a domain to an address
     * @param domainName The domain name
     * @param rightName The name of the right (e.g., "DNS_MANAGEMENT", "TRANSFER", "SUBDOMAIN")
     * @param holder The address to grant the right to
     * @param duration Duration in seconds (0 for permanent)
     */
    function grantDomainRight(
        string memory domainName,
        string memory rightName,
        address holder,
        uint256 duration
    ) external domainExists(domainName) onlyDomainOwner(domainName) nonReentrant {
        // Use DToken payment
        dToken.useFeature(msg.sender);
        
        uint256 expiresAt = duration == 0 ? 0 : block.timestamp + duration;
        
        domains[domainName].rights[rightName] = holder;
        
        DomainRights memory newRight = DomainRights({
            rightName: rightName,
            description: string(abi.encodePacked("Right: ", rightName, " for domain: ", domainName)),
            holder: holder,
            grantedAt: block.timestamp,
            expiresAt: expiresAt
        });
        
        domainRights[domainName].push(newRight);
        
        emit DomainRightGranted(domainName, rightName, holder, expiresAt);
    }
    
    /**
     * @dev Revoke a specific right for a domain
     * @param domainName The domain name
     * @param rightName The name of the right to revoke
     */
    function revokeDomainRight(
        string memory domainName,
        string memory rightName
    ) external domainExists(domainName) onlyDomainOwner(domainName) {
        address rightHolder = domains[domainName].rights[rightName];
        if (rightHolder == address(0)) revert RightNotExists();
        
        domains[domainName].rights[rightName] = address(0);
        
        emit DomainRightRevoked(domainName, rightName, rightHolder);
    }
    
    /**
     * @dev Transfer domain ownership
     * @param domainName The domain name to transfer
     * @param to The new owner address
     */
    function transferDomain(
        string memory domainName,
        address to
    ) external domainExists(domainName) onlyDomainOwner(domainName) nonReentrant {
        // Use DToken payment
        dToken.useFeature(msg.sender);
        
        address from = domains[domainName].owner;
        domains[domainName].owner = to;
        
        // Update user domain lists
        userDomains[to].push(domainName);
        
        // Remove from old owner's list
        string[] storage fromDomains = userDomains[from];
        for (uint256 i = 0; i < fromDomains.length; i++) {
            if (keccak256(bytes(fromDomains[i])) == keccak256(bytes(domainName))) {
                fromDomains[i] = fromDomains[fromDomains.length - 1];
                fromDomains.pop();
                break;
            }
        }
        
        emit DomainTransferred(domainName, from, to);
    }
    
    /**
     * @dev Synchronize domain state with ICANN registry
     * @param domainName The domain name
     * @param isActive Whether the domain is active in ICANN registry
     */
    function syncDomainState(string memory domainName, bool isActive) external onlyOwner domainExists(domainName) {
        domains[domainName].isActive = isActive;
        emit DomainStateSync(domainName, isActive);
    }
    
    /**
     * @dev Check if an address has a specific right for a domain
     * @param domainName The domain name
     * @param rightName The right name to check
     * @param user The address to check
     * @return hasRight Whether the address has the right
     */
    function hasRight(
        string memory domainName,
        string memory rightName,
        address user
    ) external view domainExists(domainName) returns (bool) {
        address rightHolder = domains[domainName].rights[rightName];
        if (rightHolder != user) return false;
        
        // Check if right has expired
        DomainRights[] memory rights = domainRights[domainName];
        for (uint256 i = 0; i < rights.length; i++) {
            if (keccak256(bytes(rights[i].rightName)) == keccak256(bytes(rightName)) && 
                rights[i].holder == user) {
                if (rights[i].expiresAt == 0 || rights[i].expiresAt > block.timestamp) {
                    return true;
                }
                break;
            }
        }
        
        return false;
    }
    
    /**
     * @dev Get domain information
     * @param domainName The domain name
     * @return owner The domain owner
     * @return isTokenized Whether the domain is tokenized
     * @return tokenizedAt When the domain was tokenized
     * @return isActive Whether the domain is active
     */
    function getDomainInfo(string memory domainName) external view domainExists(domainName) returns (
        address owner,
        bool isTokenized,
        uint256 tokenizedAt,
        bool isActive
    ) {
        Domain storage domain = domains[domainName];
        return (domain.owner, domain.isTokenized, domain.tokenizedAt, domain.isActive);
    }
    
    /**
     * @dev Get all domains owned by a user
     * @param user The user address
     * @return userDomainList Array of domain names
     */
    function getUserDomains(address user) external view returns (string[] memory userDomainList) {
        return userDomains[user];
    }
    
    /**
     * @dev Get all rights for a domain
     * @param domainName The domain name
     * @return rights Array of domain rights
     */
    function getDomainRights(string memory domainName) external view domainExists(domainName) returns (DomainRights[] memory rights) {
        return domainRights[domainName];
    }
    
    /**
     * @dev Get total number of tokenized domains
     * @return count The total count
     */
    function getTotalDomains() external view returns (uint256 count) {
        return allDomains.length;
    }
    
    /**
     * @dev Get all tokenized domains (paginated)
     * @param offset Starting index
     * @param limit Number of domains to return
     * @return domainList Array of domain names
     */
    function getAllDomains(uint256 offset, uint256 limit) external view returns (string[] memory domainList) {
        uint256 total = allDomains.length;
        if (offset >= total) return new string[](0);
        
        uint256 end = offset + limit;
        if (end > total) end = total;
        
        domainList = new string[](end - offset);
        for (uint256 i = offset; i < end; i++) {
            domainList[i - offset] = allDomains[i];
        }
        
        return domainList;
    }
}