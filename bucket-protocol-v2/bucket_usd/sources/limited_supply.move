/// Module for managing a limited supply of tokens or assets.
/// Provides functionality to create, increase, decrease, and destroy a supply with an upper limit.
module bucket_v2_usd::limited_supply {
    const EDestroyNonEmptySupply: u64 = 101;

    fun err_destroy_non_empty_supply() { abort EDestroyNonEmptySupply }

    const ESupplyExceedLimit: u64 = 102;

    fun err_exceed_limit() { abort ESupplyExceedLimit }

    const ESupplyNotEnough: u64 = 103;

    fun err_supply_not_enough() { abort ESupplyNotEnough }

    /// Struct representing a limited supply with a maximum limit and current supply.
    public struct LimitedSupply has store {
        /// The maximum allowed supply.
        limit: u64,
        /// The current supply.
        supply: u64,
    }

    /// Creates a new LimitedSupply with the given limit and zero initial supply.
    public fun new(limit: u64): LimitedSupply {
        abort 0
    }

    /// Destroys the LimitedSupply. Aborts if the supply is not zero.
    public fun destroy(self: LimitedSupply) {
        abort 0
    }

    /// Increases the supply by the given amount. Aborts if the new supply exceeds the limit.
    /// Returns the new supply.
    public fun increase(self: &mut LimitedSupply, amount: u64): u64 {
        abort 0
    }

    /// Decreases the supply by the given amount. Aborts if the supply is not enough.
    /// Returns the new supply.
    public fun decrease(self: &mut LimitedSupply, amount: u64): u64 {
        abort 0
    }

    /// Sets a new limit for the supply.
    public fun set_limit(self: &mut LimitedSupply, limit: u64) {
        abort 0
    }

    /// Returns the limit of the supply.
    public fun limit(self: &LimitedSupply): u64 {
        self.limit
    }

    /// Returns the current supply.
    public fun supply(self: &LimitedSupply): u64 {
        self.supply
    }

    public fun increasable_amount(self: &LimitedSupply): u64 {
        abort 0
    }

    /// Returns true if the supply can be increased by the given amount without exceeding the limit.
    public fun is_increasable(self: &LimitedSupply, amount: u64): bool {
        abort 0
    }

    /// Destroys the LimitedSupply for testing purposes, ignoring the supply value.
    #[test_only]
    public fun destroy_for_testing(self: LimitedSupply) {
        abort 0
    }

    /// Unit test: checks that decreasing supply below zero aborts with the correct error code.
    #[test, expected_failure(abort_code = ESupplyNotEnough)]
    fun test_supply_not_enough() {
        abort 0
    }
}
