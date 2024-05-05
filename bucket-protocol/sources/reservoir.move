module bucket_protocol::reservoir {

    // ----- Use Statements -----

    use sui::object;
    use sui::balance;
    use sui::tx_context;

    // ----- public structs -----

    public struct Reservoir<phantom T0> has store, key {
        id: object::UID,
        conversion_rate: u64,
        charge_fee_rate: u64,
        discharge_fee_rate: u64,
        pool: balance::Balance<T0>,
        buck_minted_amount: u64,
    }
    // ----- Public Functions -----

    public fun charge_fee_rate<T0>(arg0: &Reservoir<T0>) : u64 {
        abort 0
    }

    public fun conversion_rate<T0>(arg0: &Reservoir<T0>) : u64 {
        abort 0
    }

    public fun discharge_fee_rate<T0>(arg0: &Reservoir<T0>) : u64 {
        abort 0
    }

    public fun pool_balance<T0>(arg0: &Reservoir<T0>) : u64 {
        abort 0
    }

    public(package) fun handle_charge<T0>(arg0: &mut Reservoir<T0>, arg1: balance::Balance<T0>) : u64 {
        abort 0
    }

    public(package) fun handle_discharge<T0>(arg0: &mut Reservoir<T0>, arg1: u64) : balance::Balance<T0> {
        abort 0
    }

    public(package) fun new<T0>(arg0: u64, arg1: u64, arg2: u64, arg3: &mut tx_context::TxContext) : Reservoir<T0> {
        abort 0
    }

    public(package) fun update_fee_rate<T0>(arg0: &mut Reservoir<T0>, arg1: u64, arg2: u64) {
        abort 0
    }
}
