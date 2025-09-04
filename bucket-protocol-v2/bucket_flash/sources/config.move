module bucket_v2_flash::config {
    use bucket_v2_flash::{events, memo, version::package_version, witness::witness};
    use bucket_v2_framework::{account::AccountRequest, float::{Self, Float}};
    use bucket_v2_usd::{admin::AdminCap, usdb::{USDB, Treasury}};
    use sui::{coin::Coin, vec_map::{Self, VecMap}};

    // === Errors ===

    const EExceedMaxAmount: u64 = 401;

    fun err_exceed_max_amount() { abort EExceedMaxAmount }

    const ERepaymentNotEnough: u64 = 402;

    fun err_repayment_not_enough() { abort ERepaymentNotEnough }

    // === Objects ===

    public struct GlobalConfig has key {
        id: UID,
        default_config: Config,
        partner_configs: VecMap<address, Config>,
    }

    // === Structs ===

    public struct Config has copy, drop, store {
        fee_rate: Float,
        max_amount: u64,
        total_amount: u64,
    }

    // Hot-potato
    public struct FlashMintReceipt {
        partner: Option<address>,
        mint_amount: u64,
        fee_amount: u64,
    }

    // === Init ===

    fun init(ctx: &mut TxContext) {
        abort 0;
    }

    // === Admin Functions ===

    public fun set_flash_config(
        self: &mut GlobalConfig,
        _: &AdminCap,
        partner: Option<address>,
        fee_rate_bps: u64,
        max_amount: u64,
    ) {
        abort 0;
    }

    // === Public Functions ===

    public fun flash_mint(
        self: &mut GlobalConfig,
        treasury: &mut Treasury,
        partner: &Option<AccountRequest>,
        value: u64,
        ctx: &mut TxContext,
    ): (Coin<USDB>, FlashMintReceipt) {
        abort 0;
    }

    public fun flash_burn(
        self: &mut GlobalConfig,
        treasury: &mut Treasury,
        mut repayment: Coin<USDB>,
        receipt: FlashMintReceipt,
    ) {
        abort 0;
    }

    // === View Functions ===

    public fun config(self: &GlobalConfig, partner_opt: Option<address>): Config {
        if (partner_opt.is_some()) self.partner_configs[partner_opt.borrow()]
        else self.default_config
    }

    public fun fee_rate(self: &GlobalConfig, partner_opt: Option<address>): Float {
        self.config(partner_opt).fee_rate
    }

    public fun max_amount(self: &GlobalConfig, partner_opt: Option<address>): u64 {
        self.config(partner_opt).max_amount
    }

    public fun total_amount(self: &GlobalConfig, partner_opt: Option<address>): u64 {
        self.config(partner_opt).total_amount
    }

    public fun mint_amount(receipt: &FlashMintReceipt): u64 {
        receipt.mint_amount
    }

    public fun fee_amount(receipt: &FlashMintReceipt): u64 {
        receipt.fee_amount
    }

    // === Test-Only Functions ===

    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(ctx)
    }
}
