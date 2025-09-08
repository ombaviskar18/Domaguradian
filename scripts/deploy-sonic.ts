import { ethers } from "hardhat";

async function main() {
  console.log("🚀 Starting SonicGuardian deployment on Sonic Testnet...\n");

  // Get the deployer account
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);
  console.log("Account balance:", ethers.utils.formatEther(await deployer.getBalance()), "S\n");

  // Deploy SToken first
  console.log("📦 Deploying SToken contract...");
  const SToken = await ethers.getContractFactory("SToken");
  const sToken = await SToken.deploy();
  await sToken.deployed();
  console.log("✅ SToken deployed to:", sToken.address);

  // Deploy ContractAnalysis
  console.log("\n📦 Deploying ContractAnalysis contract...");
  const ContractAnalysis = await ethers.getContractFactory("ContractAnalysis");
  const contractAnalysis = await ContractAnalysis.deploy(sToken.address);
  await contractAnalysis.deployed();
  console.log("✅ ContractAnalysis deployed to:", contractAnalysis.address);

  // Deploy Tokenomics
  console.log("\n📦 Deploying Tokenomics contract...");
  const Tokenomics = await ethers.getContractFactory("Tokenomics");
  const tokenomics = await Tokenomics.deploy(sToken.address);
  await tokenomics.deployed();
  console.log("✅ Tokenomics deployed to:", tokenomics.address);

  // Deploy SocialAnalysis
  console.log("\n📦 Deploying SocialAnalysis contract...");
  const SocialAnalysis = await ethers.getContractFactory("SocialAnalysis");
  const socialAnalysis = await SocialAnalysis.deploy(sToken.address);
  await socialAnalysis.deployed();
  console.log("✅ SocialAnalysis deployed to:", socialAnalysis.address);

  // Deploy Monitoring
  console.log("\n📦 Deploying Monitoring contract...");
  const Monitoring = await ethers.getContractFactory("Monitoring");
  const monitoring = await Monitoring.deploy(sToken.address);
  await monitoring.deployed();
  console.log("✅ Monitoring deployed to:", monitoring.address);

  // Deploy Universal
  console.log("\n📦 Deploying Universal contract...");
  const Universal = await ethers.getContractFactory("Universal");
  const universal = await Universal.deploy(sToken.address);
  await universal.deployed();
  console.log("✅ Universal deployed to:", universal.address);

  // Authorize contracts to use S tokens
  console.log("\n🔐 Authorizing contracts to use S tokens...");
  
  await sToken.authorizeContract(contractAnalysis.address, true);
  console.log("✅ ContractAnalysis authorized");

  await sToken.authorizeContract(tokenomics.address, true);
  console.log("✅ Tokenomics authorized");

  await sToken.authorizeContract(socialAnalysis.address, true);
  console.log("✅ SocialAnalysis authorized");

  await sToken.authorizeContract(monitoring.address, true);
  console.log("✅ Monitoring authorized");

  await sToken.authorizeContract(universal.address, true);
  console.log("✅ Universal authorized");

  // Mint some S tokens to deployer for testing
  console.log("\n💰 Minting S tokens to deployer for testing...");
  const mintAmount = ethers.utils.parseEther("1000"); // 1000 S tokens
  await sToken.mint(deployer.address, mintAmount);
  console.log("✅ Minted 1000 S tokens to deployer");

  // Display deployment summary
  console.log("\n" + "=".repeat(60));
  console.log("🎉 DEPLOYMENT COMPLETE!");
  console.log("=".repeat(60));
  console.log("Network: Sonic Testnet (Chain ID: 14601)");
  console.log("RPC URL: https://rpc.testnet.soniclabs.com");
  console.log("Currency: S");
  console.log("\n📋 Contract Addresses:");
  console.log("SToken:", sToken.address);
  console.log("ContractAnalysis:", contractAnalysis.address);
  console.log("Tokenomics:", tokenomics.address);
  console.log("SocialAnalysis:", socialAnalysis.address);
  console.log("Monitoring:", monitoring.address);
  console.log("Universal:", universal.address);
  console.log("\n💡 Next Steps:");
  console.log("1. Update contract-addresses.json with the addresses above");
  console.log("2. Update frontend configuration");
  console.log("3. Test the contracts on Sonic Testnet");
  console.log("=".repeat(60));

  // Save addresses to file
  const addresses = {
    SToken: sToken.address,
    ContractAnalysis: contractAnalysis.address,
    Tokenomics: tokenomics.address,
    SocialAnalysis: socialAnalysis.address,
    Monitoring: monitoring.address,
    Universal: universal.address,
    Network: {
      name: "Sonic Testnet",
      rpcUrl: "https://rpc.testnet.soniclabs.com",
      chainId: 14601,
      currency: "S",
      explorer: "https://testnet.soniclabs.com"
    }
  };

  const fs = require('fs');
  fs.writeFileSync('contract-addresses.json', JSON.stringify(addresses, null, 2));
  console.log("\n💾 Contract addresses saved to contract-addresses.json");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
