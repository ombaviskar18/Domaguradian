// DomaGuardian Contract Addresses on Doma Testnet
export const DOMA_GUARDIAN_CONTRACTS = {
	DToken: '0x6F8f19d73EDFD192Fa7A93D83CD1145CFDC50B32',
	ContractAnalysis: '0xE623c001F28811F72aa024BF9608a59c5e66720d',
	Tokenomics: '0xC71F50AbCb258D800E9Ad52c4A93DA0BcAB294E0',
	SocialAnalysis: '0xa7f984BF6Cb376AC8Fb6A58aA6F65d7F940fFFea',
	Monitoring: '0x4aA7B747Ed35B358B62fc9e13F8aCC696e517477',
	Universal: '0xdb5fC412a5515033265Dc9e8d383f9C2b551c747',
} as const;

// Legacy export for backward compatibility
export const HELLO_UNIVERSAL_CONTRACT_ADDRESS = DOMA_GUARDIAN_CONTRACTS.Universal;
