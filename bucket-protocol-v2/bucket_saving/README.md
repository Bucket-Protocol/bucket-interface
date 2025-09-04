# Bucket V2 Saving Module

A decentralized saving pool implementation built on Sui blockchain that allows users to deposit USDB tokens and earn interest over time through your customized LP (Liquidity Provider) tokens.

## Overview

The Bucket V2 Saving module provides a secure and efficient way for users to earn yield on their USDB holdings. Users deposit USDB tokens into a saving pool and receive LP tokens in return. These LP tokens accrue value over time based on the configured annual interest rate.

## Key Features

- **Interest-bearing deposits**: Earn annual interest on USDB deposits
- **LP token system**: Receive transferable LP tokens representing your position
- **Flexible interest rates**: Admin-configurable annual percentage rates
- **Deposit caps**: Optional maximum deposit limits for risk management
- **Position locking**: Prevents overlapping operations for account safety
- **Witness pattern**: Extensible validation system for deposits and withdrawals

## Core Components

### SavingPool<T>
The main pool contract that:
- Holds USDB reserve
- Issues LP tokens to depositors
- Calculates and distributes interest
- Manages user positions

### Position<T>
Individual user positions containing:
- LP token balance
- Last update timestamp

### InterestConfig
Interest rate configuration including:
- Annual saving rate (as basis points)
- Last interest distribution timestamp

## Key Functions

### User Operations

#### `deposit<T>`
Deposit USDB tokens into the saving pool and receive LP tokens.

**Parameters:**
- `self`: Mutable reference to the saving pool
- `treasury`: Mutable reference to USDB treasury
- `account`: Account address for the deposit
- `usdb`: USDB coins to deposit
- `clock`: System clock for timestamp
- `ctx`: Transaction context

**Returns:** `DepositResponse<T>` hot potato that must be validated

#### `withdraw<T>`
Burn LP tokens to withdraw USDB from the pool.

**Parameters:**
- `self`: Mutable reference to the saving pool
- `treasury`: Mutable reference to USDB treasury
- `account`: Account address for the withdrawal
- `burned_lp_amount`: Amount of LP tokens to burn
- `clock`: System clock for timestamp
- `ctx`: Transaction context

**Returns:** `(Coin<USDB>, WithdrawResponse<T>)` - withdrawn USDB and response hot potato

### View Functions

#### `lp_token_value<T>`
Calculate the USDB value of a given amount of LP tokens.

#### `lp_token_value_of<T>`
Get the current USDB value of a user's LP token balance.

#### `calculate_lp_mint_amount<T>`
Calculate how many LP tokens would be minted for a given USDB deposit.

#### `pending_interest<T>`
Calculate the interest that has accumulated since the last distribution.

#### `total_reserve<T>`
Get the total reserve amount including accumulated interest.

#### `usdb_reserve<T>`
Get the current USDB reserve held in the pool (excluding pending interest).

#### `position_exists<T>`
Check if a position exists for the given account address.

### Admin Functions

#### `new<T>`
Create a new saving pool with the given treasury capability.

#### `update_saving_rate<T>`
Update the annual interest rate for the pool.

#### `update_deposit_cap<T>`
Set or remove the maximum deposit limit.

#### Response Validation Management
- `add_deposit_response_check<T, R>`
- `remove_deposit_response_check<T, R>`
- `add_withdraw_response_check<T, R>`
- `remove_withdraw_response_check<T, R>`

## Interest Calculation

The module uses a continuous compounding model where:

- Interest accrues every millisecond based on the annual rate
- Formula: `interest = (current_time - last_emitted) * saving_rate * reserve / MS_IN_YEAR`
- Interest is automatically collected and added to reserve during operations

## Hot Potato Pattern

The module implements a hot potato pattern for operation validation:

### DepositResponse<T>
Must be consumed after deposit operations, containing:
- Account address (`account_address`)
- Deposited USDB amount (`deposited_usdb_amount`)
- Minted LP tokens (`minted_lp_amount`)
- Previous balance and timestamp (`prev_last_update_timestamp`)
- Witness validation set

### WithdrawResponse<T>
Must be consumed after withdraw operations, containing:
- Account address (`account_address`)
- Burned LP tokens (`burned_lp_amount`)
- Withdrawn USDB amount (`withdrawal_usdb_amount`)
- Previous balance and timestamp (`prev_last_update_timestamp`)
- Witness validation set

## Security Features

1. **Position Locking**: Prevents concurrent operations on the same account
2. **Package Versioning**: Ensures compatibility across upgrades
3. **Witness Validation**: Extensible validation system for custom rules
4. **Deposit Caps**: Optional limits to manage pool size
5. **Hot Potato Pattern**: Ensures proper operation completion

## Error Codes

- `EInvalidPackageVersion` (001): Package version mismatch
- `EMissingDepositResponseWitness` (101): Missing required deposit witness
- `EMissingWithdrawResponseWitness` (102): Missing required withdraw witness
- `EWitnessAlreadyExists` (103): Duplicate witness addition
- `EInsufficientDeposit` (104): Deposit amount too small
- `EAccountNotFound` (104): Account position not found
- `EExceedDepositCap` (105): Deposit exceeds pool limit
- `ELockedAccount` (106): Account has ongoing operation

## Usage Examples

### Basic Deposit Operation

- Deposit
```move
// Deposit USDB tokens into the saving pool
public fun deposit<T>(user: address, deposit_amount: u64) {
    // Get required shared objects
    let mut saving_pool = /* get shared SavingPool<T> */;
    let mut treasury = /* get shared Treasury */;
    let clock = /* get shared Clock */;

    // Check how many LP tokens will be minted
    let minted_lp = saving_pool.calculate_lp_mint_amount(deposit_amount, &clock);

    // Create USDB coins to deposit
    let usdb = coin::mint_for_testing<USDB>(deposit_amount, ctx);

    // Perform the deposit
    let deposit_res = saving_pool.deposit(
        &mut treasury,
        user,
        usdb,
        &clock,
        ctx,
    );

    // Complete the deposit (required)
    deposit_res.check_deposit_response(&mut saving_pool, &treasury);
}
```


- Withdraw
```move
// Withdraw USDB by burning LP tokens
public fun withdraw<T>(user: address, lp_amount_to_burn: u64) {
    // Get required shared objects
    let mut saving_pool = /* get shared SavingPool<T> */;
    let mut treasury = /* get shared Treasury */;
    let clock = /* get shared Clock */;

    // Check how much USDB will be received
    let quoted_usdb = saving_pool.lp_token_value(lp_amount_to_burn, &clock);

    // Perform the withdrawal
    let (usdb_coin, withdraw_res) = saving_pool.withdraw(
        &mut treasury,
        user,
        lp_amount_to_burn,
        &clock,
        ctx,
    );

    // Complete the withdrawal (required)
    withdraw_res.check_withdraw_response(&mut saving_pool, &treasury);

    // Use the withdrawn USDB coins
    // coin::burn_for_testing(usdb_coin); // or transfer to user
}
```

- Query
```move
// Check user's LP token balance
let user_lp_balance = saving_pool.lp_balance_of(user_address);

// Check current value of user's position
let position_value = saving_pool.lp_token_value_of(user_address, &clock);

// Calculate LP tokens for a potential deposit
let estimated_lp = saving_pool.calculate_lp_mint_amount(deposit_amount, &clock);

// Check total pool reserve (including pending interest)
let total_reserve = saving_pool.total_reserve(&clock);

// Check current pool reserve (excluding pending interest)
let usdb_reserve = saving_pool.usdb_reserve();

// Check pending interest
let pending_interest = saving_pool.pending_interest(&clock);

// Check if a position exists
let has_position = saving_pool.position_exists(user_address);
```

## Deployments

### Testnet
Package IDs
```
0xf59c363a3af10f51e69c612c5fa01f6500701254043f057e132cdbd27b67d14f
```
UpgradeCap
```
0xd4aa6aa116ed40595fa928e472844dc42e2f6d4c6b234e358334c6373f549fe7
```

### Mainnet
Package IDs
```
0x872d08a70db3db498aa7853276acea8091fdd9871b2d86bc8dcb8524526df622
```
UpgradeCap
```
0x0c631a1f6836379e18f86bf431615caa297f8a027c4e2342220c82232b83a9c7
```
