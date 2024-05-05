module v1_core_interface::buck_events {

    // ----- Use Statements -----

    use std::ascii;
    use sui::object;

    // ----- Structs -----

    struct BuckBurnt has copy, drop {
        collateral_type: ascii::String,
        buck_amount: u64,
    }

    struct BuckMinted has copy, drop {
        collateral_type: ascii::String,
        buck_amount: u64,
    }

    struct CollateralDecreased has copy, drop {
        collateral_type: ascii::String,
        collateral_amount: u64,
    }

    struct CollateralIncreased has copy, drop {
        collateral_type: ascii::String,
        collateral_amount: u64,
    }

    struct FlashLoan has copy, drop {
        coin_type: ascii::String,
        amount: u64,
    }

    struct FlashMint has copy, drop {
        config_id: object::ID,
        mint_amount: u64,
        fee_amount: u64,
    }

    struct ParamUpdated<phantom T0> has copy, drop {
        param_name: ascii::String,
        new_value: u64,
    }
    // ----- Public Functions -----

    public(friend) fun emit_buck_burnt<T0>(arg0: u64) {
        abort 0
    }

    public(friend) fun emit_buck_minted<T0>(arg0: u64) {
        abort 0
    }

    public(friend) fun emit_collateral_decreased<T0>(arg0: u64) {
        abort 0
    }

    public(friend) fun emit_collateral_increased<T0>(arg0: u64) {
        abort 0
    }

    public(friend) fun emit_flash_loan<T0>(arg0: u64) {
        abort 0
    }

    public(friend) fun emit_flash_mint(arg0: object::ID, arg1: u64, arg2: u64) {
        abort 0
    }

    public(friend) fun emit_param_updated<T0>(arg0: vector<u8>, arg1: u64) {
        abort 0
    }
}
