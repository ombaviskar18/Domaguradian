import { ethers } from 'ethers';
import { SONIC_GUARDIAN_CONTRACTS } from '../constants/contracts';

// Contract addresses from deployment (Sonic Testnet)
export const CONTRACT_ADDRESSES = SONIC_GUARDIAN_CONTRACTS;

// Network configuration (Sonic Testnet)
export const NETWORK_CONFIG = {
  name: "Sonic Testnet",
  rpcUrl: "https://rpc.testnet.soniclabs.com",
  chainId: 14601,
  currency: "S",
  explorer: "https://testnet.soniclabs.com"
};

// Contract ABIs (simplified for the main functions)
export const CONTRACT_ABI = [
  // Request analysis using S token (no native value)
  "function requestContractAnalysis(string contractAddress) external",
  "function requestTokenomicsAnalysis(string tokenAddress) external",
  "function requestSocialAnalysis(string projectName) external",
  "function requestMonitoring(string targetAddress) external",
  

  
  // Get user requests
  "function getUserRequests(address user) external view returns (tuple(address user, string target, uint256 payment, bool completed, uint256 riskScore, string analysis, uint256 timestamp)[])",
  
  // Events
  "event ContractAnalysisRequested(address indexed user, string contractAddress, uint256 payment)",
  "event TokenomicsAnalysisRequested(address indexed user, string tokenAddress, uint256 payment)",
  "event SocialAnalysisRequested(address indexed user, string projectName, uint256 payment)",
  "event MonitoringRequested(address indexed user, string targetAddress, uint256 payment)",
  
  "event ContractAnalysisCompleted(address indexed user, string contractAddress, uint256 riskScore, string analysis)",
  "event TokenomicsAnalysisCompleted(address indexed user, string tokenAddress, uint256 riskScore, string analysis)",
  "event SocialAnalysisCompleted(address indexed user, string projectName, uint256 riskScore, string analysis)",
  "event MonitoringCompleted(address indexed user, string targetAddress, uint256 riskScore, string analysis)",
  
  "event PaymentReceived(address indexed user, uint256 amount)",
  "event AlertTriggered(address indexed user, string targetAddress, string alertType, string message)"
];

// Contract interaction utilities
export class ContractService {
  private provider: ethers.BrowserProvider | null = null;
  private signer: ethers.JsonRpcSigner | null = null;

  async connect() {
    if (typeof window.ethereum !== 'undefined') {
      this.provider = new ethers.BrowserProvider(window.ethereum);
      this.signer = await this.provider.getSigner();
      return true;
    }
    return false;
  }

  async requestContractAnalysis(contractAddress: string) {
    if (!this.signer) throw new Error("Wallet not connected");
    
    const contract = new ethers.Contract(
      CONTRACT_ADDRESSES.ContractAnalysis,
      CONTRACT_ABI,
      this.signer
    );

    const tx = await contract.requestContractAnalysis(contractAddress);
    return await tx.wait();
  }

  async requestTokenomicsAnalysis(tokenAddress: string) {
    if (!this.signer) throw new Error("Wallet not connected");
    const contract = new ethers.Contract(
      CONTRACT_ADDRESSES.Tokenomics,
      CONTRACT_ABI,
      this.signer
    );

    const tx = await contract.requestTokenomicsAnalysis(tokenAddress);
    return await tx.wait();
  }

  async requestSocialAnalysis(projectName: string) {
    if (!this.signer) throw new Error("Wallet not connected");
    
    const contract = new ethers.Contract(
      CONTRACT_ADDRESSES.SocialAnalysis,
      CONTRACT_ABI,
      this.signer
    );

    const tx = await contract.requestSocialAnalysis(projectName);
    return await tx.wait();
  }

  async requestMonitoring(targetAddress: string) {
    if (!this.signer) throw new Error("Wallet not connected");
    
    const contract = new ethers.Contract(
      CONTRACT_ADDRESSES.Monitoring,
      CONTRACT_ABI,
      this.signer
    );

    const tx = await contract.requestMonitoring(targetAddress);
    return await tx.wait();
  }

  async getUserRequests(contractType: 'ContractAnalysis' | 'Tokenomics' | 'SocialAnalysis' | 'Monitoring', userAddress: string) {
    if (!this.provider) throw new Error("Provider not connected");
    
    const contract = new ethers.Contract(
      CONTRACT_ADDRESSES[contractType],
      CONTRACT_ABI,
      this.provider
    );

    return await contract.getUserRequests(userAddress);
  }

  async getCurrentAddress(): Promise<string | null> {
    if (!this.signer) return null;
    return await this.signer.getAddress();
  }

  async getNetwork() {
    if (!this.provider) return null;
    return await this.provider.getNetwork();
  }
}

// Export singleton instance
export const contractService = new ContractService();

// Utility functions
export const formatEther = (wei: bigint) => ethers.formatEther(wei);
export const parseEther = (ether: string) => ethers.parseEther(ether);

// Network switching utility
export async function switchToSonic() {
  if (typeof window.ethereum !== 'undefined') {
    try {
      await window.ethereum.request({
        method: 'wallet_switchEthereumChain',
        params: [{ chainId: `0x${NETWORK_CONFIG.chainId.toString(16)}` }],
      });
      return true;
    } catch (switchError: any) {
      // This error code indicates that the chain has not been added to MetaMask
      if (switchError.code === 4902) {
        try {
          await window.ethereum.request({
            method: 'wallet_addEthereumChain',
            params: [{
              chainId: `0x${NETWORK_CONFIG.chainId.toString(16)}`,
              chainName: NETWORK_CONFIG.name,
              nativeCurrency: {
                name: NETWORK_CONFIG.currency,
                symbol: NETWORK_CONFIG.currency,
                decimals: 18
              },
              rpcUrls: [NETWORK_CONFIG.rpcUrl],
              blockExplorerUrls: [NETWORK_CONFIG.explorer]
            }],
          });
          return true;
        } catch (addError) {
          console.error('Failed to add Sonic Testnet to MetaMask:', addError);
          return false;
        }
      }
      return false;
    }
  }
  return false;
}

// Backward-compatible alias
export const switchToZetaChain = switchToSonic;
