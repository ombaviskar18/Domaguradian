# 🌐 SonicGuardian on Sonic Network

## 🚀 **Sonic Network Integration**

SonicGuardian is now fully integrated with **Sonic Network**, a high-performance EVM-compatible blockchain that provides fast, secure, and cost-effective transactions.

## 📋 **Network Details**

| Parameter | Value |
|-----------|-------|
| **Network Name** | Sonic Testnet |
| **Chain ID** | 14601 |
| **RPC URL** | https://rpc.testnet.soniclabs.com |
| **Explorer** | https://testnet.soniclabs.com |
| **Currency** | S (native), SGS (ERC-20) |
| **Block Time** | ~1 second |
| **Gas Price** | 20 Gwei |

## 🔧 **MetaMask Setup**

### **Add Sonic Testnet to MetaMask:**

1. **Network Name**: `Sonic Testnet`
2. **RPC URL**: `https://rpc.testnet.soniclabs.com`
3. **Chain ID**: `14601`
4. **Currency Symbol**: `S`
5. **Block Explorer**: `https://testnet.soniclabs.com`

### **Add SGS Token to MetaMask:**

1. **Contract Address**: `0x7ba0f1BA2F61aB8190200C20b7755C56292C5728`
2. **Token Symbol**: `SGS`
3. **Decimals**: `18`
4. **Token Name**: `SonicGuardian Token`

## 💰 **Token Economics**

### **SGS Token (SonicGuardian Token)**
- **Total Supply**: 1,000,000 SGS
- **Feature Cost**: 1 SGS per analysis
- **Standard**: ERC-20
- **Network**: Sonic Testnet
- **Purpose**: Access control for SonicGuardian features

### **Native S Token**
- **Purpose**: Gas fees only
- **Usage**: Transaction fees, contract interactions
- **Faucet**: Available on Sonic Testnet

## 🏗️ **Smart Contract Architecture**

### **Deployed Contracts on Sonic Testnet:**

```
SToken (SGS): 0x7ba0f1BA2F61aB8190200C20b7755C56292C5728
├── ContractAnalysis: 0x3a0B68b62Ae686D49cFe4ED15F903337557A26a4
├── Tokenomics: 0x48a471675A98FB98e70989C55c785aaFd75Aa67a
├── SocialAnalysis: 0xa4916233f1FF28C638E987a1bDc8d03bDdf92d98
├── Monitoring: 0x3523675708a44f68e19B390471a5ddC87E985f06
└── Universal: 0xaa71b81373d21496073c089c7D54a24b28CD1e1b
```

### **Contract Features:**
- ✅ **Pausable**: Emergency stop functionality
- ✅ **Ownable**: Admin controls
- ✅ **ReentrancyGuard**: Security protection
- ✅ **SGS Integration**: Token-based access control
- ✅ **Event Logging**: Comprehensive transaction tracking

## 🔄 **Migration from ZetaChain**

### **What Changed:**
- ❌ **Removed**: ZetaChain GatewayZEVM integration
- ❌ **Removed**: Native ZETA token payments
- ❌ **Removed**: Cross-chain message passing
- ✅ **Added**: Direct Sonic Network integration
- ✅ **Added**: SGS token payment system
- ✅ **Added**: Native EVM contract interactions

### **Benefits of Sonic Network:**
- 🚀 **Faster Transactions**: ~1 second block time
- 💰 **Lower Costs**: Reduced gas fees
- 🔧 **EVM Compatible**: Easy migration from Ethereum
- 🌐 **Scalable**: High throughput capacity
- 🔒 **Secure**: Advanced consensus mechanism

## 🛠️ **Development Setup**

### **Hardhat Configuration:**
```typescript
// hardhat.config.ts
networks: {
  sonic: {
    url: "https://rpc.testnet.soniclabs.com",
    chainId: 14601,
    accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    gasPrice: 20000000000, // 20 gwei
  }
}
```

### **Deployment Commands:**
```bash
# Deploy to Sonic Testnet
npx hardhat run scripts/deploy-sonic.ts --network sonic

# Test contracts
npx hardhat run scripts/test-contracts.ts --network sonic
```

## 📱 **User Experience**

### **How It Works:**
1. **Connect Wallet**: MetaMask to Sonic Testnet
2. **Add SGS Token**: Import SGS token to wallet
3. **Get SGS Tokens**: Contact deployer for initial tokens
4. **Use Features**: Each analysis costs 1 SGS token
5. **Pay Gas**: Native S tokens for transaction fees

### **Transaction Flow:**
```
User → MetaMask → Sonic Testnet → SGS Contract → Feature Contract → Analysis
```

## 🔍 **Explorer Integration**

### **Transaction Tracking:**
- **Explorer**: https://testnet.soniclabs.com
- **Contract Verification**: All contracts verified
- **Transaction History**: Full audit trail
- **Event Logs**: Comprehensive logging

### **Example Transaction:**
```
Hash: 0x6c3b8fdc168eaf7f312d0243ca80cbfbf2839c9f44f96159487dc53dfba99d19
From: 0xc5420a06016e680cb03f5714290124eebbe58d3f
To: 0xe623c001f28811f72aa024bf9608a59c5e66720d
Amount: 0 S (gas only)
Gas Used: 153,213
Status: Success
```

## 🚀 **Getting Started**

### **For Users:**
1. Add Sonic Testnet to MetaMask
2. Add SGS token to wallet
3. Get SGS tokens from deployer
4. Start using SonicGuardian features!

### **For Developers:**
1. Clone the repository
2. Install dependencies
3. Configure environment variables
4. Deploy contracts to Sonic Testnet
5. Update frontend contract addresses

## 📞 **Support**

- **Network Issues**: Check Sonic Testnet status
- **Token Issues**: Verify SGS token balance
- **Contract Issues**: Check transaction on explorer
- **General Support**: GitHub Issues or Telegram

---

**🌐 Built on Sonic Network - The Future of EVM Blockchains**
