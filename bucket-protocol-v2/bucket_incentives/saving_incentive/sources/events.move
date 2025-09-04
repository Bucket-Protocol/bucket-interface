module bucket_saving_incentive::saving_incentive_events {
    use std::{ascii::String, type_name::{get}};
    use sui::event::emit;

    public struct CreateSavingPoolRewardManager<phantom T> has copy, drop {
        reward_manager_id: ID,
    }

    public(package) fun emit_create_saving_pool_reward_manager<T>(reward_manager_id: ID) {
        emit(CreateSavingPoolRewardManager<T> {
            reward_manager_id,
        })
    }

    public struct AddRewarder<phantom T, phantom R> has copy, drop {
        reward_manager_id: ID,
        rewarder_id: ID,
    }

    public(package) fun emit_add_rewarder<T, R>(reward_manager_id: ID, rewarder_id: ID) {
        emit(AddRewarder<T, R> {
            reward_manager_id,
            rewarder_id,
        })
    }

    public struct SourceChanged<phantom T, phantom R> has copy, drop {
        kind: String,
        rewarder_id: ID,
        reward_type: String,
        reward_amount: u64,
        is_deposit: bool,
    }

    public(package) fun emit_source_changed<T, R>(
        rewarder_id: ID,
        kind: String,
        amount: u64,
        is_deposit: bool,
    ) {
        emit(SourceChanged<T, R> {
            kind,
            rewarder_id,
            reward_type: get<R>().into_string(),
            reward_amount: amount,
            is_deposit,
        });
    }

    public struct FlowRateChanged<phantom T, phantom R> has copy, drop {
        kind: String,
        rewarder_id: ID,
        asset_type: String,
        reward_type: String,
        flow_rate: u256,
    }

    public(package) fun emit_flow_rate_changed<T, R>(
        kind: String,
        rewarder_id: ID,
        flow_rate: u256,
    ) {
        emit(FlowRateChanged<T, R> {
            kind,
            rewarder_id,
            asset_type: get<T>().into_string(),
            reward_type: get<R>().into_string(),
            flow_rate,
        });
    }

    public struct RewarderTimestampChanged<phantom T, phantom R> has copy, drop {
        kind: String,
        rewarder_id: ID,
        reward_timestamp: u64,
    }

    public(package) fun emit_reward_timestamp_changed<T, R>(
        rewarder_id: ID,
        kind: String,
        timestamp: u64,
    ) {
        emit(RewarderTimestampChanged<T, R> {
            rewarder_id,
            kind,
            reward_timestamp: timestamp,
        });
    }

    public struct ClaimReward<phantom T, phantom R> has copy, drop {
        kind: String,
        rewarder_id: ID,
        account_address: address,
        asset_type: String,
        reward_type: String,
        reward_amount: u64,
    }

    public(package) fun emit_claim_reward<T, R>(
        kind: String,
        rewarder_id: ID,
        account: address,
        amount: u64,
    ) {
        emit(ClaimReward<T, R> {
            kind,
            rewarder_id,
            account_address: account,
            asset_type: get<T>().into_string(),
            reward_type: get<R>().into_string(),
            reward_amount: amount,
        });
    }
}
