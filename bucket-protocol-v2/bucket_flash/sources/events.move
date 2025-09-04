module bucket_v2_flash::events {
    use sui::event::emit;

    public struct UpdateFlashMintConfig has copy, drop {
        config_id: ID,
        partner_address: Option<address>,
        fee_rate_bps: u64,
        max_amount: u64,
    }

    public(package) fun emit_update_flash_mint_config(
        config_id: ID,
        partner_address: Option<address>,
        fee_rate_bps: u64,
        max_amount: u64,
    ) {
        emit(UpdateFlashMintConfig {
            config_id,
            partner_address,
            fee_rate_bps,
            max_amount,
        })
    }

    public struct FlashMint has copy, drop {
        partner_address: Option<address>,
        value: u64,
        fee_amount: u64,
    }

    public(package) fun emit_flash_mint(
        partner_address: Option<address>,
        value: u64,
        fee_amount: u64,
    ) {
        emit(FlashMint {
            partner_address,
            value,
            fee_amount,
        })
    }
}
