/// Module for handling requests in the BucketV2 CDP system.
module bucket_v2_cdp::request {
    use bucket_v2_usd::usdb::USDB;
    use std::{string::String, type_name::{get, TypeName}};
    use sui::{coin::Coin, vec_set::{Self, VecSet}};

    /// Error codes and abort helpers

    const EWitnessAlreadyExists: u64 = 201;

    fun err_witness_already_exists() { abort EWitnessAlreadyExists }

    /// Struct representing a request to update a vault (borrow, repay, deposit, withdraw, etc.)
    #[allow(lint(coin_field))]
    public struct UpdateRequest<phantom T> {
        vault_id: ID, // Vault being updated
        account: address, // Account making the request
        deposit: Coin<T>, // Coin being deposited
        borrow_amount: u64, // Amount to borrow
        repayment: Coin<USDB>, // USDB being repaid
        withdraw_amount: u64, // Amount to withdraw
        witnesses: VecSet<TypeName>, // Set of witness types attached to this request
        memo: String, // Optional memo for the request
    }

    /// Adds a witness type to the request, aborts if already present
    public fun add_witness<T, W: drop>(self: &mut UpdateRequest<T>, _witness: W) {
        abort 0
    }

    /// Destroys an UpdateRequest, returning its fields (package visibility)
    public(package) fun destroy<T>(
        self: UpdateRequest<T>,
    ): (ID, address, Coin<T>, u64, Coin<USDB>, u64, VecSet<TypeName>, String) {
        abort 0
    }

    /// Getter for vault_id field
    public fun vault_id<T>(self: &UpdateRequest<T>): ID {
        self.vault_id
    }

    /// Getter for account field
    public fun account<T>(self: &UpdateRequest<T>): address {
        self.account
    }

    /// Getter for deposit amount (value of Coin<T>)
    public fun deposit_amount<T>(self: &UpdateRequest<T>): u64 {
        self.deposit.value()
    }

    /// Getter for repay amount (value of Coin<USDB>)
    public fun repay_amount<T>(self: &UpdateRequest<T>): u64 {
        self.repayment.value()
    }

    /// Getter for borrow amount
    public fun borrow_amount<T>(self: &UpdateRequest<T>): u64 {
        self.borrow_amount
    }

    /// Getter for withdraw amount
    public fun withdraw_amount<T>(self: &UpdateRequest<T>): u64 {
        self.withdraw_amount
    }

    /// Getter for memo field
    public fun memo<T>(self: &UpdateRequest<T>): String {
        self.memo
    }

    /// Getter for witnesses set
    public fun witnesses<T>(self: &UpdateRequest<T>): &VecSet<TypeName> {
        &self.witnesses
    }

    /// Package helper to create an UpdateRequest (package visibility)
    public(package) fun new<T>(
        vault_id: ID,
        account: address,
        deposit: Coin<T>,
        borrow_amount: u64,
        repayment: Coin<USDB>,
        withdraw_amount: u64,
        memo: String,
    ): UpdateRequest<T> {
        abort 0
    }
}
