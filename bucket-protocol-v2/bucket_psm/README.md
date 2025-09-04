# Bucket PSM (Peg Stability Module)

A decentralized peg stability module that provides 1:1 exchange services between stablecoins and USDB, maintaining price stability through bidirectional swaps with configurable fees and price protection mechanisms.

## Project Overview

The Bucket PSM enables users to swap between various stablecoins (USDC, USDT, etc.) and USDB at a 1:1 ratio, providing liquidity and maintaining the USDB peg. The module features:

- **Bidirectional Exchange**: Asset ↔ USDB swaps with configurable fees
- **Price Protection**: Deviation detection with configurable tolerance
- **Partner Fee System**: Preferential rates for specific partners
- **Multi-Asset Support**: Support for stablecoins with different decimal precisions
- **Treasury Integration**: Automatic fee collection and supply management

## Architecture Design

### Core Components

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Pool<T>       │    │   Treasury      │    │   Oracle        │
│                 │    │                 │    │                 │
│ - Asset Balance │◄──►│ - USDB Supply   │    │ - Price Feed    │
│ - Fee Config    │    │ - Fee Collection│    │ - Tolerance     │
│ - Price Check   │    │ - Mint/Burn     │    │ - Validation    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │  Swap Functions │
                    │                 │
                    │ - swap_in()     │
                    │ - swap_out()    │
                    └─────────────────┘
```

### Security Architecture

- **Witness Pattern**: Secure inter-module communication using `BucketV2PSM` witness
- **Version Control**: Prevents incompatible module updates
- **Price Validation**: Real-time price deviation checks
- **Access Control**: AdminCap permissions for configuration changes
- **Balance Tracking**: Dual balance tracking for accuracy

## Core Module Structure

```
bucket_psm/
├── sources/
│   ├── pool.move          # Main PSM pool logic
│   ├── events.move        # Event definitions
│   ├── witness.move       # Witness pattern implementation
│   ├── version.move       # Version control
│   └── memo.move          # Transaction memos
├── tests/
│   └── bucket_v2_psm_tests.move
├── Move.toml
└── README.md
```

## Dependencies

### Direct Dependencies
- **BucketV2USD**: Treasury management, USDB minting/burning
- **BucketV2Oracle**: Price feed validation and aggregation
- **BucketV2Framework**: Core utilities (Float, Account, Sheet)

### Dependency Graph
```
BucketV2PSM
├── BucketV2USD
│   └── BucketV2Framework
├── BucketV2Oracle
│   └── BucketV2Framework
└── Sui Framework
```

## Detailed Module Analysis

### Pool Module (`pool.move`)

The core module managing PSM pools for different assets.

#### Key Structures

```move
public struct Pool<phantom T> has key, store {
    id: UID,
    decimal: u8,                                    // Asset decimal precision
    default_fee_config: FeeConfig,                  // Default fee rates
    partner_fee_configs: VecMap<address, FeeConfig>, // Partner-specific rates
    price_tolerance: Float,                         // Price deviation tolerance
    balance: Balance<T>,                           // Asset reserves
    balance_amount: u64,                           // Cached balance amount
    usdb_supply: u64,                             // USDB supply from this pool
    sheet: Sheet<T, BucketV2PSM>,                 // Credit/debt tracking
}

public struct FeeConfig has copy, drop, store {
    swap_in_fee_rate: Float,    // Fee for asset → USDB
    swap_out_fee_rate: Float,   // Fee for USDB → asset
}
```

#### Core Functions

**Administrative Functions:**
- `new<T>()`: Create new PSM pool
- `create<T>()`: Create and share PSM pool
- `set_fee_config<T>()`: Update fee configuration
- `set_price_tolerance<T>()`: Update price tolerance

**Swap Functions:**
- `swap_in<T>()`: Exchange asset for USDB
- `swap_out<T>()`: Exchange USDB for asset

**Getter Functions:**
- `decimal<T>()`: Get asset decimal precision
- `conversion_rate<T>()`: Get asset to USDB conversion rate
- `balance<T>()`: Get current asset balance
- `usdb_supply<T>()`: Get USDB supply from pool

#### Conversion Logic

The module handles different decimal precisions automatically:

```move
public fun conversion_rate<T>(pool: &Pool<T>): Float {
    let usdb_decimal = usdb_decimal();
    if (usdb_decimal >= pool.decimal) {
        float::ten().pow((usdb_decimal - pool.decimal) as u64)
    } else {
        float::one().div(
            float::ten().pow((pool.decimal - usdb_decimal) as u64)
        )
    }
}
```

### Events Module (`events.move`)

Comprehensive event system for monitoring and analytics.

#### Event Structures

```move
public struct NewPsmPool has copy, drop {
    pool_id: ID,
    coin_type: String,
    decimal: u8,
    swap_in_fee_bps: u64,
    swap_out_fee_bps: u64,
}

public struct PsmSwapIn<phantom T> has copy, drop {
    asset_in_amount: u64,
    asset_balance: u64,
    usdb_out_amount: u64,
    usdb_supply: u64,
}

public struct PsmSwapOut<phantom T> has copy, drop {
    usdb_in_amount: u64,
    usdb_supply: u64,
    asset_out_amount: u64,
    asset_balance: u64,
}
```

### Version Module (`version.move`)

Ensures compatibility between PSM and Treasury modules.

```move
const PACKAGE_VERSION: u16 = 1;

public(package) fun assert_valid_package(treasury: &Treasury) {
    treasury.assert_valid_module_version<BucketV2PSM>(package_version());
}
```

### Memo Module (`memo.move`)

Provides standardized transaction memos for fee collection.

```move
public fun swap_in(): String { b"psm_swap_in".to_string() }
public fun swap_out(): String { b"psm_swap_out".to_string() }
```

## Events

### Pool Creation
- **NewPsmPool**: Emitted when a new PSM pool is created
  - `pool_id`: Unique pool identifier
  - `coin_type`: Asset type string
  - `decimal`: Asset decimal precision
  - `swap_in_fee_bps`: Swap in fee in basis points
  - `swap_out_fee_bps`: Swap out fee in basis points

### Swap Operations
- **PsmSwapIn**: Emitted on asset → USDB swaps
  - `asset_in_amount`: Amount of asset deposited
  - `asset_balance`: Pool's asset balance after swap
  - `usdb_out_amount`: Amount of USDB minted
  - `usdb_supply`: Total USDB supply from pool

- **PsmSwapOut**: Emitted on USDB → asset swaps
  - `usdb_in_amount`: Amount of USDB burned
  - `usdb_supply`: Total USDB supply from pool after burn
  - `asset_out_amount`: Amount of asset withdrawn
  - `asset_balance`: Pool's asset balance after swap

## Error Codes

### Pool Module Errors

| Code | Constant | Description |
|------|----------|-------------|
| 401 | `EPoolNotEnough` | Insufficient pool balance for swap out |
| 402 | `EFluctuatingPrice` | Price deviation exceeds tolerance |

### Error Handling

```move
const EPoolNotEnough: u64 = 401;
fun err_pool_not_enough() { abort EPoolNotEnough }

const EFluctuatingPrice: u64 = 402;
fun err_fluctuating_price() { abort EFluctuatingPrice }
```

## Implementation

### Swap In Process (Asset → USDB)

1. **Price Validation**: Check price deviation within tolerance
2. **Fee Calculation**: Apply swap in fee rate
3. **Asset Collection**: Add asset to pool balance
4. **USDB Minting**: Mint USDB through Treasury
5. **Fee Collection**: Split and collect fees
6. **Event Emission**: Emit PsmSwapIn event

```move
public fun swap_in<T>(
    pool: &mut Pool<T>,
    treasury: &mut Treasury,
    price: &PriceResult<T>,
    asset_coin: Coin<T>,
    partner: &Option<AccountRequest>,
    ctx: &mut TxContext,
): Coin<USDB>
```

### Swap Out Process (USDB → Asset)

1. **Price Validation**: Check price deviation within tolerance
2. **USDB Burning**: Burn USDB through Treasury
3. **Asset Calculation**: Calculate asset amount after fees
4. **Balance Check**: Ensure sufficient pool balance
5. **Asset Withdrawal**: Split asset from pool
6. **Fee Collection**: Collect fees in asset
7. **Event Emission**: Emit PsmSwapOut event

```move
public fun swap_out<T>(
    pool: &mut Pool<T>,
    treasury: &mut Treasury,
    price: &PriceResult<T>,
    usdb_coin: Coin<USDB>,
    partner: &Option<AccountRequest>,
    ctx: &mut TxContext,
): Coin<T>
```

### Fee Structure

- **Default Fees**: Applied to all users by default
- **Partner Fees**: Preferential rates for specific addresses
- **Fee Collection**: Automatic collection to Treasury
- **Basis Points**: All fees specified in basis points (1 bp = 0.01%)

### Price Protection

The module includes price protection mechanisms:

```move
fun check_price<T>(pool: &Pool<T>, price: &PriceResult<T>) {
    let price = price.aggregated_price();
    if (price.diff(float::one()).gt(pool.price_tolerance())) {
        err_fluctuating_price();
    };
}
```

## Testnet Deployment

### Package ID
```
0xb818b22a88d614c266c5f4436fb4447dee1c4fba8071c456f864851eb6dd194d
```

### Owned Objects
**UpgradeCap**
```
0xebecfbb39d0e3e4710708ed82c17419efeb6dd48778aa4311f5c09297da517ca
```

## Mainnet Deployment

### Package ID
```
0xc2ae6693383e4a81285136effc8190c7baaf0e75aafa36d1c69cd2170cfc3803
```

### Owned Objects
**UpgradeCap**
```
0x4c7ae4444de9abdd5f18aeedde053172b4bd7ecfb5102832cbe552ebee0fbe8c
```

## Usage Examples

### Creating a PSM Pool

```move
// Create USDC PSM pool with 0.1% swap in fee and 0.2% swap out fee
pool::create<USDC>(
    &treasury,
    &admin_cap,
    6,      // USDC decimals
    10,     // 0.1% swap in fee
    20,     // 0.2% swap out fee
    5,      // 0.05% price tolerance
    ctx,
);
```

### Performing Swaps

```move
// Swap USDC for USDB
let usdb = pool.swap_in(
    &mut treasury,
    &price_result,
    usdc_coin,
    &option::none(), // No partner
    ctx,
);

// Swap USDB for USDC
let usdc = pool.swap_out(
    &mut treasury,
    &price_result,
    usdb_coin,
    &option::none(), // No partner
    ctx,
);
```
