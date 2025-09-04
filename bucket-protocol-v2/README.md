# BucketV2 Protocol Technical Documentation

## Project Overview

BucketV2 is a decentralized stablecoin protocol built on the Sui blockchain, primarily providing Collateralized Debt Position (CDP) systems and Peg Stability Module (PSM). The protocol issues USDB stablecoin, allowing users to borrow stablecoins by collateralizing assets or directly exchange through PSM.

## Architecture Design

### Core Module Structure

```
v2-move-contracts
├── bucket_framework/     # Basic framework modules
├── bucket_usd/          # USDB stablecoin core
├── bucket_oracle/       # Oracle system
├── bucket_cdp/          # CDP collateralized debt positions
└── bucket_psm/          # Peg stability module
```

## Dependencies

<img width="515" height="331" alt="image" src="https://github.com/user-attachments/assets/1cc49356-5ceb-4aab-99e2-e75f3b122aa5" />

## Detailed Module Analysis

### 1. BucketV2Framework (`bucket_framework`)

The basic framework provides core tools and data structures.

#### Main Components:

**Float & Double Precision Arithmetic**
- `float.move`: 9-decimal precision (1e9)
- `double.move`: 18-decimal precision (1e18)
- Supports basic arithmetic operations, percentage conversion, exponential operations

```move
// Usage example
let rate = float::from_bps(550); // 5.5%
let price = double::from(1500);   // 1500.0
```

**Account Abstraction**
- Provides account abstraction layer
- Supports alias setting
- Secure receiving mechanism

**Liability Credit/Debt Management**
- `Credit<T>` and `Debt<T>` structures
- Automatic settlement mechanism
- Credit-debt pairing elimination

**LinkedTable Structure**
- Doubly linked list implementation
- Supports front/back insertion
- Efficient sequential traversal

### 2. BucketV2USD (`bucket_usd`)

Stablecoin core module managing USDB issuance and burning.

#### Core Features:

**Treasury Management**
```move
public struct Treasury has key {
    id: UID,
    module_config_map: VecMap<TypeName, ModuleConfig>,
    beneficiary_address: address,
}
```

**Modular Issuance Control**
- Each integrated module has independent supply limits
- Version control mechanism
- Administrator permission control

**Fee Collection Mechanism**
```move
public fun collect<T, M: drop>(
    treasury: &mut Treasury,
    _witness: M,
    memo: String,
    balance: Balance<T>,
)
```

#### Key Functions:

- `mint<M>()`: Mint USDB
- `burn<M>()`: Burn USDB
- `collect<T, M>()`: Collect fees
- `claim<T, M>()`: Claim fees

### 3. BucketV2Oracle (`bucket_oracle`)

Decentralized oracle system providing price aggregation services.

#### Core Components:

**PriceAggregator**
```move
public struct PriceAggregator<phantom T> has key, store {
    id: UID,
    weights: VecMap<TypeName, u8>,
    weight_threshold: u64,
    outlier_tolerance: Float,
}
```

**PriceCollector**
- Collects prices from multiple sources
- Supports rule type classification
- Dynamic price updates

**Outlier Detection**
- Weighted average-based anomaly detection
- Configurable tolerance
- Automatic filtering of abnormal prices

#### Workflow:
1. Price sources submit prices to Collector
2. Aggregator calculates weighted average price
3. Filter outliers beyond tolerance
4. Output final aggregated price

### 4. BucketV2CDP (`bucket_cdp`)

Collateralized Debt Position system where users can collateralize assets to borrow USDB.

#### Core Structures:

**Vault**
```move
public struct Vault<phantom T> has key, store {
    id: UID,
    security_level: u8,
    access_control: Acl,
    decimal: u8,
    interest_rate: Double,
    limited_supply: LimitedSupply,
    min_collateral_ratio: Float,
    liquidation_rule: TypeName,
    position_table: LinkedTable<address, Position>,
    balance: Balance<T>,
    position_locker: VecSet<address>,
}
```

**Position Management**
```move
public struct Position has store, copy, drop {
    timestamp: u64,
    coll_amount: u64,
    debt_amount: u64,
}
```

#### Main Functions:

**Position Operations**
- `debtor_request()`: User requests (lending, repayment, deposit/withdrawal)
- `donor_request()`: Third-party repayment requests
- `update_position()`: Update position status

**Liquidation Mechanism**
- Health check: `position_is_healthy()`
- Forced liquidation: `liquidate()`
- Proportional liquidation protection

**Interest Calculation**
- Compound interest calculation
- Automatic accumulation by timestamp
- Annualized interest rate system

**Security Control**
- Multi-level security levels
- ACL access control
- Administrator role management

### 5. BucketV2PSM (`bucket_psm`)

Peg Stability Module providing 1:1 exchange services.

#### Core Functions:

**Pool Liquidity Pool**
```move
public struct Pool<phantom T> has key, store {
    id: UID,
    decimal: u8,
    default_fee_config: FeeConfig,
    partner_fee_configs: VecMap<address, FeeConfig>,
    price_tolerance: Float,
    balance: Balance<T>,
    balance_amount: u64,
    usdb_supply: u64,
    sheet: Sheet<T, BucketV2PSM>,
}
```

**Bidirectional Exchange**
- `swap_in()`: Asset to USDB
- `swap_out()`: USDB to Asset
- Dynamic exchange rate adjustment
- Decimal precision handling

**Fee Mechanism**
- Configurable swap-in/swap-out rates
- Partner preferential rates
- Automatic fee collection

**Price Protection**
- Price deviation detection
- Configurable tolerance
- Automatic transaction suspension

## Security Mechanisms

### 1. Access Control
- **AdminCap**: Administrator permission control
- **Witness Pattern**: Secure inter-module communication
- **Version Control**: Prevent incompatible updates

### 2. Economic Security
- **Collateral Ratio Check**: Prevent over-borrowing
- **Supply Limits**: Control inflation risk
- **Liquidation Mechanism**: Protect system solvency

### 3. Technical Security
- **Reentrancy Protection**: Position Locker mechanism
- **Outlier Filtering**: Oracle protection
- **Precision Control**: Avoid precision loss

## Event System

### CDP Events
```move
public struct PositionUpdated has copy, drop {
    vault_id: ID,
    coll_type: String,
    debtor: address,
    deposit_amount: u64,
    borrow_amount: u64,
    withdraw_amount: u64,
    repay_amount: u64,
    interest_amount: u64,
    current_coll_amount: u64,
    current_debt_amount: u64,
    memo: String,
}
```

### PSM Events
```move
public struct PsmSwapIn<phantom T> has copy, drop {
    asset_in_amount: u64,
    asset_balance: u64,
    usdb_out_amount: u64,
    usdb_supply: u64,
}
```

### Oracle Events
```move
public struct PriceAggregated<phantom T> has copy, drop {
    aggregator_id: ID,
    sources: vector<String>,
    prices: vector<u128>,
    weights: vector<u8>,
    current_threshold: u64,
    result: u128,
}
```

## Deployment and Configuration

### 1. Initialization Order
1. Deploy BucketV2Framework
2. Deploy BucketV2USD and initialize Treasury
3. Deploy BucketV2Oracle and configure aggregators
4. Deploy BucketV2CDP and create Vault
5. Deploy BucketV2PSM and create Pool

### 2. Configuration Parameters
```move
// CDP Vault Configuration
vault::create<SUI, LiquidationRule>(
    treasury,
    cap,
    9,              // decimal
    550,            // interest_rate_bps (5.5%)
    1_000_000,      // supply_limit
    11000,          // min_collateral_ratio_bps (110%)
    ctx,
);

// PSM Pool Configuration
pool::create<USDC>(
    treasury,
    cap,
    6,              // decimal
    10,             // swap_in_fee_bps (0.1%)
    20,             // swap_out_fee_bps (0.2%)
    5,              // price_tolerance_bps (0.05%)
    ctx,
);
```

## Usage Examples

### 1. CDP Lending Process
```move
// 1. Create request
let account_req = account::request(ctx);
let deposit = coin::mint_for_testing<SUI>(1000_000_000_000, ctx); // 1000 SUI
let repayment = coin::zero<USDB>(ctx);

let mut request = vault.debtor_request(
    &account_req,
    &treasury,
    deposit,
    500_000_000,    // borrow 500 USDB
    repayment,
    0,              // withdraw 0
);

// 2. Add witness
request.add_witness(RequestCheck {});

// 3. Update position
let (coll_out, usdb_out, mut response) = vault.update_position(
    &mut treasury,
    &clock,
    &price_option,
    request,
    ctx,
);

// 4. Handle response
response.add_witness(ResponseCheck {});
vault.destroy_response(&treasury, response);
```

### 2. PSM Exchange Process
```move
// Swap in: USDC -> USDB
let usdc_coin = coin::mint_for_testing<USDC>(1000_000_000, ctx); // 1000 USDC
let price = price_result::new_for_testing<USDC>(float::from_bps(10000)); // 1.0

let usdb_out = pool.swap_in(
    &mut treasury,
    &price,
    usdc_coin,
    &option::none(), // no partner
    ctx,
);

// Swap out: USDB -> USDC
let usdb_coin = coin::mint_for_testing<USDB>(1000_000_000, ctx);
let usdc_out = pool.swap_out(
    &mut treasury,
    &price,
    usdb_coin,
    &option::none(),
    ctx,
);
```

## Summary

Bucket Protocol V2 is a well-designed decentralized stablecoin protocol featuring:

1. **Modular Design**: Clear component responsibilities, easy to maintain and extend
2. **Security**: Multi-layered permission control and risk management mechanisms
3. **Flexibility**: Supports multiple collateral types and price sources
4. **Scalability**: Plugin architecture supports easy addition of new features
5. **Efficiency**: Built on Sui's high-performance blockchain infrastructure

The protocol provides users with a secure and efficient stablecoin ecosystem while offering developers rich extensibility capabilities.
