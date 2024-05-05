module v1_interface::bucket_events {

    // ----- Use Statements -----

    use std::ascii;
    use sui::object;
    use 0xce7ff77a83ea0cb6fd39bd8748e2ec89a3f41e8efdc3f4eb123e0ca37b184db2::bottle;

    // ----- Structs -----

    struct BottleCreated has copy, drop {
        collateral_type: ascii::String,
        debtor: address,
        bottle_id: object::ID,
        collateral_amount: u64,
        buck_amount: u64,
    }

    struct BottleDestroyed has copy, drop {
        collateral_type: ascii::String,
        debtor: address,
        bottle_id: object::ID,
    }

    struct BottleUpdated has copy, drop {
        collateral_type: ascii::String,
        debtor: address,
        bottle_id: object::ID,
        collateral_amount: u64,
        buck_amount: u64,
    }

    struct FeeRateChanged has copy, drop {
        collateral_type: ascii::String,
        base_fee_rate: u64,
    }

    struct Redeem has copy, drop {
        collateral_type: ascii::String,
        input_buck_amount: u64,
        output_collateral_amount: u64,
    }

    struct Redistribution has copy, drop {
        collateral_type: ascii::String,
    }

    struct SurplusBottleGenerated has copy, drop {
        collateral_type: ascii::String,
        debtor: address,
        bottle_id: object::ID,
        collateral_amount: u64,
    }

    struct SurplusBottleWithdrawal has copy, drop {
        collateral_type: ascii::String,
        debtor: address,
        bottle_id: object::ID,
    }
    // ----- Public Functions -----

    public(friend) fun emit_bottle_created<T0>(arg0: address, arg1: &bottle::Bottle) {
        abort 0
    }

    public(friend) fun emit_bottle_destroyed<T0>(arg0: address, arg1: &bottle::Bottle) {
        abort 0
    }

    public(friend) fun emit_bottle_updated<T0>(arg0: address, arg1: &bottle::Bottle) {
        abort 0
    }

    public(friend) fun emit_fee_rate_changed<T0>(arg0: u64) {
        abort 0
    }

    public(friend) fun emit_redeem<T0>(arg0: u64, arg1: u64) {
        abort 0
    }

    public(friend) fun emit_redistribution<T0>() {
        abort 0
    }

    public(friend) fun emit_surplus_bottle_generated<T0>(arg0: address, arg1: &bottle::Bottle) {
        abort 0
    }

    public(friend) fun emit_surplus_bottle_withdrawal<T0>(arg0: address, arg1: &bottle::Bottle) {
        abort 0
    }
}
