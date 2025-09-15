# Bucket Protocol Interface

A comprehensive decentralized stablecoin protocol built on the Sui blockchain, providing Collateralized Debt Position (CDP) systems, Peg Stability Module (PSM), and various DeFi infrastructure components.

## Overview

Bucket Protocol consists of multiple modules that work together to create a robust stablecoin ecosystem centered around USDB (Bucket USD). The protocol enables users to:

- **Collateralize assets** to mint USDB stablecoin through CDP positions
- **Exchange stablecoins** at 1:1 ratio through PSM pools
- **Earn yields** through saving pools and incentive mechanisms
- **Build custom DeFi applications** using the framework components

## Repository Structure

```
bucket-interface/
├── bucket-protocol/         # Legacy v1 protocol (archived)
├── bucket-protocol-v2/      # Core v2 protocol modules
│   ├── bucket_framework/    # Basic framework and utilities
│   ├── bucket_usd/         # USDB stablecoin core
│   ├── bucket_oracle/      # Decentralized oracle system
│   ├── bucket_cdp/         # Collateralized Debt Positions
│   ├── bucket_psm/         # Peg Stability Module
│   ├── bucket_saving/      # Saving pools
│   ├── bucket_flash/       # Flash loan functionality
│   └── bucket_incentives/  # Incentive mechanisms
├── framework/              # Shared framework utilities
└── examples/               # Integration examples and plugins
    └── saving_plugins/     # Example saving pool plugins
```

## Core Components

### 🏗️ Bucket Framework
**Location:** `framework/` & `bucket-protocol-v2/bucket_framework/`

Provides fundamental building blocks:
- **Precision Math**: Float (9-decimal) and Double (18-decimal) arithmetic
- **Account System**: Account abstraction with alias support
- **Liability Management**: Credit/Debt structures with automatic settlement
- **Data Structures**: LinkedTable, access control mechanisms

### 💰 USDB Stablecoin (`bucket_usd`)
**Core stablecoin module managing:**
- Treasury operations and supply control
- Modular issuance permissions
- Fee collection and distribution
- Cross-module integration

### 🔮 Oracle System (`bucket_oracle`)
**Decentralized price aggregation:**
- Multi-source price collection
- Weighted average calculations
- Outlier detection and filtering
- Real-time price feeds

### 🏦 CDP System (`bucket_cdp`)
**Collateralized borrowing platform:**
- Multi-collateral vault support
- Interest rate calculations
- Liquidation mechanisms
- Position management

### 🔄 PSM - Peg Stability Module (`bucket_psm`)
**1:1 stablecoin exchange:**
- Bidirectional swapping (Asset ↔ USDB)
- Dynamic fee structures
- Price deviation protection
- Partner rate configurations

### 💸 Saving Pools (`bucket_saving`)
**Yield-generating deposits:**
- USDB staking mechanisms
- Reward distribution
- Plugin architecture for extensions

### ⚡ Flash Loans (`bucket_flash`)
**Instant liquidity access:**
- Zero-collateral borrowing
- Atomic transaction requirements
- Fee-based revenue model

### 🎁 Incentive Systems (`bucket_incentives`)
**Reward mechanisms:**
- Borrowing incentives
- Saving rewards
- Loyalty programs

## Getting Started

### Prerequisites

- [Sui CLI](https://docs.sui.io/build/install) installed
- Basic understanding of Move programming language
- Testnet/Mainnet SUI tokens for deployment

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-org/bucket-interface
   cd bucket-interface
   ```

2. **Install dependencies:**
   Each module has its own `Move.toml` with specific dependencies. Navigate to any module and run:
   ```bash
   sui move build
   ```

### Deployment

The protocol should be deployed in the following order:

1. **Framework Foundation:**
   ```bash
   cd framework
   sui move publish
   ```

2. **Core Protocol (v2):**
   ```bash
   cd bucket-protocol-v2/bucket_framework
   sui move publish

   cd ../bucket_usd
   sui move publish

   cd ../bucket_oracle
   sui move publish

   cd ../bucket_cdp
   sui move publish

   cd ../bucket_psm
   sui move publish
   ```

3. **Additional Modules:**
   Deploy saving, flash, and incentive modules as needed.

## Usage Examples

### CDP Borrowing
```move
// Create a collateral deposit request
let deposit = coin::mint_for_testing<SUI>(1000_000_000_000, ctx); // 1000 SUI
let request = vault.debtor_request(
    &account_req,
    &treasury,
    deposit,
    500_000_000,    // borrow 500 USDB
    repayment,
    0,              // withdraw 0
);

// Update position
let (coll_out, usdb_out, response) = vault.update_position(
    &mut treasury,
    &clock,
    &price_option,
    request,
    ctx,
);
```

### PSM Exchange
```move
// Exchange USDC for USDB
let usdc_coin = coin::mint_for_testing<USDC>(1000_000_000, ctx);
let price = price_result::new_for_testing<USDC>(float::from_bps(10000));

let usdb_out = pool.swap_in(
    &mut treasury,
    &price,
    usdc_coin,
    &option::none(), // no partner fee
    ctx,
);
```

## Development

### Building Plugins

The framework supports custom plugin development. See the [saving plugins example](examples/saving_plugins/READEME.md) for a comprehensive integration guide.

**Key patterns:**
- Version management for upgrades
- Witness pattern for secure extensions
- Event emission for transparency
- Access control with admin capabilities

### Testing

Run tests for any module:
```bash
cd bucket-protocol-v2/[module-name]
sui move test
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Implement changes with tests
4. Submit a pull request

## Security

The protocol implements multiple security layers:

- **Access Control**: AdminCap and witness patterns
- **Economic Security**: Collateral ratio checks, supply limits
- **Technical Security**: Reentrancy protection, precision controls
- **Oracle Security**: Outlier filtering, weighted aggregation

## Network Addresses

### Mainnet
- **Framework**: `0x00db9a10bb9536ab367b7d1ffa404c1d6c55f009076df1139dc108dd86608bbe`
- **Protocol v1**: `0xce7ff77a83ea0cb6fd39bd8748e2ec89a3f41e8efdc3f4eb123e0ca37b184db2`

### Testnet
See individual module `Move.toml` files for testnet addresses.

## Documentation

- **Technical Documentation**: [bucket-protocol-v2/README.md](bucket-protocol-v2/README.md)
- **Integration Guide**: [examples/saving_plugins/READEME.md](examples/saving_plugins/READEME.md)
- **API Reference**: Generated from source code comments

## License

[Specify your license here]

## Support

- **Issues**: Report bugs via GitHub Issues
- **Discussions**: Community discussions on GitHub Discussions
- **Documentation**: Comprehensive guides in `/docs`

---

**Built with ❤️ on Sui Blockchain**