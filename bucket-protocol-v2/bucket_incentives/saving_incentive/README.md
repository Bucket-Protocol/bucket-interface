# Saving Pool Incentive System

A sophisticated reward distribution system for saving pools built on Sui blockchain. This module enables automatic distribution of incentive tokens to users based on their LP token holdings over time using a flow-based mechanism.

## Overview

The Saving Pool Incentive System provides:
- **Flow-based rewards**: Continuous reward distribution at a configurable rate
- **Multiple reward tokens**: Support for different reward tokens per saving pool
- **Real-time calculations**: Accurate reward calculations without requiring frequent transactions
- **Hot potato pattern**: Ensures reward state consistency during user actions
- **Admin controls**: Comprehensive management functions for reward parameters

## Architecture

### Key Components

1. **Registry**: Global registry mapping saving pool types to reward managers
2. **RewardManager**: Manages all rewards for a specific saving pool type
3. **Reward**: Individual reward token distribution logic and state
4. **StakeData**: Per-user reward tracking information
5. **Response Checkers**: Hot potato structs ensuring reward updates during actions

### Reward Calculation

The system uses a unit-based reward calculation:
- **Global Unit**: Accumulated reward per LP token since inception
- **User Unit**: User's last recorded global unit value
- **Reward Amount**: `(Current Global Unit - User Unit) * User LP Balance`

## Setup Guide

### 1. Deploy and Initialize

```move
// Initialize the registry (done once during deployment)
// This happens automatically via init() function
```

### 2. Create Reward Manager

```move
// Admin creates a reward manager for a saving pool type
public fun setup_reward_manager<POOL_TOKEN>(
    registry: &mut Registry,
    config: &GlobalConfig,
    admin_cap: &AdminCap,
    saving_pool: &SavingPool<POOL_TOKEN>,
    ctx: &mut TxContext,
) {
    registry.new_reward_manager<POOL_TOKEN>(
        config,
        admin_cap,
        saving_pool,
        ctx
    );
}
```

### 3. Add Reward Token

```move
// Add SUI rewards to SBUCK saving pool
// Distribute 1000 SUI over 24 hours (86400000 ms)
public fun add_sui_rewards(
    reward_manager: &mut RewardManager<SBUCK>,
    admin_cap: &AdminCap,
    config: &GlobalConfig,
    saving_pool: &SavingPool<SBUCK>,
    ctx: &mut TxContext,
) {
    reward_manager.add_reward<SBUCK, SUI>(
        admin_cap,
        config,
        saving_pool,
        1000_000_000_000, // 1000 SUI (in mist)
        86400000,         // 24 hours in milliseconds
        1700000000000,    // Start timestamp
        ctx
    );
}
```

### 4. Supply Reward Tokens

```move
// Supply SUI tokens for distribution
public fun supply_rewards(
    reward_manager: &mut RewardManager<SBUCK>,
    sui_coin: Coin<SUI>,
) {
    reward_manager.supply<SBUCK, SUI>(sui_coin);
}
```

## Usage Examples

### Deposit with Incentives

```move
public fun deposit_with_incentives(
    saving_pool: &mut SavingPool<SBUCK>,
    reward_manager: &mut RewardManager<SBUCK>,
    treasury: &mut Treasury,
    config: &GlobalConfig,
    deposit_coin: Coin<VUSD>,
    clock: &Clock,
    ctx: &mut TxContext,
) {
    // 1. Execute deposit on saving pool
    let account_req = account::request(ctx);
    let deposit_response = saving_pool.deposit(
        treasury,
        &account_req,
        deposit_coin,
        clock,
        ctx,
    );

    // 2. Create incentive checker
    let mut deposit_checker = reward_manager.new_checker_for_deposit_action(
        config,
        deposit_response,
    );

    // 3. Update each reward (repeat for each reward token)
    deposit_checker.update_deposit_action<SBUCK, SUI>(
        config,
        reward_manager,
        saving_pool,
        clock,
    );

    // 4. Finalize the deposit
    let deposit_response = deposit_checker.destroy_deposit_checker(config);
    deposit_response.check_deposit_response(saving_pool);
}
```

### Withdraw with Incentives

```move
public fun withdraw_with_incentives(
    saving_pool: &mut SavingPool<SBUCK>,
    reward_manager: &mut RewardManager<SBUCK>,
    treasury: &mut Treasury,
    config: &GlobalConfig,
    amount: u64,
    clock: &Clock,
    ctx: &mut TxContext,
): Coin<VUSD> {
    // 1. Execute withdrawal on saving pool
    let account_req = account::request(ctx);
    let (vusd_coin, withdraw_response) = saving_pool.withdraw(
        treasury,
        &account_req,
        amount,
        clock,
        ctx,
    );

    // 2. Create incentive checker
    let mut withdraw_checker = reward_manager.new_checker_for_withdraw_action(
        config,
        withdraw_response,
    );

    // 3. Update each reward (repeat for each reward token)
    withdraw_checker.update_withdraw_action<SBUCK, SUI>(
        config,
        reward_manager,
        saving_pool,
        clock,
    );

    // 4. Finalize the withdrawal
    let withdraw_response = withdraw_checker.destroy_withdraw_checker(config);
    withdraw_response.check_withdraw_response(saving_pool);

    vusd_coin
}
```

### Claim Rewards

```move
public fun claim_sui_rewards(
    reward_manager: &mut RewardManager<SBUCK>,
    config: &GlobalConfig,
    saving_pool: &SavingPool<SBUCK>,
    clock: &Clock,
    ctx: &mut TxContext,
): Coin<SUI> {
    let account_req = account::request(ctx);

    // Claim SUI rewards
    let sui_reward = reward_manager.claim<SBUCK, SUI>(
        config,
        saving_pool,
        &account_req,
        clock,
        ctx,
    );

    sui_reward
}
```

### Check User Reward Balance

```move
public fun check_user_pending_rewards(
    reward_manager: &RewardManager<SBUCK>,
    saving_pool: &SavingPool<SBUCK>,
    account: address,
    clock: &Clock,
): u64 {
    let reward = reward_manager.get_reward<SBUCK, SUI>();
    reward.realtime_reward_amount(saving_pool, account, clock)
}
```

## Administrative Functions

### Update Flow Rate

```move
public fun update_flow_rate(
    reward_manager: &mut RewardManager<SBUCK>,
    config: &GlobalConfig,
    clock: &Clock,
    new_flow_amount: u64,
    new_flow_interval: u64,
    request: &AccountRequest,
) {
    reward_manager.update_flow_rate<SBUCK, SUI>(
        config,
        clock,
        new_flow_amount,
        new_flow_interval,
        request,
    );
}
```

### Withdraw from Source

```move
public fun emergency_withdraw(
    reward_manager: &mut RewardManager<SBUCK>,
    config: &GlobalConfig,
    admin_cap: &AdminCap,
    clock: &Clock,
    amount: u64,
    ctx: &mut TxContext,
): Coin<SUI> {
    reward_manager.withdraw_from_source<SBUCK, SUI>(
        config,
        admin_cap,
        clock,
        amount,
        ctx,
    )
}
```

## Error Handling

| Error Code | Description | Resolution |
|------------|-------------|------------|
| `EInvalidReward` | Invalid reward parameters | Check flow_interval > 0 |
| `EMissingRewarderCheck` | Missed reward update | Call update functions for all rewards |
| `EInvalidTimestamp` | Timestamp in the past | Use future timestamp |
| `EOngoingAction` | User has pending operations | Wait for operations to complete |
| `EIncentiveAlreadyStart` | Cannot modify started incentive | Only modify before start time |

## Key Functions

### Core Functions (following Smart Contract Naming Rules)
- `account_exists()` - Check if account exists in reward tracking
- `new_checker_for_deposit_action()` - Create deposit checker (fixed typo from `depoit`)
- `reward_last_update_timestamp()` - Get last reward update timestamp

## Deployments

### Testnet
Package ID
```
0x11e03be85d2b5f1ddef785fe1dfa129551f69913c41324ac0cad116031579588
```
GlobalConfig `349180418`
```
0xdfdfe9c7bdd63113a5c57f3d1c7c425d2b85b73c7ef7d974b98db8584837c5b6
```
Registry `349180418`
```
0x77ffc06871393e8d8dfc2af67bc5464292e9700e903b3cc321ea03b891a1c3ce
```
UpgradeCap
```
0xd3ef6c60a7a4a2de4d422d77927beae2e7ca2e1141dddd28831656b53df0bc6f
```

### Mainnet
Package ID
```
0x39692320d6fc01c27315a7972ed4717e4fd32eed43531ad6f55fd7f24b74e207
```
GlobalConfig `606028576`
```
0x50ffe3535b157841e9ff0470fff722192c90b86b4dee521de0b27b03b44b20f5
```
Registry `606028576`
```
0x95d518095d7b44f45941e3d980224e9b7d0df00bf2151c4f48bb541c860003c9
```
UpgradeCap
```
0x774a460fb760a81578ce0eb5b20c14f1693323e492ebb674ba52696069881913
```
