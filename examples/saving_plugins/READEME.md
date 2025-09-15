# Bucket V2 Integration Guide

This guide demonstrates how to integrate with the Bucket V2 framework using the saving plugins example. The Bucket V2 framework provides a comprehensive DeFi infrastructure with PSM (Peg Stability Module), saving pools, and oracle integration.

## Overview

The example shows how to build a withdrawal request plugin that extends the basic saving pool functionality with an approval-based withdrawal system. This pattern can be adapted for various DeFi use cases.

## Key Components

### 1. Framework Dependencies

```move
use bucket_v2_framework::account::{Self, Account};
use bucket_v2_oracle::result::PriceResult;
use bucket_v2_psm::pool::Pool;
use bucket_v2_saving::saving::{DepositResponse, WithdrawResponse, SavingPool};
use bucket_v2_usd::{admin::AdminCap, usdb::{USDB, Treasury}};
```

### 2. Core Plugin Structure

```move
public struct WithdrawRequestPlugin<phantom T> has key, store {
    id: UID,
    version: VecSet<u64>,
    account: Account,
    managers: VecSet<address>,
    pending_requests: LinkedTable<u64, Request>,
    counter: u64,
}
```

## Integration Steps

### Step 1: Initialize Your Plugin

Create a new plugin instance with admin capabilities:

```move
public fun new<T>(_cap: &AdminCap, ctx: &mut TxContext): WithdrawRequestPlugin<T> {
    WithdrawRequestPlugin<T> {
        id: object::new(ctx),
        version: vec_set::singleton(VERSION),
        account: account::new(option::none(), ctx),
        managers: vec_set::singleton(ctx.sender()),
        pending_requests: linked_table::new(ctx),
        counter: 0,
    }
}
```

### Step 2: Implement Deposit Flow

The deposit flow integrates PSM and saving pools:

```move
public fun deposit<T, StableCoin>(
    self: &WithdrawRequestPlugin<T>,
    user_id: String,
    // PSM parameters
    pool: &mut Pool<StableCoin>,
    treasury: &mut Treasury,
    price: &PriceResult<StableCoin>,
    // Saving pool parameters
    saving_pool: &mut SavingPool<T>,
    stable: Coin<StableCoin>,
    clock: &Clock,
    ctx: &mut TxContext,
): DepositResponse<T>
```

**Flow:**
1. Convert stable coin to USDB via PSM
2. Deposit USDB to saving pool
3. Add custom witness for extended functionality
4. Emit deposit event

### Step 3: Implement Withdrawal Request System

Create a two-step withdrawal process:

```move
// Step 1: User requests withdrawal
public fun request_withdraw<T>(
    self: &mut WithdrawRequestPlugin<T>,
    withdraw_response: &mut WithdrawResponse<T>,
    usdb: Coin<USDB>,
    clock: &Clock,
)

// Step 2: Manager approves withdrawal
public fun approve_withdraw<T, StableCoin>(
    self: &mut WithdrawRequestPlugin<T>,
    request_id: u64,
    user_id: String,
    pool: &mut Pool<StableCoin>,
    treasury: &mut Treasury,
    price: &PriceResult<StableCoin>,
    clock: &Clock,
    ctx: &mut TxContext,
)
```

### Step 4: Add Event Tracking

Implement comprehensive event tracking:

```move
public struct DepositEvent<phantom T> has copy, drop, store {
    user_id: String,
    sender: address,
    amount: u64,
    timestamp: u64,
}

public struct RequestWithdraEvent<phantom T> has copy, drop, store {
    owner: address,
    amount: u64,
    timestamp: u64,
}

public struct FulfillWithdraEvent<phantom T> has copy, drop, store {
    user_id: String,
    owner: address,
    amount: u64,
    timestamp: u64,
}
```

## Key Features

### Version Management
- Support for multiple package versions
- Version validation on each operation
- Easy upgrade path

### Access Control
- Admin-only functions protected by `AdminCap`
- Manager-based approval system
- Flexible permission management

### Account Integration
- Built-in account system from bucket_v2_framework
- Automatic account creation and management
- Request-based operations

### Oracle Integration
- Price feed integration via `PriceResult<T>`
- Real-time price validation
- Secure price oracle usage

## Best Practices

### 1. Version Control
Always implement version checking:
```move
fun assert_version<T>(self: &WithdrawRequestPlugin<T>) {
    assert!(self.version.contains(&version()), EInvalidPackageVersion);
}
```

### 2. Event Emission
Emit events for all significant operations:
```move
emit(DepositEvent<T> {
    user_id,
    sender: ctx.sender(),
    amount: deposit_response.deposited_usdb_amount(),
    timestamp: clock.timestamp_ms(),
});
```

### 3. Error Handling
Define clear error codes:
```move
const EInvalidPackageVersion: u64 = 101;
const ENotManager: u64 = 102;
const EUnmatchedWithdrawalAmount: u64 = 103;
```

### 4. Witness Pattern
Use witness types for extended functionality:
```move
public struct SavingPoolWithdrawWithRequest<phantom T> has drop {}
```

## View Functions

Implement comprehensive view functions for frontend integration:

```move
public fun get_requests<T>(
    self: &WithdrawRequestPlugin<T>,
    mut cursor: Option<u64>,
    size: u64,
): (vector<RequestData>, Option<u64>)
```

## Deployment

1. Deploy your plugin contract
2. Initialize with admin capabilities
3. Configure managers and permissions
4. Integrate with existing Bucket V2 infrastructure

## Security Considerations

- Always validate package versions
- Implement proper access controls
- Use witness patterns for extended functionality
- Validate all user inputs
- Emit events for auditability

## Example Usage

```move
// Initialize plugin
let plugin = new<MyToken>(&admin_cap, ctx);

// User deposits
let deposit_response = plugin.deposit(
    user_id,
    pool,
    treasury,
    price,
    saving_pool,
    stable_coin,
    clock,
    ctx
);

// User requests withdrawal
plugin.request_withdraw(&mut withdraw_response, usdb_coin, clock);

// Manager approves withdrawal
plugin.approve_withdraw(request_id, user_id, pool, treasury, price, clock, ctx);
