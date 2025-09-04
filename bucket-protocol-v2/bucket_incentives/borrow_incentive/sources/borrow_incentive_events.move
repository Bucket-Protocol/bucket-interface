module bucket_v2_borrow_incentive::borrow_incentive_events;

use std::type_name::{get};
use std::ascii::{String};
use sui::event::{emit};

public struct RewarderCreated has copy, drop {
    vault_id: ID,
    rewarder_id: ID,
    asset_type: String,
    reward_type: String,
    start_timestamp: u64,
    flow_rate: u256,
}

public(package) fun emit_rewarder_created<T, R>(
    vault_id: ID,
    rewarder_id: ID,
    start_timestamp: u64,
    flow_rate: u256,
) {
    emit(RewarderCreated {
        vault_id,
        rewarder_id,
        asset_type: get<T>().into_string(),
        reward_type: get<R>().into_string(),
        start_timestamp,
        flow_rate,
    });
}

public struct SourceChanged has copy, drop {
    rewarder_id: ID,
    reward_type: String,
    amount: u64,
    is_deposit: bool,
}

public(package) fun emit_source_changed<R>(
    rewarder_id: ID,
    amount: u64,
    is_deposit: bool,
) {
    emit(SourceChanged {
        rewarder_id,
        reward_type: get<R>().into_string(),
        amount,
        is_deposit,
    });
}

public struct FlowRateChanged has copy, drop {
    rewarder_id: ID,
    asset_type: String,
    reward_type: String,
    flow_rate: u256,
}

public(package) fun emit_flow_rate_changed<T, R>(
    rewarder_id: ID,
    flow_rate: u256,
) {
    emit(FlowRateChanged {
        rewarder_id,
        asset_type: get<T>().into_string(),
        reward_type: get<R>().into_string(),
        flow_rate,
    });
}

public struct ClaimReward has copy, drop {
    rewarder_id: ID,
    account: address,
    asset_type: String,
    reward_type: String,
    amount: u64,
}

public(package) fun emit_claim_reward<T, R>(
    rewarder_id: ID,
    account: address,
    amount: u64,
) {
    emit(ClaimReward {
        rewarder_id,
        account,
        asset_type: get<T>().into_string(),
        reward_type: get<R>().into_string(),
        amount,
    });
}
