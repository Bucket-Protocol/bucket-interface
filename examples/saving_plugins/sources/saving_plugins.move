/// Module: saving_plugins
module saving_plugins::withdraw_requests {
    use bucket_v2_framework::account::{Self, Account};
    use bucket_v2_oracle::result::PriceResult;
    use bucket_v2_psm::pool::Pool;
    use bucket_v2_saving::saving::{DepositResponse, WithdrawResponse, SavingPool};
    use bucket_v2_usd::{admin::AdminCap, usdb::{USDB, Treasury}};
    use std::ascii::String;
    use sui::{
        balance::Balance,
        clock::Clock,
        coin::{Self, Coin},
        event::emit,
        linked_table::{Self, LinkedTable},
        vec_set::{Self, VecSet}
    };

    const VERSION: u64 = 001;

    public fun version(): u64 { VERSION }

    const EInvalidPackageVersion: u64 = 101;
    const ENotManager: u64 = 102;
    const EUnmatchedWithdrawalAmount: u64 = 103;

    /// Witness type for providing feature for make user withdraw with approval
    public struct SavingPoolWithdrawWithRequest<phantom T> has drop {}

    public struct Request has store {
        owner: address,
        withdrawal: Balance<USDB>,
    }

    public struct WithdrawRequestPlugin<phantom T> has key, store {
        id: UID,
        version: VecSet<u64>,
        account: Account,
        managers: VecSet<address>,
        pending_requests: LinkedTable<u64, Request>,
        counter: u64,
    }

    public fun account_address<T>(self: &WithdrawRequestPlugin<T>): address {
        self.account.address()
    }

    public fun managers<T>(self: &WithdrawRequestPlugin<T>): vector<address> {
        *self.managers.keys()
    }

    // === Events ===
    public struct DepositEvent<phantom T> has copy, drop, store {
        user_id: String,
        sender: address,
        amount: u64,
        timestamp: u64,
    }

    public struct RequestWithdraEvent<phantom T> has copy, drop, store {
        owner: address,
        amount: u64,
        timestamp: u64,
    }

    public struct FulfillWithdraEvent<phantom T> has copy, drop, store {
        user_id: String,
        owner: address,
        amount: u64,
        timestamp: u64,
    }

    // === Admin Functions ===
    public fun new<T>(_cap: &AdminCap, ctx: &mut TxContext): WithdrawRequestPlugin<T> {
        WithdrawRequestPlugin<T> {
            id: object::new(ctx),
            version: vec_set::singleton(VERSION),
            account: account::new(option::none(), ctx),
            managers: vec_set::singleton(ctx.sender()),
            pending_requests: linked_table::new(ctx),
            counter: 0,
        }
    }

    public fun default<T>(_cap: &AdminCap, ctx: &mut TxContext) {
        transfer::public_share_object(new<T>(_cap, ctx))
    }

    public fun add_version<T>(self: &mut WithdrawRequestPlugin<T>, _cap: &AdminCap, version: u64) {
        self.version.insert(version);
    }

    public fun remove_version<T>(
        self: &mut WithdrawRequestPlugin<T>,
        _cap: &AdminCap,
        version: u64,
    ) {
        self.version.remove(&version);
    }

    public fun add_manager<T>(
        self: &mut WithdrawRequestPlugin<T>,
        _cap: &AdminCap,
        manager: address,
    ) {
        self.managers.insert(manager);
    }

    public fun remove_manager<T>(
        self: &mut WithdrawRequestPlugin<T>,
        _cap: &AdminCap,
        manager: address,
    ) {
        self.managers.remove(&manager);
    }

    // === View Function ===

    public struct RequestData has copy, drop {
        request_id: u64,
        owner: address,
        withdrawal: u64,
    }

    public fun request_index(data: &RequestData): u64 {
        data.request_id
    }

    public fun request_owner(data: &RequestData): address { data.owner }

    public fun request_withdrawal(data: &RequestData): u64 { data.withdrawal }

    public use fun request_index as RequestData.request_id;
    public use fun request_owner as RequestData.owner;
    public use fun request_withdrawal as RequestData.withdrawal;

    public fun get_requests<T>(
        self: &WithdrawRequestPlugin<T>,
        mut cursor: Option<u64>,
        size: u64,
    ): (vector<RequestData>, Option<u64>) {
        let mut info_vec = vector[];
        if (cursor.is_none()) {
            cursor = *self.pending_requests.front();
        };

        let mut counter = 0;
        while (cursor.is_some() && counter < size) {
            let request_id = cursor.extract();
            let req = &self.pending_requests[request_id];
            info_vec.push_back(RequestData {
                request_id,
                owner: req.owner,
                withdrawal: req.withdrawal.value(),
            });
            counter = counter + 1;
            cursor = *self.pending_requests.next(request_id);
        };
        (info_vec, cursor)
    }

    // === Public Function ===

    public fun deposit<T, StableCoin>(
        self: &WithdrawRequestPlugin<T>,
        user_id: String,
        // psm
        pool: &mut Pool<StableCoin>,
        treasury: &mut Treasury,
        price: &PriceResult<StableCoin>,
        // saving_pool params
        saving_pool: &mut SavingPool<T>,
        stable: Coin<StableCoin>,
        clock: &Clock,
        ctx: &mut TxContext,
    ): DepositResponse<T> {
        self.assert_version();

        // psm swap_in
        let usdb = pool.swap_in(
            treasury,
            price,
            stable,
            &option::some(self.account.request()),
            ctx,
        );

        // deposit to saving_pool
        let mut deposit_response = saving_pool.deposit(treasury, ctx.sender(), usdb, clock, ctx);

        deposit_response.add_deposit_witness(SavingPoolWithdrawWithRequest<T> {});

        emit(DepositEvent<T> {
            user_id,
            sender: ctx.sender(),
            amount: deposit_response.deposited_usdb_amount(),
            timestamp: clock.timestamp_ms(),
        });

        deposit_response
    }

    public fun request_withdraw<T>(
        self: &mut WithdrawRequestPlugin<T>,
        withdraw_response: &mut WithdrawResponse<T>,
        usdb: Coin<USDB>,
        clock: &Clock,
    ) {
        self.assert_version();
        assert!(
            usdb.value() == withdraw_response.withdrawal_usdb_amount(),
            EUnmatchedWithdrawalAmount,
        );

        let owner = withdraw_response.account();
        emit(RequestWithdraEvent<T> {
            owner,
            amount: withdraw_response.withdrawal_usdb_amount(),
            timestamp: clock.timestamp_ms(),
        });

        // add request
        let current_counter = self.counter;
        self
            .pending_requests
            .push_back(
                current_counter,
                Request { owner, withdrawal: usdb.into_balance() },
            );

        self.counter = self.counter + 1;

        withdraw_response.add_withdraw_witness(SavingPoolWithdrawWithRequest<T> {});
    }

    public fun approve_withdraw<T, StableCoin>(
        self: &mut WithdrawRequestPlugin<T>,
        request_id: u64,
        user_id: String,
        // psm params
        pool: &mut Pool<StableCoin>,
        treasury: &mut Treasury,
        price: &PriceResult<StableCoin>,
        clock: &Clock,
        ctx: &mut TxContext,
    ) {
        self.assert_version();
        assert!(self.managers.contains(&ctx.sender()), ENotManager);

        if (self.pending_requests.contains(request_id)) {
            let Request {
                owner,
                withdrawal,
            } = self.pending_requests.remove(request_id);

            emit(FulfillWithdraEvent<T> {
                user_id,
                owner,
                amount: withdrawal.value(),
                timestamp: clock.timestamp_ms(),
            });

            // convert USDB to USDC through PSM
            let stable_coin = pool.swap_out(
                treasury,
                price,
                coin::from_balance(withdrawal, ctx),
                &option::some(self.account.request()),
                ctx,
            );
            // hardcoded recipient
            transfer::public_transfer(stable_coin, owner);
        };
    }

    fun assert_version<T>(self: &WithdrawRequestPlugin<T>) {
        assert!(self.version.contains(&version()), EInvalidPackageVersion);
    }
}
