import { ethers } from "hardhat";
import fs from "fs";
import path from "path";

async function main() {
  console.log("🚀 Starting deployment to Doma Testnet...");
  
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  // Deploy DToken (ETH payment system)
  console.log("\n📄 Deploying DToken...");
  const DToken = await ethers.getContractFactory("DToken");
  const dToken = await DToken.deploy();
  await dToken.deployed();
  console.log("✅ DToken deployed to:", dToken.address);

  // Deploy DomainManagement
  console.log("\n🏠 Deploying DomainManagement...");
  const DomainManagement = await ethers.getContractFactory("DomainManagement");
  const domainManagement = await DomainManagement.deploy(dToken.address);
  await domainManagement.deployed();
  console.log("✅ DomainManagement deployed to:", domainManagement.address);

  // Deploy ContractAnalysis
  console.log("\n🔍 Deploying ContractAnalysis...");
  const ContractAnalysis = await ethers.getContractFactory("ContractAnalysis");
  const contractAnalysis = await ContractAnalysis.deploy(dToken.address);
  await contractAnalysis.deployed();
  console.log("✅ ContractAnalysis deployed to:", contractAnalysis.address);

  // Deploy SocialAnalysis
  console.log("\n📱 Deploying SocialAnalysis...");
  const SocialAnalysis = await ethers.getContractFactory("SocialAnalysis");
  const socialAnalysis = await SocialAnalysis.deploy(dToken.address);
  await socialAnalysis.deployed();
  console.log("✅ SocialAnalysis deployed to:", socialAnalysis.address);

  // Deploy Tokenomics
  console.log("\n📊 Deploying Tokenomics...");
  const Tokenomics = await ethers.getContractFactory("Tokenomics");
  const tokenomics = await Tokenomics.deploy(dToken.address);
  await tokenomics.deployed();
  console.log("✅ Tokenomics deployed to:", tokenomics.address);

  // Deploy Monitoring
  console.log("\n⚡ Deploying Monitoring...");
  const Monitoring = await ethers.getContractFactory("Monitoring");
  const monitoring = await Monitoring.deploy(dToken.address);
  await monitoring.deployed();
  console.log("✅ Monitoring deployed to:", monitoring.address);

  // Deploy Universal
  console.log("\n🌐 Deploying Universal...");
  const Universal = await ethers.getContractFactory("Universal");
  const universal = await Universal.deploy(dToken.address);
  await universal.deployed();
  console.log("✅ Universal deployed to:", universal.address);

  // Authorize all contracts to use DToken
  console.log("\n🔐 Authorizing contracts...");
  await dToken.authorizeContract(domainManagement.address, true);
  await dToken.authorizeContract(contractAnalysis.address, true);
  await dToken.authorizeContract(socialAnalysis.address, true);
  await dToken.authorizeContract(tokenomics.address, true);
  await dToken.authorizeContract(monitoring.address, true);
  await dToken.authorizeContract(universal.address, true);
  console.log("✅ All contracts authorized");

  // Save contract addresses
  const contractAddresses = {
    DToken: dToken.address,
    ContractAnalysis: contractAnalysis.address,
    Tokenomics: tokenomics.address,
    SocialAnalysis: socialAnalysis.address,
    Monitoring: monitoring.address,
    Universal: universal.address,
    DomainManagement: domainManagement.address,
    Network: {
      name: "Doma Testnet",
      rpcUrl: "https://rpc-testnet.doma.xyz",
      chainId: 9747,
      currency: "ETH",
      explorer: "https://explorer-testnet.doma.xyz",
      bridge: "https://bridge-testnet.doma.xyz"
    }
  };

  const addressesPath = path.join(__dirname, "../contract-addresses.json");
  fs.writeFileSync(addressesPath, JSON.stringify(contractAddresses, null, 2));
  
  console.log("\n🎉 Deployment Summary:");
  console.log("====================");
  console.log("DToken:", dToken.address);
  console.log("ContractAnalysis:", contractAnalysis.address);
  console.log("SocialAnalysis:", socialAnalysis.address);
  console.log("Tokenomics:", tokenomics.address);
  console.log("Monitoring:", monitoring.address);
  console.log("Universal:", universal.address);
  console.log("DomainManagement:", domainManagement.address);
  console.log("\nNetwork: Doma Testnet (Chain ID: 9747)");
  console.log("Feature Cost: 0.0001 ETH per feature");
  console.log("Contract addresses saved to:", addressesPath);
  
  console.log("\n📋 Next Steps:");
  console.log("1. Update frontend constants with new contract addresses");
  console.log("2. Test all features with 0.0001 ETH payments");
  console.log("3. Verify contracts on Doma explorer");
  console.log("4. Update documentation");
  
  console.log("\n✅ DomaGuardian deployment completed successfully!");
}

main().catch((error) => {
  console.error("❌ Deployment failed:", error);
  process.exitCode = 1;
});
