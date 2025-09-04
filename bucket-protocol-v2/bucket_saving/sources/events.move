module bucket_v2_saving::events {
    use sui::event::emit;

    public struct NewSavingPoolEvent<phantom T> has copy, drop {
        saving_pool_id: ID,
    }

    public(package) fun emit_new_saving_pool_event<T>(saving_pool_id: ID) {
        emit(NewSavingPoolEvent<T> { saving_pool_id })
    }

    public struct UpdateSavingRateEvent<phantom T> has copy, drop {
        saving_pool_id: ID,
        saving_rate_bps: u64,
    }

    public(package) fun emit_update_saving_rate_event<T>(saving_pool_id: ID, saving_rate_bps: u64) {
        emit(UpdateSavingRateEvent<T> { saving_pool_id, saving_rate_bps })
    }

    public struct DepositEvent<phantom T> has copy, drop {
        saving_pool_id: ID,
        account_address: address,
        deposited_usdb_amount: u64,
        minted_lp_amount: u64,
    }

    public(package) fun emit_deposit_event<T>(
        saving_pool_id: ID,
        account_address: address,
        deposited_usdb_amount: u64,
        minted_lp_amount: u64,
    ) {
        emit(DepositEvent<T> {
            saving_pool_id,
            account_address,
            deposited_usdb_amount,
            minted_lp_amount,
        })
    }

    public struct WithdrawEvent<phantom T> has copy, drop {
        saving_pool_id: ID,
        account_address: address,
        burned_lp_amount: u64,
        withdrawal_usdb_amount: u64,
    }

    public(package) fun emit_withdraw_event<T>(
        saving_pool_id: ID,
        account_address: address,
        burned_lp_amount: u64,
        withdrawal_usdb_amount: u64,
    ) {
        emit(WithdrawEvent<T> {
            saving_pool_id,
            account_address,
            burned_lp_amount,
            withdrawal_usdb_amount,
        })
    }

    public struct InterestEmittedEvent<phantom T> has copy, drop {
        saving_pool_id: ID,
        interest_amount: u64,
    }

    public(package) fun emit_interest_emitted_event<T>(saving_pool_id: ID, interest_amount: u64) {
        emit(InterestEmittedEvent<T> { saving_pool_id, interest_amount })
    }
}
