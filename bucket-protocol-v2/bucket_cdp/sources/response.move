// Module for handling responses to vault updates in the BucketV2 CDP system
module bucket_v2_cdp::response;

use std::type_name::{get, TypeName};
use sui::vec_set::{Self, VecSet};

/// Errors

const EWitnessAlreadyExists: u64 = 301;
fun err_witness_already_exists() { abort EWitnessAlreadyExists }

//// Represents the result of a vault update, including collateral, debt, interest, and witnesses
public struct UpdateResponse<phantom T> {
    vault_id: ID,                // The ID of the vault being updated
    account: address,            // The account that owns the vault
    coll_amount: u64,            // The new collateral amount
    debt_amount: u64,            // The new debt amount
    interest_amount: u64,        // The new interest amount
    witnesses: VecSet<TypeName>, // Set of rule type witnesses applied to this update
}

/// Package-only Functions

/// Creates a new UpdateResponse for a vault update
public(package) fun new<T>(
    vault_id: ID,
    account: address,
    coll_amount: u64,
    debt_amount: u64,
    interest_amount: u64,
): UpdateResponse<T> {
    abort 0
}

/// Destroys an UpdateResponse, returning its fields as a tuple
public(package) fun destroy<T>(
    res: UpdateResponse<T>,
): (ID, address, u64, u64, u64, VecSet<TypeName>) {
    abort 0
}

/// Public Functions

/// Adds a witness of type R to the UpdateResponse, aborting if it already exists
public fun add_witness<T, R: drop>(
    res: &mut UpdateResponse<T>,
    _witness: R, // The witness object (consumed, only type is used)
) {
    abort 0
}

/// Getter Functions

/// Returns the vault ID from the response
public fun vault_id<T>(res: &UpdateResponse<T>): ID {
    res.vault_id
}

/// Returns the account address from the response
public fun account<T>(res: &UpdateResponse<T>): address {
    res.account
}

/// Returns the collateral amount from the response
public fun coll_amount<T>(res: &UpdateResponse<T>): u64 {
    res.coll_amount
}

/// Returns the debt amount from the response
public fun debt_amount<T>(res: &UpdateResponse<T>): u64 {
    res.debt_amount
}

/// Returns the interest amount from the response
public fun interest_amount<T>(res: &UpdateResponse<T>): u64 {
    res.interest_amount
}

/// Returns a reference to the set of witnesses from the response
public fun witnesses<T>(res: &UpdateResponse<T>): &VecSet<TypeName> {
    &res.witnesses
}
