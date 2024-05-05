module v1_core_interface::well_events {

    // ----- Use Statements -----

    use std::ascii;
    use sui::balance;

    // ----- Structs -----

    struct Claim has copy, drop {
        well_type: ascii::String,
        reward_amount: u64,
    }

    struct CollectFee has copy, drop {
        well_type: ascii::String,
        fee_amount: u64,
    }

    struct CollectFeeFrom has copy, drop {
        well_type: ascii::String,
        fee_amount: u64,
        from: ascii::String,
    }

    struct Penalty has copy, drop {
        well_type: ascii::String,
        penalty_amount: u64,
    }

    struct Stake has copy, drop {
        well_type: ascii::String,
        stake_amount: u64,
        stake_weight: u64,
        lock_time: u64,
    }

    struct Unstake has copy, drop {
        well_type: ascii::String,
        unstake_amount: u64,
        unstake_weigth: u64,
        reward_amount: u64,
    }
    // ----- Public Functions -----

    public(friend) fun emit_claim<T0>(arg0: u64) {
        abort 0
    }

    public(friend) fun emit_collect_fee<T0>(arg0: u64) {
        abort 0
    }

    public(friend) fun emit_collect_fee_from<T0>(arg0: &balance::Balance<T0>, arg1: vector<u8>) {
        abort 0
    }

    public(friend) fun emit_penalty<T0>(arg0: u64) {
        abort 0
    }

    public(friend) fun emit_stake<T0>(arg0: u64, arg1: u64, arg2: u64) {
        abort 0
    }

    public(friend) fun emit_unstake<T0>(arg0: u64, arg1: u64, arg2: u64) {
        abort 0
    }
}
