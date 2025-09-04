/// Module for fee events
module bucket_v2_usd::treasury;

use std::string::{String};
use std::type_name::{get};
use sui::event::{emit};

public struct CollectFee<phantom M> has copy, drop {
    memo: String, // Description or memo for the collection
    coin_type: String, // The coin type of the fee
    amount: u64, // Amount collected
}

public(package) fun emit_collect_fee<T, M>(memo: String, amount: u64) {
    abort 0
}

public struct ClaimFee<phantom M> has copy, drop {
    coin_type: String, // The coin type of the fee
    amount: u64, // Amount claimed
}

public(package) fun emit_claim_fee<T, M>(amount: u64) {
    abort 0
}
