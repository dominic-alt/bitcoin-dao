# BitcoinDAO - Next-Generation Autonomous Governance Protocol

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Clarity](https://img.shields.io/badge/Clarity-3.0-brightgreen.svg)](https://clarity-lang.org/)
[![Stacks](https://img.shields.io/badge/Stacks-Blockchain-orange.svg)](https://www.stacks.co/)

## 🚀 Overview

BitcoinDAO harnesses Bitcoin's battle-tested security architecture to power sophisticated autonomous organizations through Stacks Layer 2 smart contracts, delivering unmatched governance integrity for the decentralized economy.

BitcoinDAO represents a paradigm shift in decentralized governance, establishing the first truly Bitcoin-secured autonomous organization framework. This protocol combines the immutable foundation of Bitcoin with advanced governance mechanics to create organizations that are:

- **Quantum-resistant** through Bitcoin's proven cryptographic foundation
- **Economically incentivized** with reputation-weighted decision making
- **Democratically fair** using quadratic voting mechanisms
- **Cross-chain compatible** for multi-ecosystem collaboration
- **Treasury-optimized** with automated fund management
- **Community-driven** with anti-centralization safeguards

Unlike traditional DAOs that rely on potentially vulnerable consensus mechanisms, BitcoinDAO anchors every governance decision to Bitcoin's unbreachable ledger, ensuring that organizational integrity scales with Bitcoin's own security guarantees.

## ✨ Key Features

### 🏛️ Governance

- **Quadratic Voting**: Reputation and stake-weighted voting system
- **Proposal Management**: Create, vote, and execute governance proposals
- **Time-bounded Voting**: 10-day voting periods with automatic expiration
- **Anti-double Voting**: Built-in mechanisms to prevent vote manipulation

### 👥 Membership System

- **Dynamic Membership**: Join/leave DAO functionality
- **Reputation Scoring**: Merit-based reputation system with decay mechanics
- **Staking Mechanism**: Stake STX tokens to increase governance weight
- **Activity Tracking**: Last interaction monitoring for member engagement

### 💰 Treasury Management

- **Secure Fund Management**: Multi-signature treasury operations
- **Donation System**: Community funding with reputation rewards
- **Automated Execution**: Smart contract-based fund distribution
- **Balance Tracking**: Real-time treasury balance monitoring

### 🤝 Cross-DAO Collaboration

- **Partnership Framework**: Propose and accept collaborations with other DAOs
- **Interoperability**: Cross-chain governance capabilities
- **Collaborative Proposals**: Joint decision-making across organizations

### 🔒 Security Features

- **Bitcoin-anchored Security**: Every decision backed by Bitcoin's immutability
- **Access Control**: Role-based authorization system
- **Anti-centralization**: Built-in safeguards against governance attacks
- **Comprehensive Error Handling**: Robust error codes and validation

## 🏗️ Architecture

### Smart Contract Structure

```
contracts/
└── bitcoin-dao.clar          # Main DAO contract with full functionality

Data Maps:
├── members                   # Member registry with reputation & stake
├── proposals                 # Governance proposals with metadata
├── votes                     # Vote tracking to prevent double voting
└── collaborations           # Cross-DAO partnership management
```

### Core Functions

#### Membership Functions

- `join-dao()` - Become a DAO member
- `leave-dao()` - Exit the DAO
- `stake-tokens(amount)` - Stake STX for voting power
- `unstake-tokens(amount)` - Withdraw staked tokens

#### Governance Functions

- `create-proposal(title, description, amount)` - Submit new proposals
- `vote-on-proposal(proposal-id, vote)` - Cast weighted votes
- `execute-proposal(proposal-id)` - Execute passed proposals

#### Treasury Functions

- `donate-to-treasury(amount)` - Contribute funds to DAO
- `get-treasury-balance()` - Check current treasury status

#### Collaboration Functions

- `propose-collaboration(partner-dao, proposal-id)` - Initiate partnerships
- `accept-collaboration(collaboration-id)` - Accept partnership proposals

## 🛠️ Development Setup

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) (latest version)
- [Node.js](https://nodejs.org/) (v18 or higher)
- [Git](https://git-scm.com/)

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/dominic-alt/bitcoin-dao.git
   cd bitcoin-dao
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Check contract syntax**

   ```bash
   clarinet check
   ```

4. **Run tests**

   ```bash
   npm test
   ```

### Project Structure

```
bitcoin-dao/
├── contracts/
│   └── bitcoin-dao.clar      # Main smart contract
├── tests/
│   └── bitcoin-dao.test.ts   # Test suite
├── settings/
│   ├── Devnet.toml          # Development network settings
│   ├── Testnet.toml         # Testnet configuration
│   └── Mainnet.toml         # Mainnet configuration
├── Clarinet.toml            # Clarinet project configuration
├── package.json             # Node.js dependencies
└── README.md               # This file
```

## 🧪 Testing

The project uses Vitest for comprehensive testing with the Clarinet SDK.

### Running Tests

```bash
# Run all tests
npm test

# Run tests with coverage
npm run test:report

# Watch mode for development
npm run test:watch
```

### Test Coverage

- ✅ Membership management
- ✅ Proposal creation and voting
- ✅ Treasury operations
- ✅ Access control validation
- ✅ Error handling
- ✅ Cross-DAO collaboration

## 📊 Usage Examples

### Joining the DAO

```clarity
;; Join as a new member
(contract-call? .bitcoin-dao join-dao)
```

### Creating a Proposal

```clarity
;; Create a funding proposal
(contract-call? .bitcoin-dao create-proposal 
  "Fund Development Team" 
  "Allocate 1000 STX for Q4 development milestones"
  u1000000000) ;; 1000 STX in microSTX
```

### Voting on Proposals

```clarity
;; Vote YES on proposal #1
(contract-call? .bitcoin-dao vote-on-proposal u1 true)

;; Vote NO on proposal #1
(contract-call? .bitcoin-dao vote-on-proposal u1 false)
```

### Staking for Governance Weight

```clarity
;; Stake 100 STX to increase voting power
(contract-call? .bitcoin-dao stake-tokens u100000000)
```

## 🌐 Deployment

### Local Development (Devnet)

```bash
clarinet integrate
```

### Testnet Deployment

1. Configure your testnet settings in `settings/Testnet.toml`
2. Deploy using Clarinet:

   ```bash
   clarinet deploy --testnet
   ```

### Mainnet Deployment

1. Configure your mainnet settings in `settings/Mainnet.toml`
2. Deploy using Clarinet:

   ```bash
   clarinet deploy --mainnet
   ```

## 🔧 Configuration

### Network Settings

Edit the appropriate configuration file in the `settings/` directory:

- `Devnet.toml` - Local development
- `Testnet.toml` - Stacks testnet
- `Mainnet.toml` - Stacks mainnet

### Contract Parameters

Key constants that can be modified before deployment:

```clarity
;; Voting period (currently 10 days = 1440 blocks)
(+ stacks-block-height u1440)

;; Reputation decay threshold (currently 30 days = 4320 blocks)
u4320

;; Initial reputation for new members
u1
```

## 🔐 Security Considerations

### Audit Status

- ⚠️ **Not yet audited** - This contract is under development
- 🔍 **Self-reviewed** - Internal security review completed
- 📋 **Test coverage** - Comprehensive unit tests implemented

### Known Security Features

- **Reentrancy Protection**: Uses Clarity's built-in protections
- **Integer Overflow Protection**: Clarity prevents overflow attacks
- **Access Control**: Role-based function restrictions
- **Input Validation**: Comprehensive parameter checking

### Recommendations

- Conduct professional security audit before mainnet deployment
- Implement timelock for critical governance changes
- Monitor for unusual voting patterns
- Regular reputation decay for inactive members

## 🤝 Contributing

We welcome contributions from the community! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass (`npm test`)
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

### Code Style

- Follow Clarity best practices
- Use descriptive function and variable names
- Add comprehensive comments
- Include error handling for all edge cases

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- [Stacks Blockchain](https://www.stacks.co/)
- [Clarity Language](https://clarity-lang.org/)
- [Clarinet Documentation](https://docs.hiro.so/clarinet)
- [Stacks Developer Resources](https://docs.stacks.co/)

## 🗺️ Roadmap

### Phase 1: Core Functionality ✅

- [x] Basic membership management
- [x] Proposal creation and voting
- [x] Treasury management
- [x] Reputation system

### Phase 2: Advanced Features 🚧

- [ ] Delegation mechanisms
- [ ] Multi-signature proposals
- [ ] Advanced analytics dashboard
- [ ] Mobile interface

### Phase 3: Ecosystem Integration 📋

- [ ] Cross-chain bridging
- [ ] DeFi protocol integrations
- [ ] NFT governance tokens
- [ ] DAO-to-DAO communication protocol
