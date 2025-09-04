module bucket_v2_psm::pool {
    use bucket_v2_framework::{account::AccountRequest, float::{Self, Float}, sheet::{Self, Sheet}};
    use bucket_v2_oracle::result::PriceResult;
    use bucket_v2_psm::{
        events,
        memo,
        version::{Self, package_version},
        witness::{witness, BucketV2PSM}
    };
    use bucket_v2_usd::{admin::AdminCap, usdb::{Treasury, USDB, decimal as usdb_decimal}};
    use sui::{balance::{Self, Balance}, coin::Coin, vec_map::{Self, VecMap}};

    /// Errors

    const EPoolNotEnough: u64 = 401;

    fun err_pool_not_enough() { abort EPoolNotEnough }

    const EFluctuatingPrice: u64 = 402;

    fun err_fluctuating_price() { abort EFluctuatingPrice }

    /// Struct

    public struct FeeConfig has copy, drop, store {
        swap_in_fee_rate: Float,
        swap_out_fee_rate: Float,
    }

    /// Objects

    public struct Pool<phantom T> has key, store {
        id: UID,
        // configs
        decimal: u8,
        default_fee_config: FeeConfig,
        partner_fee_configs: VecMap<address, FeeConfig>,
        price_tolerance: Float,
        // states
        balance: Balance<T>,
        balance_amount: u64,
        usdb_supply: u64,
        sheet: Sheet<T, BucketV2PSM>,
    }

    /// Admin Funs

    public fun new<T>(
        treasury: &Treasury,
        _cap: &AdminCap,
        decimal: u8,
        swap_in_fee_rate_bps: u64,
        swap_out_fee_rate_bps: u64,
        price_tolerance_bps: u64,
        ctx: &mut TxContext,
    ): Pool<T> {
        abort 0
    }

    #[allow(lint(share_owned))]
    public fun create<T>(
        treasury: &Treasury,
        _cap: &AdminCap,
        decimal: u8,
        swap_in_fee_rate_bps: u64,
        swap_out_fee_rate_bps: u64,
        price_tolerance_bps: u64,
        ctx: &mut TxContext,
    ) {
        abort 0
    }

    public fun set_fee_config<T>(
        pool: &mut Pool<T>,
        _cap: &AdminCap,
        partner: Option<address>,
        swap_in_fee_rate_bps: u64,
        swap_out_fee_rate_bps: u64,
    ) {
        abort 0
    }

    public fun set_price_tolerance<T>(pool: &mut Pool<T>, _cap: &AdminCap, tolerance_bps: u64) {
        abort 0
    }

    /// Public Funs

    public fun swap_in<T>(
        pool: &mut Pool<T>,
        treasury: &mut Treasury,
        price: &PriceResult<T>,
        asset_coin: Coin<T>,
        partner: &Option<AccountRequest>,
        ctx: &mut TxContext,
    ): Coin<USDB> {
        abort 0
    }

    public fun swap_out<T>(
        pool: &mut Pool<T>,
        treasury: &mut Treasury,
        price: &PriceResult<T>,
        usdb_coin: Coin<USDB>,
        partner: &Option<AccountRequest>,
        ctx: &mut TxContext,
    ): Coin<T> {
        abort 0
    }

    // Getter Funs

    public fun decimal<T>(pool: &Pool<T>): u8 {
        pool.decimal
    }

    // scaling factor for conversing collateral assets to USDB
    public fun conversion_rate<T>(pool: &Pool<T>): Float {
        abort 0
    }

    public fun swap_in_fee_rate<T>(pool: &Pool<T>, partner: Option<address>): Float {
        abort 0
    }

    public fun swap_out_fee_rate<T>(pool: &Pool<T>, partner: Option<address>): Float {
        abort 0
    }

    public fun balance<T>(pool: &Pool<T>): u64 {
        pool.balance.value()
    }

    public fun balance_amount<T>(pool: &Pool<T>): u64 {
        pool.balance_amount
    }

    public fun usdb_supply<T>(pool: &Pool<T>): u64 {
        pool.usdb_supply
    }

    public fun price_tolerance<T>(pool: &Pool<T>): Float {
        pool.price_tolerance
    }

    /// Internal Funs
    fun swap_in_internal<T>(
        pool: &mut Pool<T>,
        treasury: &mut Treasury,
        asset_coin: Coin<T>,
        fee_rate: Float,
        ctx: &mut TxContext,
    ): Coin<USDB> {
        abort 0
    }

    fun swap_out_internal<T>(
        pool: &mut Pool<T>,
        treasury: &mut Treasury,
        usdb_coin: Coin<USDB>,
        fee_rate: Float,
        ctx: &mut TxContext,
    ): Coin<T> {
        abort 0
    }

    fun check_price<T>(pool: &Pool<T>, price: &PriceResult<T>) {
        abort 0
    }
}
