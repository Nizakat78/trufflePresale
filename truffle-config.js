const HDWalletProvider = require('@truffle/hdwallet-provider');

const privateKey = 'Private key here';
const localSepoliaNodeUrl = 'http://localhost:8545'; // URL of your local Sepolia node

module.exports = {
  networks: {
    sepolia: {
      provider: () =>
        new HDWalletProvider(
          privateKey,
          localSepoliaNodeUrl
        ),
      network_id: 11155111, // Sepolia network ID
      gas: 5500000,         // Gas limit
      gasPrice: 20000000000 // Gas price in wei (20 Gwei)
    },
  },
  compilers: {
    solc: {
      version: "0.8.0",    // Solidity compiler version
    },
  },
};
