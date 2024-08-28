const HDWalletProvider = require('@truffle/hdwallet-provider');

const privateKey = '78217cd02474ee4c5b9e9b637898520e6cb4be53beb2b4729c1832fe1c2a504d';
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
