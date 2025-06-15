# Brewit Contracts

A collection of smart contracts for the Brewit platform, including badge management, smart sessions, and WebAuthn validation.

## Overview

This repository contains several key components:

1. **Badges System**
   - ERC1155-based soulbound badges
   - Signature-based minting
   - Flexible token rendering
   - Role-based access control

2. **Smart Sessions**
   - ERC-7579 compatible smart account sessions
   - Granular control over session keys
   - Support for various policy types
   - Integration with external policy contracts

3. **WebAuthn Validators**
   - WebAuthn2/FIDO2 authentication
   - ECDSA P256 optimization
   - FreshCryptoLib integration

## Project Structure

## Development

### Prerequisites

- [Foundry](https://getfoundry.sh/)
- Node.js
- [SageMath](https://www.sagemath.org/) (for WebAuthn validators)

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd brewit-contracts
```

2. Install dependencies:
```bash
forge install
```

3. Create a `.env` file with your configuration:
```env
PRIVATE_KEY=your_private_key
API_KEY_ALCHEMY=your_alchemy_key
ETHERSCAN_API_KEY=your_etherscan_key
# Add other API keys as needed
```

### Testing

Run tests for all components:
```bash
forge test
```

Run tests for specific components:
```bash
# Badges
cd badges && forge test

# Smart Sessions
cd smartsessions && forge test

# WebAuthn Validators
cd validators/webauthn && forge test
```

### Deployment

Deploy to a network:
```bash
forge script script/Deploy.s.sol --rpc-url <RPC_URL> --broadcast
```

## Components

### Badges

The badge system implements ERC1155 tokens with soulbound functionality:
- Non-transferable tokens
- Signature-based minting
- Customizable token rendering
- Role-based access control

### Smart Sessions

Smart session management for ERC-7579 accounts:
- Session key management
- Policy-based access control
- ERC-1271 signature validation
- Batched execution support

### WebAuthn Validators

WebAuthn2/FIDO2 authentication implementation:
- ECDSA P256 optimization
- FreshCryptoLib integration
- Gas-optimized verification
- Comprehensive test coverage

## Security

This project is in active development. Use at your own risk.

## License

MIT License