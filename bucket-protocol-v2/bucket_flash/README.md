# Bucket Flash

Flash loan module for USDB providing temporary borrowing without collateral requirements.

## Project Overview

The Bucket Flash module enables flash loans of USDB tokens, allowing users to borrow large amounts temporarily within a single transaction. This is useful for arbitrage, liquidations, and other DeFi strategies that require temporary capital without upfront collateral.

### Key Features
- **Flash Loans**: Borrow USDB without collateral, must be repaid in same transaction
- **Partner System**: Preferential rates for specific partners
- **Fee Collection**: Configurable fees for flash loan operations
- **Security Controls**: Version control and access management
- **Hot Potato Pattern**: Ensures loans are repaid through `FlashMintReceipt`

## Architecture Design

### Core Components
1. **GlobalConfig**: Central configuration for flash loan parameters
2. **FlashMintReceipt**: Hot potato struct ensuring loan repayment
3. **Partner System**: Differentiated pricing for partners vs default users
4. **Treasury Integration**: Direct integration with USDB treasury for minting/burning

### Security Model
- **Hot Potato Pattern**: `FlashMintReceipt` must be consumed in same transaction
- **Amount Limits**: Maximum borrowing limits per configuration
- **Fee Enforcement**: Mandatory fee payment on loan repayment
- **Version Control**: Prevents incompatible module interactions

## Core Module Structure

```
bucket_flash/
├── sources/
│   ├── config.move          # Main flash loan logic and configuration
│   ├── events.move          # Event definitions
│   ├── memo.move            # Transaction memos
│   ├── version.move         # Version management
│   └── witness.move         # Witness pattern implementation
├── tests/
│   └── bucket_v2_flash_tests.move  # Comprehensive test suite
└── Move.toml               # Package configuration
```

## Dependencies

### Direct Dependencies
- **BucketV2USD**: USDB treasury integration for minting/burning
- **BucketV2Framework**: Core utilities (float math, account system)
- **Sui Framework**: Standard Sui blockchain functionality

### Dependency Graph
```
BucketV2Flash
├── BucketV2USD
│   └── BucketV2Framework
│       └── Sui Framework
└── Sui Framework
```

## Detailed Module Analysis

### config.move
**Primary Module**: Contains all flash loan logic and configuration management.

#### Key Structures
```move
public struct GlobalConfig has key {
    id: UID,
    default_config: Config,
    partner_configs: VecMap<address, Config>,
}

public struct Config has copy, drop, store {
    fee_rate: Float,      // Fee rate in basis points
    max_amount: u64,      // Maximum borrowable amount
    total_amount: u64,    // Currently borrowed amount
}

public struct FlashMintReceipt {
    partner: Option<address>,
    mint_amount: u64,
    fee_amount: u64,
}
```

#### Core Functions

**Admin Functions**
- `set_flash_config()`: Configure flash loan parameters for default or partner accounts

**Public Functions**
- `flash_mint()`: Borrow USDB tokens, returns coin and receipt
- `flash_burn()`: Repay loan with fees, consumes receipt

**View Functions**
- `config()`: Get configuration for partner or default
- `fee_rate()`, `max_amount()`, `total_amount()`: Individual parameter getters

### events.move
**Event System**: Comprehensive event logging for monitoring and analytics.

#### Event Structures
```move
public struct UpdateFlashMintConfig has copy, drop {
    config_id: ID,
    partner_address: Option<address>,
    fee_rate_bps: u64,
    max_amount: u64,
}

public struct FlashMint has copy, drop {
    partner_address: Option<address>,
    value: u64,
    fee_amount: u64,
}
```

### witness.move
**Security Pattern**: Implements witness pattern for secure treasury interactions.

### version.move
**Version Control**: Manages package version for compatibility checks.

### memo.move
**Transaction Memos**: Provides standardized memo strings for treasury operations.

## Events

### UpdateFlashMintConfig
Emitted when flash loan configuration is updated.
- `config_id`: GlobalConfig object ID
- `partner_address`: Partner address (None for default config)
- `fee_rate_bps`: Fee rate in basis points
- `max_amount`: Maximum borrowable amount

### FlashMint
Emitted when flash loan is initiated.
- `partner_address`: Borrower's partner address (if applicable)
- `value`: Amount borrowed
- `fee_amount`: Fee to be paid on repayment

## Error Codes

### EExceedMaxAmount (401)
**Trigger**: When requested flash loan amount exceeds configured maximum
**Resolution**: Reduce loan amount or increase max_amount configuration

### ERepaymentNotEnough (402)
**Trigger**: When repayment amount is less than borrowed amount plus fees
**Resolution**: Ensure repayment includes exact borrowed amount plus calculated fees

## Implementation

### Flash Loan Flow

1. **Initiation**
   ```move
   let (usdb_coin, receipt) = config.flash_mint(
       &mut treasury,
       &partner_request,
       amount,
       ctx
   );
   ```

2. **Usage**
   - Use borrowed USDB for intended operations
   - Must complete all operations within same transaction

3. **Repayment**
   ```move
   config.flash_burn(
       &mut treasury,
       repayment_coin,  // amount + fees
       receipt
   );
   ```

### Partner Configuration

Partners can receive preferential rates:
```move
// Set partner-specific configuration
config.set_flash_config(
    &admin_cap,
    option::some(partner_address),
    fee_rate_bps,
    max_amount
);
```

### Fee Calculation

Fees are calculated using float math:
```move
let fee_amount = float::from(value).mul(config.fee_rate).ceil();
```

### Integration Example

```move
public fun arbitrage_example(
    config: &mut GlobalConfig,
    treasury: &mut Treasury,
    // ... other parameters
) {
    // 1. Flash mint USDB
    let (usdb, receipt) = config.flash_mint(
        treasury,
        &option::none(),
        1000000, // 1M USDB
        ctx
    );

    // 2. Perform arbitrage operations
    let profit = perform_arbitrage(usdb);

    // 3. Repay with fees
    let fee = receipt.fee_amount();
    let repayment = coin::split(&mut profit, 1000000 + fee, ctx);

    config.flash_burn(treasury, repayment, receipt);

    // 4. Keep remaining profit
    transfer::public_transfer(profit, sender);
}
```

## Testnet Deployments

### Package Information
- **Package ID**: `0x68d88be9921bd6730a0f1cdfc200a7e9dda6b3e862c0245cd3891511671bcb8c`
- **Version**: 1
- **Chain**: Sui Testnet (4c78adac)

### Shared Objects
- **GlobalConfig**: `0x66c8c42e1ccf2a8eaa50f2584b990418c54349f53470004545e12333ccf1f0fc`
- **UpgradeCap**: `0x6b0163fea28551ca5e95eeaa234885d3e16c2bae32f8c18175b4b22b127f0747`

## Mainnet Deployments
Package ID
```
0x0f51f9eb63574a1d12b62295599ac4f8231197f95b3cce9a516daba64f419d06
```
GlobalConfig `610893688`
```
0x4cbc26a7ec49d4bec975768af386cc6ab987a1c29d524566f99d5aa018a99546
```
UpgradeCap
```
0xb88247cf76313bfad3828d7c16fdf6561e5b683992e0315685ea045f03786e27
```
