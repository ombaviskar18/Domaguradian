import { ethers } from 'ethers';
import { DOMA_GUARDIAN_CONTRACTS } from '../constants/contracts';

// Contract addresses from deployment (Doma Testnet)
export const CONTRACT_ADDRESSES = DOMA_GUARDIAN_CONTRACTS;

// Network configuration (Doma Testnet)
export const NETWORK_CONFIG = {
  name: 'Doma Testnet',
  rpcUrl: 'https://rpc-testnet.doma.xyz',
  chainId: 97476,
  currency: 'ETH',
  explorer: 'https://explorer-testnet.doma.xyz',
};

// Contract ABIs (simplified for the main functions)
export const CONTRACT_ABI = [
  // Feature entrypoints (no value, uses DToken balance credit)
  'function requestContractAnalysis(string contractAddress) external',
  'function requestTokenomicsAnalysis(string tokenAddress) external',
  'function requestSocialAnalysis(string projectName) external',
  'function requestMonitoring(string targetAddress, uint256 alertThreshold) external',
  'function getUserRequests(address user) external view returns (tuple(address user, string target, uint256 payment, bool completed, uint256 riskScore, string analysis, uint256 timestamp)[])',
  'event ContractAnalysisRequested(address indexed user, string contractAddress, uint256 payment)',
  'event TokenomicsAnalysisRequested(address indexed user, string tokenAddress, uint256 payment)',
  'event SocialAnalysisRequested(address indexed user, string projectName, uint256 payment)',
  'event MonitoringRequested(address indexed user, string targetAddress, uint256 payment)',
  'event ContractAnalysisCompleted(address indexed user, string contractAddress, uint256 riskScore, string analysis)',
  'event TokenomicsAnalysisCompleted(address indexed user, string tokenAddress, uint256 riskScore, string analysis)',
  'event SocialAnalysisCompleted(address indexed user, string projectName, uint256 riskScore, string analysis)',
  'event MonitoringCompleted(address indexed user, string targetAddress, uint256 riskScore, string analysis)',
  'event PaymentReceived(address indexed user, uint256 amount)'
];

// DToken ABI for payments
export const DTOKEN_ABI = [
  'function FEATURE_COST() view returns (uint256)',
  'function payForFeature() external payable',
  'function hasFeaturePayment(address user) external view returns (bool)',
  'function getUserPaymentBalance(address user) external view returns (uint256)'
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

  private getContract(address: string) {
    if (!this.signer) throw new Error('Wallet not connected');
    return new ethers.Contract(address, CONTRACT_ABI, this.signer);
  }

  private getDToken() {
    if (!this.signer) throw new Error('Wallet not connected');
    return new ethers.Contract(CONTRACT_ADDRESSES.DToken, DTOKEN_ABI, this.signer);
  }

  async ensurePaymentCredit() {
    const dtoken = this.getDToken();
    const user = await this.signer!.getAddress();
    const has = await dtoken.hasFeaturePayment(user);
    if (!has) {
      // Pay exactly feature cost
      const cost: bigint = await dtoken.FEATURE_COST();
      const tx = await dtoken.payForFeature({ value: cost });
      await tx.wait();
    }
  }

  async requestContractAnalysis(contractAddress: string) {
    await this.ensurePaymentCredit();
    const contract = this.getContract(CONTRACT_ADDRESSES.ContractAnalysis);
    const tx = await contract.requestContractAnalysis(contractAddress);
    return await tx.wait();
  }

  async requestTokenomicsAnalysis(tokenAddress: string) {
    await this.ensurePaymentCredit();
    const contract = this.getContract(CONTRACT_ADDRESSES.Tokenomics);
    const tx = await contract.requestTokenomicsAnalysis(tokenAddress);
    return await tx.wait();
  }

  async requestSocialAnalysis(projectName: string) {
    await this.ensurePaymentCredit();
    const contract = this.getContract(CONTRACT_ADDRESSES.SocialAnalysis);
    const tx = await contract.requestSocialAnalysis(projectName);
    return await tx.wait();
  }

  async requestMonitoring(targetAddress: string, alertThreshold: number) {
    await this.ensurePaymentCredit();
    const contract = this.getContract(CONTRACT_ADDRESSES.Monitoring);
    const tx = await contract.requestMonitoring(targetAddress, alertThreshold);
    return await tx.wait();
  }

  async getUserRequests(
    contractType: 'ContractAnalysis' | 'Tokenomics' | 'SocialAnalysis' | 'Monitoring',
    userAddress: string,
  ) {
    if (!this.provider) throw new Error('Provider not connected');
    const contract = new ethers.Contract(
      CONTRACT_ADDRESSES[contractType],
      CONTRACT_ABI,
      this.provider,
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

// Network switching utility (Doma)
export async function switchToDoma() {
  if (typeof window.ethereum !== 'undefined') {
    try {
      await window.ethereum.request({
        method: 'wallet_switchEthereumChain',
        params: [{ chainId: `0x${NETWORK_CONFIG.chainId.toString(16)}` }],
      });
      return true;
    } catch (switchError: any) {
      if (switchError.code === 4902) {
        try {
          await window.ethereum.request({
            method: 'wallet_addEthereumChain',
            params: [{
              chainId: `0x${NETWORK_CONFIG.chainId.toString(16)}`,
              chainName: NETWORK_CONFIG.name,
              nativeCurrency: { name: NETWORK_CONFIG.currency, symbol: NETWORK_CONFIG.currency, decimals: 18 },
              rpcUrls: [NETWORK_CONFIG.rpcUrl],
              blockExplorerUrls: [NETWORK_CONFIG.explorer],
            }],
          });
          return true;
        } catch (addError) {
          console.error('Failed to add Doma Testnet to MetaMask:', addError);
          return false;
        }
      }
      return false;
    }
  }
  return false;
}

// Backward-compatible aliases
export const switchToSonic = switchToDoma;
export const switchToZetaChain = switchToDoma;
