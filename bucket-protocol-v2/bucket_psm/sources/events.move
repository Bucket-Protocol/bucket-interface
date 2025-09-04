module bucket_v2_psm::events {

    use std::ascii::String;
    use std::type_name::{get};
    use sui::event::emit;

    public struct NewPsmPool has copy, drop {
        pool_id: ID,
        coin_type: String,
        decimal: u8,
        swap_in_fee_bps: u64,
        swap_out_fee_bps: u64,
    }

    public(package) fun emit_new_pool<T>(
        pool_id: ID,
        decimal: u8,
        swap_in_fee_bps: u64,
        swap_out_fee_bps: u64,
    ) {
        emit(NewPsmPool {
            pool_id,
            coin_type: get<T>().into_string(),
            decimal,
            swap_in_fee_bps,
            swap_out_fee_bps,
        });
    }

    public struct PsmSwapIn has copy, drop {
        asset_type: String,
        asset_in_amount: u64,
        asset_balance: u64,
        usdb_out_amount: u64,
        usdb_supply: u64,
    }

    public(package) fun emit_swap_in<T>(
        asset_in_amount: u64,
        asset_balance: u64,
        usdb_out_amount: u64,
        usdb_supply: u64,
    ) {
        emit(PsmSwapIn {
            asset_type: get<T>().into_string(),
            asset_in_amount: asset_in_amount,
            asset_balance,
            usdb_out_amount: usdb_out_amount,
            usdb_supply,
        });
    }

    public struct PsmSwapOut has copy, drop {
        usdb_in_amount: u64,
        usdb_supply: u64,
        asset_type: String,
        asset_out_amount: u64,
        asset_balance: u64,
    }

    public(package) fun emit_swap_out<T>(
        usdb_in_amount: u64,
        usdb_supply: u64,
        asset_out_amount: u64,
        asset_balance: u64,
    ) {
        emit(PsmSwapOut {
            usdb_in_amount,
            usdb_supply,
            asset_type: get<T>().into_string(),
            asset_out_amount,
            asset_balance,
        });
    }
}
