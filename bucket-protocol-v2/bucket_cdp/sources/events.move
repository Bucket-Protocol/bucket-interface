/// Module for emitting events related to the BucketV2 CDP (Collateralized Debt Position) system.
/// This module defines event structs and emit functions for tracking important changes
/// and actions within the CDP system, such as vault creation, supply limit updates,
/// liquidation rule changes, and position updates.
module bucket_v2_cdp::events;

use std::type_name::{get, TypeName};
use std::string::{String};
use sui::event::{emit};
use bucket_v2_framework::float::{Float};
use bucket_v2_framework::double::{Double};

/// Event emitted when a new vault is created.
public struct VaultCreated has copy, drop {
    /// Unique identifier for the vault
    vault_id: ID,
    /// The coll type of the vault
    coll_type: String,
    /// The interest rate for the vault (scaled value)
    interest_rate: u256,
    /// The supply limit for the vault
    supply_limit: u64,
    /// The minimum coll ratio required
    min_coll_ratio: u128,
}

/// Emits a `VaultCreated` event for a new vault.
///
/// - `vault_id`: Unique identifier for the vault
/// - `interest_rate`: Interest rate as a Double
/// - `supply_limit`: Maximum supply limit for the vault
/// - `min_coll_ratio`: Minimum coll ratio as a Float
public(package) fun emit_vault_created<T>(
    vault_id: ID,
    interest_rate: Double,
    supply_limit: u64,
    min_coll_ratio: Float,
) {
    abort 0;
}

/// Event emitted when the supply limit of a vault is updated.
public struct SupplyLimitUpdated has copy, drop {
    /// Unique identifier for the vault
    vault_id: ID,
    /// The coll type of the vault
    coll_type: String,
    /// Previous supply limit
    before: u64,
    /// New supply limit
    after: u64,
}

/// Emits a `SupplyLimitUpdated` event when a vault's supply limit changes.
///
/// - `vault_id`: Unique identifier for the vault
/// - `before`: Previous supply limit
/// - `after`: New supply limit
public(package) fun emit_supply_limit_updated<T>(
    vault_id: ID,
    before: u64,
    after: u64,
) {
    abort 0;
}

/// Event emitted when the supply limit of a vault is updated.
public struct InterestRateUpdated has copy, drop {
    /// Unique identifier for the vault
    vault_id: ID,
    /// The coll type of the vault
    coll_type: String,
    /// New interest rate
    interest_rate_bps: u64
}

/// Emits a `SupplyLimitUpdated` event when a vault's supply limit changes.
///
/// - `vault_id`: Unique identifier for the vault
/// - `before`: Previous supply limit
/// - `after`: New supply limit
public(package) fun emit_interest_rate_updated<T>(
    vault_id: ID,
    interest_rate_bps: u64
) {
    abort 0;
}

/// Event emitted when the liquidation rule of a vault is updated.
public struct LiquidationRuleUpdated has copy, drop {
    /// Unique identifier for the vault
    vault_id: ID,
    /// The coll type of the vault
    coll_type: String,
    /// Previous liquidation rule type
    before: String,
    /// New liquidation rule type
    after: String,
}

/// Emits a `LiquidationRuleUpdated` event when a vault's liquidation rule changes.
///
/// - `vault_id`: Unique identifier for the vault
/// - `before`: Previous liquidation rule type
/// - `after`: New liquidation rule type
public(package) fun emit_liquidation_rule_updated<T>(
    vault_id: ID,
    before: TypeName,
    after: TypeName,
) {
    abort 0;
}

/// Event emitted when a position in a vault is updated (e.g., deposit, borrow, repay, withdraw).
public struct PositionUpdated has copy, drop {
    /// Unique identifier for the vault
    vault_id: ID,
    /// The coll type of the vault
    coll_type: String,
    /// Address of the debtor (user)
    debtor: address,
    /// Amount deposited in this update
    deposit_amount: u64,
    /// Amount borrowed in this update
    borrow_amount: u64,
    /// Amount withdrawn in this update
    withdraw_amount: u64,
    /// Amount repaid in this update
    repay_amount: u64,
    /// Interest accrued in this update
    interest_amount: u64,
    /// Current coll after the update
    current_coll_amount: u64,
    /// Current debt after the update
    current_debt_amount: u64,
    /// Optional memo or note for the update
    memo: String,
}

/// Emits a `PositionUpdated` event when a user's position in a vault changes.
///
/// - `vault_id`: Unique identifier for the vault
/// - `debtor`: Address of the user
/// - `deposit_amount`: Amount deposited
/// - `borrow_amount`: Amount borrowed
/// - `repay_amount`: Amount repaid
/// - `withdraw_amount`: Amount withdrawn
/// - `interest_amount`: Interest accrued
/// - `current_coll_amount`: Current coll after update
/// - `current_debt_amount`: Current debt after update
/// - `memo`: Optional note for the update
public(package) fun emit_position_updated<T>(
    vault_id: ID,
    debtor: address,
    deposit_amount: u64,
    borrow_amount: u64,
    repay_amount: u64,
    withdraw_amount: u64,
    interest_amount: u64,
    current_coll_amount: u64,
    current_debt_amount: u64,
    memo: String,
) {
    abort 0;
}

public struct SetSecurity has copy, drop{
    vault_id: ID,
    coll_type: String,
    sender: address,
    level: Option<u8>
}

public(package) fun emit_set_security_level<T>(vault_id: ID, sender: address, level: Option<u8>){
    abort 0;
}
