module v1_core_interface::reservoir_events {

    // ----- Structs -----

    struct ChargeReservior<phantom T0> has copy, drop {
        inflow_amount: u64,
        buck_amount: u64,
    }

    struct DischargeReservior<phantom T0> has copy, drop {
        outflow_amount: u64,
        buck_amount: u64,
    }
    // ----- Public Functions -----

    public(friend) fun emit_charge_reservoir<T0>(arg0: u64, arg1: u64) {
        abort 0
    }

    public(friend) fun emit_discharge_reservoir<T0>(arg0: u64, arg1: u64) {
        abort 0
    }
}
