/// Module: saving_incentive
/// This module implements a reward system for saving pools, allowing users to earn incentive tokens
/// based on their LP token holdings over time. It uses a flow-based reward distribution mechanism.
module bucket_saving_incentive::saving_incentive {
    use bucket_saving_incentive::{
        incentive_config::GlobalConfig,
        memo,
        saving_incentive_events as events
    };
    use bucket_v2_framework::{account::AccountRequest, double::{Self, Double}};
    use bucket_v2_saving::saving::{SavingPool, DepositResponse, WithdrawResponse};
    use bucket_v2_usd::admin::AdminCap;
    use std::type_name::{get, TypeName};
    use sui::{
        balance::{Self, Balance},
        clock::Clock,
        coin::{Self, Coin},
        dynamic_field as df,
        table::{Self, Table},
        vec_map::{Self, VecMap},
        vec_set::{Self, VecSet}
    };

    // === Errors ===

    const EInvalidReward: u64 = 301;

    /// Thrown when reward parameters are invalid (e.g., zero flow interval)
    fun err_invalid_reward() { abort EInvalidReward }

    const EMissingRewarderCheck: u64 = 302;

    /// Thrown when trying to destroy a checker without updating all rewarders
    fun err_missing_rewarder_check() { abort EMissingRewarderCheck }

    const EInvalidTimestamp: u64 = 303;

    /// Thrown when timestamp is in the past
    fun err_invalid_timestamp() { abort EInvalidTimestamp }

    const EOngoingAction: u64 = 304;

    /// Thrown when user has ongoing deposit/withdraw actions
    fun err_ongoing_action() { abort EOngoingAction }

    const EIncentiveAlreadyStart: u64 = 304;

    /// Thrown when trying to update timestamp after incentive has started
    fun err_incentive_already_start() { abort EIncentiveAlreadyStart }

    // === Constants ===

    /// Witness type for saving pool incentives
    public struct SavingPoolIncentives has drop {}

    /// Global registry that maps saving pool types to their reward managers
    public struct Registry has key {
        id: UID,
        /// Maps saving pool type to its reward manager ID
        reward_manager_ids: VecMap<TypeName, ID>,
    }

    /// Returns the mapping of saving pool types to reward manager IDs
    public fun reward_manager_ids(reg: &Registry): &VecMap<TypeName, ID> {
        &reg.reward_manager_ids
    }

    /// Manages all rewarders for a specific saving pool type T
    public struct RewardManager<phantom T> has key, store {
        id: UID,
        /// Set of all reward IDs managed by this manager
        rewarder_ids: VecSet<ID>,
    }

    /// Gets an immutable reference to a specific rewarder
    public fun get_rewarder<T, R>(reward_manager: &RewardManager<T>): &Rewarder<T, R> {
        abort 0;
    }

    /// Gets a mutable reference to a specific rewarder (internal use)
    fun get_rewarder_mut<T, R>(reward_manager: &mut RewardManager<T>): &mut Rewarder<T, R> {
        abort 0;
    }

    /// Returns all reward IDs managed by this reward manager
    public fun rewarder_ids<T>(reward_manager: &RewardManager<T>): &VecSet<ID> {
        abort 0;
    }

    /// Individual user's staking data for a specific reward token
    public struct StakeData<phantom R> has store {
        /// User's unit value for reward calculation
        unit: Double,
        /// User's accumulated unclaimed rewards
        reward: Balance<R>,
    }

    /// Key for storing rewarder data in dynamic fields
    public struct RewarderKey<phantom R> has copy, drop, store {}

    /// Main rewarder structure containing all reward logic and state
    public struct Rewarder<phantom T, phantom R> has key, store {
        id: UID,
        /// Total reward tokens available for distribution
        source: Balance<R>,
        /// Reward tokens ready for claiming
        pool: Balance<R>,
        /// Rate of reward distribution (tokens per millisecond)
        flow_rate: Double,
        /// Total LP tokens staked (snapshot)
        total_stake: u64,
        /// Individual user stake data
        stake_table: Table<address, StakeData<R>>,
        /// Global unit for reward calculation
        unit: Double,
        /// Last update timestamp
        last_update_timestamp: u64,
    }

    // Getter functions for Rewarder struct
    /// Returns the total source balance available for rewards
    public fun rewarder_source<T, R>(rewarder: &Rewarder<T, R>): u64 {
        rewarder.source.value()
    }

    /// Returns the pool balance ready for claiming
    public fun rewarder_pool<T, R>(rewarder: &Rewarder<T, R>): u64 {
        rewarder.pool.value()
    }

    /// Returns the current flow rate (tokens per millisecond)
    public fun rewarder_flow_rate<T, R>(rewarder: &Rewarder<T, R>): Double {
        rewarder.flow_rate
    }

    /// Returns the total staked LP tokens
    public fun rewarder_total_stake<T, R>(rewarder: &Rewarder<T, R>): u64 {
        rewarder.total_stake
    }

    /// Returns reference to the stake table
    public fun rewarder_stake_table<T, R>(
        rewarder: &Rewarder<T, R>,
    ): &Table<address, StakeData<R>> {
        &rewarder.stake_table
    }

    /// Returns the global reward unit
    public fun rewarder_unit<T, R>(rewarder: &Rewarder<T, R>): Double {
        rewarder.unit
    }

    /// Returns the last update timestamp
    public fun rewarder_last_update_timestamp<T, R>(rewarder: &Rewarder<T, R>): u64 {
        rewarder.last_update_timestamp
    }

    /// Returns the unit value for a specific account
    public fun unit_of<T, R>(rewarder: &Rewarder<T, R>, account: address): Double {
        rewarder.stake_table[account].unit
    }

    /// Returns the reward balance for a specific account
    public fun reward_of<T, R>(rewarder: &Rewarder<T, R>, account: address): u64 {
        rewarder.stake_table[account].reward.value()
    }

    /// Hot potato for ensuring all rewarders are updated during deposit
    public struct DepositResponseChecker<phantom T> {
        /// Set of rewarders that need to be updated
        rewarder_ids: VecSet<ID>,
        /// Original deposit response
        response: DepositResponse<T>,
    }

    /// Hot potato for ensuring all rewarders are updated during withdrawal
    public struct WithdrawResponseChecker<phantom T> {
        /// Set of rewarders that need to be updated
        rewarder_ids: VecSet<ID>,
        /// Original withdraw response
        response: WithdrawResponse<T>,
    }

    // === View Functions ===

    /// Checks if an account has staking data in the rewarder
    public fun account_exists<T, R>(rewarder: &Rewarder<T, R>, account_address: address): bool {
        abort 0;
    }

    /// Calculates the real-time reward amount for an account (settled + unsettled)
    public fun realtime_reward_amount<T, R>(
        rewarder: &Rewarder<T, R>,
        saving_pool: &SavingPool<T>,
        account: address,
        clock: &Clock,
    ): u64 {
        abort 0;
    }

    // === Admin Functions ===

    /// Initialize the global registry (called once during deployment)
    fun init(ctx: &mut TxContext) {
        abort 0;
    }

    /// Creates a new reward manager for a specific saving pool type
    /// Only admins can call this function
    public fun new_reward_manager<T>(
        registry: &mut Registry,
        config: &GlobalConfig,
        _cap: &AdminCap,
        _saving_pool: &SavingPool<T>,
        ctx: &mut TxContext,
    ): RewardManager<T> {
        abort 0;
    }

    public fun new_reward_manager_and_share<T>(
        registry: &mut Registry,
        config: &GlobalConfig,
        _cap: &AdminCap,
        _saving_pool: &SavingPool<T>,
        ctx: &mut TxContext,
    ) {
        abort 0;
    }

    /// Adds a new reward token to the reward manager
    /// flow_amount: tokens to distribute per flow_interval
    /// flow_interval: time interval in milliseconds
    /// start_time: when the reward distribution starts
    public fun add_reward<T, R>(
        reward_manager: &mut RewardManager<T>,
        _cap: &AdminCap,
        config: &GlobalConfig,
        saving_pool: &SavingPool<T>,
        flow_amount: u64,
        flow_interval: u64,
        start_time: u64,
        clock: &Clock,
        ctx: &mut TxContext,
    ) {
        abort 0;
    }

    /// Withdraws tokens from the reward source (admin only)
    public fun withdraw_from_source<T, R>(
        reward_manager: &mut RewardManager<T>,
        config: &GlobalConfig,
        _cap: &AdminCap,
        clock: &Clock,
        amount: u64,
        ctx: &mut TxContext,
    ): Coin<R> {
        abort 0;
    }

    /// Updates the reward flow rate (manager only)
    public fun update_flow_rate<T, R>(
        reward_manager: &mut RewardManager<T>,
        config: &GlobalConfig,
        clock: &Clock,
        flow_amount: u64,
        flow_interval: u64,
        request: &AccountRequest,
    ) {
        abort 0;
    }

    /// Updates when the reward distribution starts (manager only, before start time)
    public fun update_reward_timestamp<T, R>(
        reward_manager: &mut RewardManager<T>,
        config: &GlobalConfig,
        clock: &Clock,
        timestamp: u64,
        request: &AccountRequest,
    ) {
        abort 0;
    }

    // === Public Functions ===

    /// Supplies reward tokens to the reward source
    public fun supply<T, R>(reward_manager: &mut RewardManager<T>, coin: Coin<R>) {
        abort 0;
    }

    /// Creates a checker for deposit actions to ensure rewarders are updated
    public fun new_checker_for_deposit_action<T>(
        reward_manager: &RewardManager<T>,
        config: &GlobalConfig,
        deposit_response: DepositResponse<T>,
    ): DepositResponseChecker<T> {
        abort 0;
    }

    /// Updates reward state for a specific reward during deposit
    public fun update_deposit_action<T, R>(
        deposit_checker: &mut DepositResponseChecker<T>,
        config: &GlobalConfig,
        reward_manager: &mut RewardManager<T>,
        saving_pool: &SavingPool<T>,
        clock: &Clock,
    ) {
        abort 0;
    }

    /// Destroys the deposit checker and returns the original response
    public fun destroy_deposit_checker<T>(
        deposit_checker: DepositResponseChecker<T>,
        config: &GlobalConfig,
    ): DepositResponse<T> {
        abort 0;
    }

    /// Claims all available rewards for the user
    public fun claim<T, R>(
        reward_manager: &mut RewardManager<T>,
        config: &GlobalConfig,
        saving_pool: &SavingPool<T>,
        request: &AccountRequest,
        clock: &Clock,
        ctx: &mut TxContext,
    ): Coin<R> {
        abort 0;
    }

    /// Creates a checker for withdraw actions to ensure rewarders are updated
    public fun new_checker_for_withdraw_action<T>(
        reward_manager: &RewardManager<T>,
        config: &GlobalConfig,
        withdraw_response: WithdrawResponse<T>,
    ): WithdrawResponseChecker<T> {
        abort 0;
    }

    /// Updates reward state for a specific reward during withdrawal
    public fun update_withdraw_action<T, R>(
        withdraw_checker: &mut WithdrawResponseChecker<T>,
        config: &GlobalConfig,
        reward_manager: &mut RewardManager<T>,
        saving_pool: &SavingPool<T>,
        clock: &Clock,
    ) {
        abort 0;
    }

    /// Destroys the withdraw checker and returns the original response
    public fun destroy_withdraw_checker<T>(
        withdraw_checker: WithdrawResponseChecker<T>,
        config: &GlobalConfig,
    ): WithdrawResponse<T> {
        abort 0;
    }

    // === Private Functions ===

    /// Settles pool-wide rewards by updating the global unit and moving tokens from source to pool
    fun settle_pool_reward<T, R>(rewarder: &mut Rewarder<T, R>, clock: &Clock) {
        abort 0;
    }

    /// Calculates how many reward tokens should be released and the new global unit
    fun realtime_reward_release_and_unit<T, R>(
        rewarder: &Rewarder<T, R>,
        clock: &Clock,
    ): (u64, Double) {
        abort 0;
    }

    /// Calculates unsettled reward amount for an account based on unit difference
    fun unsettled_reward_amount<T, R>(
        rewarder: &Rewarder<T, R>,
        account: address,
        prev_lp_balance: u64,
        clock: &Clock,
    ): u64 {
        abort 0;
    }

    /// Settles an individual account's rewards by calculating and crediting earned tokens
    fun settle_account_reward<T, R>(
        rewarder: &mut Rewarder<T, R>,
        account: address,
        prev_lp_balance: u64,
        clock: &Clock,
    ): u64 {
        abort 0;
    }

    // === Test Functions ===
    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        abort 0;
    }
}
