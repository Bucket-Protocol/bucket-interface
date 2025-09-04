# Bucket CDP (Collateralized Debt Position)

A sophisticated collateralized debt position system that allows users to deposit collateral assets and borrow USDB stablecoin against them. The system features automated interest accrual, liquidation mechanisms, and comprehensive security controls.

## Project Overview

The Bucket CDP module is a core component of the BucketV2 protocol that enables users to:
- Deposit collateral assets (SUI, BTC, WAL, etc.) into vaults
- Borrow USDB stablecoin against their collateral
- Manage positions with flexible deposit/withdraw/borrow/repay operations
- Earn or pay interest based on their position type
- Participate in a secure liquidation system when positions become unhealthy

## Architecture Design

### Core Design Principles

1. **Modular Security**: Multi-level access control with configurable security levels
2. **Interest Accrual**: Continuous compound interest calculation with millisecond precision
3. **Position Management**: Efficient linked-table based position tracking
4. **Liquidation Safety**: Health-based liquidation with proportional collateral seizure
5. **Witness Pattern**: Secure inter-module communication using capability tokens
6. **Hot Potato Pattern**: Request/Response flow prevents reentrancy attacks

### Security Architecture

- **Access Control Lists (ACL)**: Role-based permissions for managers
- **Security Levels**: Configurable operation restrictions (0=open, 1=strictest, 2=moderate)
- **Position Locking**: Prevents reentrancy during position updates
- **Supply Limits**: Controls USDB inflation per vault
- **Version Control**: Ensures compatibility between modules

## Core Module Structure

```
bucket_cdp/
├── sources/
│   ├── vault.move          # Main vault logic and position management
│   ├── request.move        # Request handling with witness validation
│   ├── response.move       # Response handling for post-processing
│   ├── events.move         # Event emission for monitoring
│   ├── memo.move           # Operation type constants
│   ├── witness.move        # Module witness for treasury operations
│   ├── version.move        # Version compatibility checking
│   └── acl.move           # Access control list management
└── tests/
    └── bucket_cdp_tests.move # Comprehensive test suite
```

## Dependencies

### Direct Dependencies
- **BucketV2USD**: USDB treasury operations and minting/burning
- **BucketV2Oracle**: Price feeds for collateral valuation
- **BucketV2Framework**: Core utilities (Float, Double, LinkedTable, Account)

### Dependency Graph
```
BucketV2CDP
├── BucketV2USD (Treasury, USDB operations)
├── BucketV2Oracle (Price aggregation)
└── BucketV2Framework (Math, data structures, account system)
```

## Detailed Module Analysis

### 1. Vault Module (`vault.move`)

**Core Functionality:**
- Vault creation and configuration management
- Position updates (deposit, withdraw, borrow, repay)
- Interest accrual and collection
- Liquidation processing
- Health checks and collateral ratio validation

**Key Structures:**
```move
public struct Vault<phantom T> has key, store {
    id: UID,
    security_level: Option<u8>,
    access_control: Acl,
    decimal: u8,
    interest_rate: Double,
    interest_unit: Double,
    timestamp: u64,
    total_pending_interest_amount: u64,
    limited_supply: LimitedSupply,
    total_debt_amount: u64,
    min_collateral_ratio: Float,
    liquidation_rule: TypeName,
    request_checklist: vector<TypeName>,
    response_checklist: vector<TypeName>,
    position_table: LinkedTable<address, Position>,
    balance: Balance<T>,
    position_locker: VecSet<address>,
}

public struct Position has store, copy, drop {
    coll_amount: u64,
    debt_amount: u64,
    interest_unit: Double,
}
```

**Key Functions:**
- `new<T, LR>()`: Create new vault with specified parameters
- `update_position<T>()`: Core position management function
- `liquidate<T, LR>()`: Liquidate unhealthy positions
- `collect_interest<T>()`: Accrue and collect interest
- `position_is_healthy<T>()`: Check position health status

### 2. Request Module (`request.move`)

**Purpose:** Handles user requests for vault operations with witness validation.

**Key Structure:**
```move
public struct UpdateRequest<phantom T> {
    vault_id: ID,
    account: address,
    deposit: Coin<T>,
    borrow_amount: u64,
    repayment: Coin<USDB>,
    withdraw_amount: u64,
    witnesses: VecSet<TypeName>,
    memo: String,
}
```

**Key Functions:**
- `debtor_request<T>()`: Create request for position owner
- `donor_request<T>()`: Create request for third-party repayment
- `add_witness<T, W>()`: Add validation witness to request

### 3. Response Module (`response.move`)

**Purpose:** Handles post-processing validation after position updates.

**Key Structure:**
```move
public struct UpdateResponse<phantom T> {
    vault_id: ID,
    account: address,
    coll_amount: u64,
    debt_amount: u64,
    interest_amount: u64,
    witnesses: VecSet<TypeName>,
}
```

### 4. Access Control Module (`acl.move`)

**Purpose:** Manages role-based permissions for vault operations.

**Key Structure:**
```move
public struct Acl has store {
    managers: VecMap<address, u8>,
}
```

**Security Levels:**
- **Level 0**: Invalid (causes abort)
- **Level 1**: Strictest - blocks all operations except basic queries
- **Level 2**: Moderate - allows deposits but restricts borrowing/withdrawing
- **No Level**: Open access to all operations

## Events

The system emits comprehensive events for monitoring and analytics:

### VaultCreated
```move
public struct VaultCreated has copy, drop {
    vault_id: ID,
    coll_type: String,
    interest_rate: u256,
    supply_limit: u64,
    min_coll_ratio: u128,
}
```

### PositionUpdated
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

### Configuration Events
- `SupplyLimitUpdated`: When vault supply limits change
- `InterestRateUpdated`: When interest rates are modified
- `LiquidationRuleUpdated`: When liquidation rules change

## Error Codes

### Request/Response Validation (400s)
- `401 EMissingRequestWitness`: Required request witness not provided
- `402 EMissingResponseWitness`: Required response witness not provided

### Oracle and Health Checks (403-405)
- `403 EOaclePriceIsRequired`: Oracle price needed for operation
- `404 EPositionIsNotHealthy`: Position below minimum collateral ratio
- `405 EPositionIsHealthy`: Cannot liquidate healthy position

### Liquidation Errors (406-407)
- `406 EInvalidLiquidation`: Liquidation parameters invalid
- `407 EDebtorNotFound`: Position does not exist

### Operation Limits (408-410)
- `408 ERepayTooMuch`: Repayment exceeds debt amount
- `409 EWithdrawTooMuch`: Withdrawal exceeds collateral amount
- `410 EWrongVaultId`: Request vault ID mismatch

### Configuration Errors (411-416)
- `411 EInvalidVaultSettings`: Invalid vault parameters
- `412 EAgainstSecurityLevel`: Operation blocked by security level
- `413 ENotManager`: Sender lacks manager permissions
- `414 EPositionIsLocked`: Position locked during update
- `415 EInvalidMinCollateralRatio`: Collateral ratio below 110%
- `416 EInvalidSecurityLevel`: Invalid security level (cannot be 0)

## Implementation Details

### Interest Calculation
- **Compound Interest**: Calculated continuously using `interest_rate * time_fraction`
- **Precision**: Uses 18-decimal Double arithmetic for accuracy
- **Accrual**: Interest accrues every millisecond based on annual rate
- **Collection**: Automatic interest collection during position updates

### Position Management
- **Linked Table**: Efficient O(1) insertion/removal with ordering preservation
- **Hot Potato**: Request/Response pattern prevents reentrancy
- **Atomic Updates**: All position changes are atomic and revert-safe

### Liquidation Mechanism
- **Health Check**: `collateral_value * price >= debt_value * min_ratio`
- **Proportional Seizure**: Collateral seized proportional to debt repaid
- **Price Protection**: Requires oracle price for liquidation operations

### Security Features
- **Position Locking**: Prevents concurrent position modifications
- **Witness Validation**: Configurable witness requirements for operations
- **Supply Limits**: Per-vault USDB minting limits
- **Version Control**: Ensures module compatibility

## Deployment Information

### Testnet
- **Package ID**: `0x801a162330af18f018022faf93d781e5f2777886cac46c269ba3cc09b808c59a`
- **UpgradeCap**: `0x5414b093b53fbd4eaf6892fcbab5577a10bcf2a0b264a5418809857a2a5fa99f`

### Mainnet
- **Package ID**: `0x9f835c21d21f8ce519fec17d679cd38243ef2643ad879e7048ba77374be4036e`
- **UpgradeCap**: `0x9e9a1e879aa062c46e0beb731a974ee9de0c242989127d4da0b1edcf37bf7526`

## Usage Examples

### Manage a Position
```move
// 1. Create debtor request
let request = vault.debtor_request(&account_req, &treasury, deposit_coin, borrow_amount, repayment_coin, withdraw_amount);

// 2. Add required witnesses
request.add_witness(SomeWitness {});

// 3. Update position
let (coll_out, usdb_out, response) = vault.update_position(&mut treasury, &clock, &price_option, request, ctx);

// 4. Add response witnesses and destroy
response.add_witness(ResponseWitness {});
vault.destroy_response(&treasury, response);
```

### Liquidating a Position
```move
// 1. Check if position is unhealthy
let is_healthy = vault.position_is_healthy(debtor, &clock, &price_result);

// 2. Create liquidation request
let request = vault.liquidate(&treasury, &clock, &price_result, debtor, repayment_coin, LiquidationRule {}, ctx);

// 3. Process liquidation
let (coll_out, usdb_out, response) = vault.update_position(&mut treasury, &clock, &price_option, request, ctx);
