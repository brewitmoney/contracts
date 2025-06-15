# Brewit Badges

A Solidity smart contract system for managing soulbound badges/tokens with advanced minting and rendering capabilities.

## Overview

Brewit Badges is a smart contract system that implements ERC1155 tokens with soulbound functionality. The system includes:

- `BrewitBadge`: The main ERC1155 token contract with soulbound functionality
- `BadgeMinter`: A contract for managing badge minting with signature verification
- `BasicRenderer`: A flexible token URI renderer for badge metadata

## Features

- **Soulbound Tokens**: Badges cannot be transferred once minted
- **Signature-based Minting**: Secure minting process using EIP-712 signatures
- **Flexible Rendering**: Customizable token URI generation
- **Role-based Access Control**: Granular permission management
- **Deployment Scripts**: Ready-to-use deployment scripts for multiple networks

## Smart Contracts

### BrewitBadge

The main token contract that implements ERC1155 with soulbound functionality. Key features:
- Soulbound tokens (non-transferable)
- Role-based access control
- Customizable token rendering
- Contract URI management

### BadgeMinter

A contract that handles the minting process with signature verification:
- EIP-712 signature verification
- Configurable signer address
- Owner-only signer management

### BasicRenderer

A flexible renderer contract for token URIs:
- Base URI configuration
- Custom token URI overrides
- URI suffix support
- Owner-only configuration

## Development

### Prerequisites

- [Foundry](https://getfoundry.sh/)
- Node.js (for development tools)

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd brewit-badges
```

2. Install dependencies:
```bash
forge install
```

3. Create a `.env` file with your configuration:
```env
PRIVATE_KEY=your_private_key
```

### Testing

Run the test suite:
```bash
forge test
```

### Deployment

Deploy to a network:
```bash
forge script script/Deploy.s.sol --rpc-url <RPC_URL> --broadcast
```

## License

MIT License

## Security

This project is in active development. Use at your own risk. 