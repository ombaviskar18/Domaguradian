import { ethers } from "hardhat";

async function main() {
  console.log("🧪 Testing SonicGuardian contracts...\n");

  // Get the test account
  const [deployer, user1] = await ethers.getSigners();
  console.log("Testing with accounts:");
  console.log("Deployer:", deployer.address);
  console.log("User1:", user1.address);

  // Load contract addresses from the JSON file
  const fs = require('fs');
  const addresses = JSON.parse(fs.readFileSync('contract-addresses.json', 'utf8'));

  console.log("\n📋 Contract Addresses:");
  console.log("SToken:", addresses.SToken);
  console.log("ContractAnalysis:", addresses.ContractAnalysis);
  console.log("Tokenomics:", addresses.Tokenomics);
  console.log("SocialAnalysis:", addresses.SocialAnalysis);
  console.log("Monitoring:", addresses.Monitoring);
  console.log("Universal:", addresses.Universal);

  // Get contract instances
  const SToken = await ethers.getContractFactory("SToken");
  const ContractAnalysis = await ethers.getContractFactory("ContractAnalysis");
  const Tokenomics = await ethers.getContractFactory("Tokenomics");
  const SocialAnalysis = await ethers.getContractFactory("SocialAnalysis");
  const Monitoring = await ethers.getContractFactory("Monitoring");
  const Universal = await ethers.getContractFactory("Universal");

  const sToken = SToken.attach(addresses.SToken);
  const contractAnalysis = ContractAnalysis.attach(addresses.ContractAnalysis);
  const tokenomics = Tokenomics.attach(addresses.Tokenomics);
  const socialAnalysis = SocialAnalysis.attach(addresses.SocialAnalysis);
  const monitoring = Monitoring.attach(addresses.Monitoring);
  const universal = Universal.attach(addresses.Universal);

  console.log("\n🔍 Testing S Token...");
  
  // Test S Token basic functions
  const deployerBalance = await sToken.balanceOf(deployer.address);
  const user1Balance = await sToken.balanceOf(user1.address);
  const totalSupply = await sToken.totalSupply();
  const featureCost = await sToken.getFeatureCost();

  console.log("Deployer S Token balance:", ethers.utils.formatEther(deployerBalance));
  console.log("User1 S Token balance:", ethers.utils.formatEther(user1Balance));
  console.log("Total supply:", ethers.utils.formatEther(totalSupply));
  console.log("Feature cost:", ethers.utils.formatEther(featureCost));

  // Transfer some S tokens to user1 for testing
  console.log("\n💰 Transferring S tokens to user1...");
  const transferAmount = ethers.utils.parseEther("10");
  await sToken.transfer(user1.address, transferAmount);
  console.log("✅ Transferred 10 S tokens to user1");

  // Test contract analysis
  console.log("\n🔍 Testing Contract Analysis...");
  const contractAddress = "0x1234567890123456789012345678901234567890";
  
  try {
    await contractAnalysis.connect(user1).requestContractAnalysis(contractAddress);
    console.log("✅ Contract analysis requested successfully");
  } catch (error) {
    console.log("❌ Contract analysis failed:", error.message);
  }

  // Test tokenomics analysis
  console.log("\n📊 Testing Tokenomics Analysis...");
  const tokenAddress = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd";
  
  try {
    await tokenomics.connect(user1).requestTokenomicsAnalysis(tokenAddress);
    console.log("✅ Tokenomics analysis requested successfully");
  } catch (error) {
    console.log("❌ Tokenomics analysis failed:", error.message);
  }

  // Test social analysis
  console.log("\n📱 Testing Social Analysis...");
  const projectName = "TestProject";
  
  try {
    await socialAnalysis.connect(user1).requestSocialAnalysis(projectName);
    console.log("✅ Social analysis requested successfully");
  } catch (error) {
    console.log("❌ Social analysis failed:", error.message);
  }

  // Test monitoring
  console.log("\n⚡ Testing Monitoring...");
  const targetAddress = "0x9876543210987654321098765432109876543210";
  
  try {
    await monitoring.connect(user1).requestMonitoring(targetAddress);
    console.log("✅ Monitoring requested successfully");
  } catch (error) {
    console.log("❌ Monitoring failed:", error.message);
  }

  // Test universal messaging
  console.log("\n💬 Testing Universal Messaging...");
  const message = "Hello Sonic Network!";
  
  try {
    await universal.connect(user1).sendMessage(message);
    console.log("✅ Message sent successfully");
  } catch (error) {
    console.log("❌ Message sending failed:", error.message);
  }

  // Check final balances
  console.log("\n📊 Final Balances:");
  const finalDeployerBalance = await sToken.balanceOf(deployer.address);
  const finalUser1Balance = await sToken.balanceOf(user1.address);
  
  console.log("Deployer S Token balance:", ethers.utils.formatEther(finalDeployerBalance));
  console.log("User1 S Token balance:", ethers.utils.formatEther(finalUser1Balance));

  // Check contract balances
  console.log("\n🏦 Contract S Token Balances:");
  const contractAnalysisBalance = await sToken.balanceOf(addresses.ContractAnalysis);
  const tokenomicsBalance = await sToken.balanceOf(addresses.Tokenomics);
  const socialAnalysisBalance = await sToken.balanceOf(addresses.SocialAnalysis);
  const monitoringBalance = await sToken.balanceOf(addresses.Monitoring);
  const universalBalance = await sToken.balanceOf(addresses.Universal);

  console.log("ContractAnalysis:", ethers.utils.formatEther(contractAnalysisBalance));
  console.log("Tokenomics:", ethers.utils.formatEther(tokenomicsBalance));
  console.log("SocialAnalysis:", ethers.utils.formatEther(socialAnalysisBalance));
  console.log("Monitoring:", ethers.utils.formatEther(monitoringBalance));
  console.log("Universal:", ethers.utils.formatEther(universalBalance));

  console.log("\n🎉 Contract testing completed!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
