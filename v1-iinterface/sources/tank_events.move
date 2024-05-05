module v1_interface::tank_events {

    // ----- Use Statements -----

    use std::ascii;

    // ----- Structs -----

    struct Absorb has copy, drop {
        tank_type: ascii::String,
        buck_amount: u64,
        collateral_amount: u64,
    }

    struct CollectBKT has copy, drop {
        tank_type: ascii::String,
        bkt_amount: u64,
    }

    struct Deposite has copy, drop {
        tank_type: ascii::String,
        buck_amount: u64,
    }

    struct TankUpdate has copy, drop {
        tank_type: ascii::String,
        current_epoch: u64,
        current_scale: u64,
        current_p: u64,
    }

    struct Withdraw has copy, drop {
        tank_type: ascii::String,
        buck_amount: u64,
        collateral_amount: u64,
        bkt_amount: u64,
    }
    // ----- Public Functions -----

    public(friend) fun emit_absorb<T0>(arg0: u64, arg1: u64) {
        abort 0
    }

    public(friend) fun emit_collect_bkt<T0>(arg0: u64) {
        abort 0
    }

    public(friend) fun emit_deposit<T0>(arg0: u64) {
        abort 0
    }

    public(friend) fun emit_tank_update<T0>(arg0: u64, arg1: u64, arg2: u64) {
        abort 0
    }

    public(friend) fun emit_withdraw<T0>(arg0: u64, arg1: u64, arg2: u64) {
        abort 0
    }
}
