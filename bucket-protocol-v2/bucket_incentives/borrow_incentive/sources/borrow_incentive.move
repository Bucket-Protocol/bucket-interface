module bucket_v2_borrow_incentive::borrow_incentive {
    use bucket_v2_borrow_incentive::borrow_incentive_events as events;
    use bucket_v2_cdp::{request::UpdateRequest, vault::Vault};
    use bucket_v2_framework::{account::{Self, AccountRequest}, double::{Self, Double}};
    use sui::{
        balance::{Self, Balance},
        clock::Clock,
        coin::Coin,
        table::{Self, Table},
        vec_set::{Self, VecSet}
    };

    /// Constants

    const PACKAGE_VERSION: u16 = 1;

    public fun package_version(): u16 { PACKAGE_VERSION }

    /// Errors

    const EInvalidRewarder: u64 = 201;

    fun err_invalid_rewarder() { abort EInvalidRewarder }

    const EMissingRewarderCheck: u64 = 202;

    fun err_missing_rewarder_check() { abort EMissingRewarderCheck }

    const EInvalidTimestamp: u64 = 203;

    fun err_invalid_timestamp() { abort EInvalidTimestamp }

    const EWrongVault: u64 = 204;

    fun err_wrong_vault() { abort EWrongVault }

    const EInvalidPackageVersion: u64 = 205;

    fun err_invalid_package_version() { abort EInvalidPackageVersion }

    const ESenderIsNotManager: u64 = 206;

    fun err_sender_is_not_manager() { abort ESenderIsNotManager }

    /// Witness

    public struct BucketV2BorrowIncentive has drop {}

    /// Struct

    public struct StakeData<phantom R> has store {
        unit: Double,
        reward: Balance<R>,
    }

    /// Objects

    public struct AdminCap has key, store {
        id: UID,
    }

    public struct VaultRewarderRegistry has key {
        id: UID,
        vault_rewarders: Table<ID, VecSet<ID>>,
        versions: VecSet<u16>,
        managers: VecSet<address>,
    }

    public struct VaultRewarder<phantom R> has key {
        id: UID,
        vault_id: ID,
        source: Balance<R>,
        pool: Balance<R>,
        flow_rate: Double,
        stake_table: Table<address, StakeData<R>>,
        unit: Double,
        timestamp: u64,
    }

    /// Hot potato

    public struct RequestChecker<phantom T> {
        vault_id: ID,
        rewarder_ids: VecSet<ID>,
        request: UpdateRequest<T>,
    }

    /// Init

    fun init(ctx: &mut TxContext) {
        abort 0;
    }

    /// Admin Funs

    public fun create<T, R>(
        registry: &mut VaultRewarderRegistry,
        _cap: &AdminCap,
        vault: &Vault<T>,
        flow_amount: u64,
        flow_interval: u64,
        start_timestamp: u64,
        ctx: &mut TxContext,
    ) {
        abort 0;
    }

    public fun withdraw_from_source<T, R>(
        registry: &VaultRewarderRegistry,
        rewarder: &mut VaultRewarder<R>,
        vault: &Vault<T>,
        _cap: &AdminCap,
        clock: &Clock,
        amount: u64,
        ctx: &mut TxContext,
    ): Coin<R> {
        abort 0;
    }

    /// Admin Funs

    public fun add_version(registry: &mut VaultRewarderRegistry, _cap: &AdminCap, version: u16) {
        abort 0;
    }

    public fun remove_version(registry: &mut VaultRewarderRegistry, _cap: &AdminCap, version: u16) {
        abort 0;
    }

    public fun add_manager(
        registry: &mut VaultRewarderRegistry,
        _cap: &AdminCap,
        manager: address,
    ) {
        abort 0;
    }

    public fun remove_manager(
        registry: &mut VaultRewarderRegistry,
        _cap: &AdminCap,
        manager: address,
    ) {
        abort 0;
    }

    /// Manager Funs

    public fun update_flow_rate<T, R>(
        registry: &VaultRewarderRegistry,
        rewarder: &mut VaultRewarder<R>,
        vault: &Vault<T>,
        clock: &Clock,
        flow_amount: u64,
        flow_interval: u64,
        request: &AccountRequest,
    ) {
        abort 0;
    }

    public fun update_rewarder_timestamp<T, R>(
        registry: &VaultRewarderRegistry,
        rewarder: &mut VaultRewarder<R>,
        vault: &Vault<T>,
        clock: &Clock,
        timestamp: u64,
        request: &AccountRequest,
    ) {
        abort 0;
    }

    /// Public Fun

    public fun deposit_to_source<R>(rewarder: &mut VaultRewarder<R>, coin: Coin<R>) {
        abort 0;
    }

    public fun deposit_to_pool<R>(rewarder: &mut VaultRewarder<R>, coin: Coin<R>) {
        abort 0;
    }

    public fun new_checker<T>(
        registry: &VaultRewarderRegistry,
        request: UpdateRequest<T>,
    ): RequestChecker<T> {
        abort 0;
    }

    public fun update<T, R>(
        registry: &VaultRewarderRegistry,
        checker: &mut RequestChecker<T>,
        vault: &Vault<T>,
        rewarder: &mut VaultRewarder<R>,
        clock: &Clock,
    ) {
        abort 0;
    }

    public fun destroy_checker<T>(
        registry: &VaultRewarderRegistry,
        checker: RequestChecker<T>,
    ): UpdateRequest<T> {
        abort 0;
    }

    public fun claim<T, R>(
        registry: &VaultRewarderRegistry,
        rewarder: &mut VaultRewarder<R>,
        vault: &Vault<T>,
        request: &AccountRequest,
        clock: &Clock,
        ctx: &mut TxContext,
    ): Coin<R> {
        abort 0;
    }

    /// Getter Funs

    public fun id<R>(rewarder: &VaultRewarder<R>): ID {
        abort 0;
    }

    public fun stake_exists<R>(rewarder: &VaultRewarder<R>, account: address): bool {
        abort 0;
    }

    public fun realtime_reward_amount<T, R>(
        rewarder: &VaultRewarder<R>,
        vault: &Vault<T>,
        account: address,
        clock: &Clock,
    ): u64 {
        abort 0;
    }

    /// Entry Funs

    entry fun withdraw_from_source_to<T, R>(
        registry: &VaultRewarderRegistry,
        rewarder: &mut VaultRewarder<R>,
        vault: &Vault<T>,
        cap: &AdminCap,
        clock: &Clock,
        amount: u64,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        abort 0;
    }

    entry fun deposit_to_source_and_set_flow_rate<T, R>(
        registry: &VaultRewarderRegistry,
        rewarder: &mut VaultRewarder<R>,
        vault: &Vault<T>,
        clock: &Clock,
        coin: Coin<R>,
        flow_interval: u64,
        ctx: &TxContext,
    ) {
        abort 0;
    }

    entry fun set_flow_rate<T, R>(
        registry: &VaultRewarderRegistry,
        rewarder: &mut VaultRewarder<R>,
        vault: &Vault<T>,
        clock: &Clock,
        flow_amount: u64,
        flow_interval: u64,
        ctx: &TxContext,
    ) {
        abort 0;
    }

    entry fun set_rewarder_timestamp<T, R>(
        registry: &VaultRewarderRegistry,
        rewarder: &mut VaultRewarder<R>,
        vault: &Vault<T>,
        clock: &Clock,
        timestamp: u64,
        ctx: &TxContext,
    ) {
        abort 0;
    }

    /// Internal Funs

    fun realtime_rewarder_release_and_unit<T, R>(
        rewarder: &VaultRewarder<R>,
        vault: &Vault<T>,
        clock: &Clock,
    ): (u64, Double, bool) {
        abort 0;
    }

    fun source_to_pool<T, R>(rewarder: &mut VaultRewarder<R>, vault: &Vault<T>, clock: &Clock) {
        abort 0;
    }

    fun unsettled_reward_amount<T, R>(
        rewarder: &VaultRewarder<R>,
        vault: &Vault<T>,
        account: address,
        clock: &Clock,
    ): u64 {
        abort 0;
    }

    fun settle_reward<T, R>(
        rewarder: &mut VaultRewarder<R>,
        vault: &Vault<T>,
        account: address,
        clock: &Clock,
    ): u64 {
        abort 0;
    }

    fun assert_unchecked_rewarder<T, R>(checker: &RequestChecker<T>, rewarder: &VaultRewarder<R>) {
        abort 0;
    }

    fun assert_correct_vault<T, R>(rewarder: &VaultRewarder<R>, vault: &Vault<T>) {
        abort 0;
    }

    fun assert_valid_package_version(registry: &VaultRewarderRegistry) {
        abort 0;
    }

    fun assert_sender_is_manager(registry: &VaultRewarderRegistry, request: &AccountRequest) {
        abort 0;
    }

    /// Test-only Funs

    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        abort 0;
    }
}
