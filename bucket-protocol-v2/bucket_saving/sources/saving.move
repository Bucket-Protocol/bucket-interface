module bucket_v2_saving::saving {
    use bucket_v2_framework::{account::AccountRequest, double::{Self, Double}};
    use bucket_v2_saving::{events, version::{package_version, assert_valid_package}, witness};
    use bucket_v2_usd::{admin::AdminCap, usdb::{USDB, Treasury}};
    use std::type_name::{get, TypeName};
    use sui::{
        balance::{Self, Balance, Supply},
        clock::Clock,
        coin::{Self, TreasuryCap, Coin},
        table::{Self, Table},
        vec_set::{Self, VecSet}
    };

    // === Errors ===

    const EMissingDepositResponseWitness: u64 = 101;

    fun err_missing_deposit_response_witness() { abort EMissingDepositResponseWitness }

    const EMissingWithdrawResponseWitness: u64 = 102;

    fun err_missing_withdraw_response_witness() { abort EMissingWithdrawResponseWitness }

    const EWitnessAlreadyExists: u64 = 103;

    fun err_witness_already_exists() { abort EWitnessAlreadyExists }

    const EInsufficientDeposit: u64 = 104;

    fun err_insufficient_deposit() { abort EInsufficientDeposit }

    const EAccountNotFound: u64 = 104;

    fun err_account_not_found() { abort EAccountNotFound }

    const EExceedDepositCqp: u64 = 105;

    fun err_exceed_deposit_cap() { abort EExceedDepositCqp }

    const ELockedAccount: u64 = 106;

    fun err_locked_account() { abort ELockedAccount }

    // === Constants ===
    const MS_IN_YEAR: u64 = { 86400 * 52 * 7 * 1000 }; // ms of 52 weeks

    public fun ms_in_year(): u64 { MS_IN_YEAR }

    // === Structs ===

    /// Configuration for saving pool interest calculation
    public struct InterestConfig has store {
        /// Annual interest rate as a Double (basis points converted to decimal)
        saving_rate: Double,
        /// Timestamp (in milliseconds) when interest was last distributed
        last_emitted: u64,
    }

    /// Individual user position in the saving pool
    public struct Position<phantom T> has store {
        /// User's LP token balance in the pool
        balance: Balance<T>,
        /// Timestamp when this position was last updated
        last_update_timestamp: u64,
    }

    /// Main saving pool that holds USDB and issues LP tokens with interest
    public struct SavingPool<phantom T> has key, store {
        /// Unique identifier for this saving pool
        id: UID,
        /// Total supply of LP tokens issued by this pool
        lp_supply: Supply<T>,
        /// Optional maximum deposit limit for the pool
        deposit_cap_amount: Option<u64>,
        /// USDB balance held in the pool reserves
        usdb_reserve_balance: Balance<USDB>,
        /// Mapping of user addresses to their positions
        positions: Table<address, Position<T>>,
        /// Interest rate configuration for the pool
        saving_config: InterestConfig,
        /// Required witness types for deposit operations
        deposit_response_checklist: VecSet<TypeName>,
        /// Required witness types for withdraw operations
        withdraw_response_checklist: VecSet<TypeName>,
        /// Set of addresses with locked positions (ongoing operations)
        position_locker: VecSet<address>,
    }

    public fun lp_supply<T>(self: &SavingPool<T>): u64 {
        self.lp_supply.supply_value()
    }

    /// Returns the current USDB reserves held in the pool (excluding pending interest)
    public fun usdb_reserve<T>(self: &SavingPool<T>): u64 {
        self.usdb_reserve_balance.value()
    }

    /// Returns the optional deposit cap limit for the pool
    public fun deposit_cap_amount<T>(self: &SavingPool<T>): Option<u64> {
        self.deposit_cap_amount
    }

    /// Returns the LP token balance for a specific account
    public fun lp_balance_of<T>(self: &SavingPool<T>, account_address: address): u64 {
        abort 0
    }

    /// Returns the last update timestamp for a specific account's position
    public fun last_update<T>(self: &SavingPool<T>, account_address: address): u64 {
        abort 0
    }

    /// Returns the current annual saving rate as a Double
    public fun saving_rate<T>(self: &SavingPool<T>): Double {
        self.saving_config.saving_rate
    }

    /// Returns the timestamp when interest was last distributed
    public fun last_emitted<T>(self: &SavingPool<T>): u64 {
        self.saving_config.last_emitted
    }

    /// Returns the set of required witness types for deposit operations
    public fun deposit_response_checklist<T>(self: &SavingPool<T>): &VecSet<TypeName> {
        &self.deposit_response_checklist
    }

    /// Returns the set of required witness types for withdraw operations
    public fun withdraw_response_checklist<T>(self: &SavingPool<T>): &VecSet<TypeName> {
        &self.withdraw_response_checklist
    }

    /// Returns the set of addresses with currently locked positions
    public fun position_locker<T>(self: &SavingPool<T>): VecSet<address> {
        self.position_locker
    }

    /// Hot Potato
    public struct DepositResponse<phantom T> {
        /// Address of the account that made the deposit
        account_address: address,
        /// Amount of USDB deposited into the pool
        deposited_usdb_amount: u64,
        /// Amount of LP tokens minted for this deposit
        minted_lp_amount: u64,
        /// Previous LP token balance before this deposit
        prev_lp_balance: u64,
        /// Previous last update timestamp before this deposit
        prev_last_update_timestamp: u64,
        /// Set of witness types that have been validated
        witnesses: VecSet<TypeName>,
    }

    /// Returns the account address from deposit response
    public fun deposit_response_account<T>(deposit_res: &DepositResponse<T>): address {
        deposit_res.account_address
    }

    public use fun deposit_response_account as DepositResponse.account;

    /// Returns the amount of USDB deposited
    public fun deposit_response_deposited_usdb_amount<T>(deposit_res: &DepositResponse<T>): u64 {
        deposit_res.deposited_usdb_amount
    }

    public use fun deposit_response_deposited_usdb_amount as DepositResponse.deposited_usdb_amount;

    /// Returns the amount of LP tokens minted
    public fun deposit_response_minted_lp_amount<T>(deposit_res: &DepositResponse<T>): u64 {
        deposit_res.minted_lp_amount
    }

    public use fun deposit_response_minted_lp_amount as DepositResponse.minted_lp_amount;

    /// Returns the previous LP balance before deposit
    public fun deposit_response_prev_lp_balance<T>(deposit_res: &DepositResponse<T>): u64 {
        deposit_res.prev_lp_balance
    }

    public use fun deposit_response_prev_lp_balance as DepositResponse.prev_lp_balance;

    /// Returns the previous last update timestamp before deposit
    public fun deposit_response_prev_last_update_timestamp<T>(
        deposit_res: &DepositResponse<T>,
    ): u64 {
        deposit_res.prev_last_update_timestamp
    }

    public use fun deposit_response_prev_last_update_timestamp as
        DepositResponse.prev_last_update_timestamp;

    /// Hot Potato struct that must be consumed after withdraw operation
    /// Contains withdrawal transaction details and witness validation
    public struct WithdrawResponse<phantom T> {
        /// Address of the account that made the withdrawal
        account_address: address,
        /// Amount of LP tokens burned for this withdrawal
        burned_lp_amount: u64,
        /// Previous LP token balance before this withdrawal
        prev_lp_balance: u64,
        /// Previous last update timestamp before this withdrawal
        prev_last_update_timestamp: u64,
        /// Amount of USDB withdrawn from the pool
        withdrawal_usdb_amount: u64,
        /// Set of witness types that have been validated
        witnesses: VecSet<TypeName>,
    }

    /// Returns the account address from withdraw response
    public fun withdraw_response_account<T>(withdraw_res: &WithdrawResponse<T>): address {
        withdraw_res.account_address
    }

    public use fun withdraw_response_account as WithdrawResponse.account;

    /// Returns the amount of LP tokens burned
    public fun withdraw_response_burned_lp_amount<T>(withdraw_res: &WithdrawResponse<T>): u64 {
        withdraw_res.burned_lp_amount
    }

    public use fun withdraw_response_burned_lp_amount as WithdrawResponse.burned_lp_amount;

    /// Returns the amount of USDB withdrawn
    public fun withdraw_response_withdrawal_usdb_amount<T>(
        withdraw_res: &WithdrawResponse<T>,
    ): u64 {
        withdraw_res.withdrawal_usdb_amount
    }

    public use fun withdraw_response_withdrawal_usdb_amount as
        WithdrawResponse.withdrawal_usdb_amount;

    /// Returns the previous LP balance before withdrawal
    public fun withdraw_response_prev_lp_balance<T>(withdraw_res: &WithdrawResponse<T>): u64 {
        withdraw_res.prev_lp_balance
    }

    public use fun withdraw_response_prev_lp_balance as WithdrawResponse.prev_lp_balance;

    /// Returns the previous last update timestamp before withdrawal
    public fun withdraw_response_prev_last_update_timestamp<T>(
        withdraw_res: &WithdrawResponse<T>,
    ): u64 {
        withdraw_res.prev_last_update_timestamp
    }

    public use fun withdraw_response_prev_last_update_timestamp as
        WithdrawResponse.prev_last_update_timestamp;

    // === Events ===

    // === Method Aliases ===

    // === View Functions ===

    /// Returns the amount of interest that has accumulated since last distribution
    /// but has not yet been distributed to the pool reserves
    public fun pending_interest<T>(self: &SavingPool<T>, clock: &Clock): u64 {
        abort 0
    }

    /// Returns the total reserve amount including current reserves plus accumulated interest
    public fun total_reserve<T>(self: &SavingPool<T>, clock: &Clock): u64 {
        abort 0
    }

    /// Returns the current ratio of LP token value to total reserve
    /// Used to calculate how much each LP token is worth in USDB terms
    public fun lp_token_ratio<T>(self: &SavingPool<T>, clock: &Clock): Double {
        abort 0
    }

    /// Returns the USDB value for a given amount of LP token shares
    public fun lp_token_value<T>(self: &SavingPool<T>, shares: u64, clock: &Clock): u64 {
        abort 0
    }

    /// Returns the total USDB value of LP tokens held by a specific account
    public fun lp_token_value_of<T>(
        self: &SavingPool<T>,
        account_address: address,
        clock: &Clock,
    ): u64 {
        abort 0
    }

    /// Calculates how many LP tokens would be minted for a given USDB deposit amount
    public fun calculate_lp_mint_amount<T>(self: &SavingPool<T>, value: u64, clock: &Clock): u64 {
        abort 0
    }

    /// Checks if a position exists for the given account address
    public fun position_exists<T>(self: &SavingPool<T>, account_address: address): bool {
        abort 0
    }

    // === Admin Functions ===
    /// Creates a new saving pool with the given treasury capability
    /// Only callable by admin with AdminCap
    public fun new<T>(
        _cap: &AdminCap,
        treasury_cap: TreasuryCap<T>,
        ctx: &mut TxContext,
    ): SavingPool<T> {
        abort 0
    }

    #[allow(lint(share_owned))]
    public fun default<T>(cap: &AdminCap, treasury_cap: TreasuryCap<T>, ctx: &mut TxContext) {
        abort 0
    }

    /// Updates the annual saving interest rate for the pool
    /// Collects any accumulated rewards before applying the new rate
    public fun update_saving_rate<T>(
        self: &mut SavingPool<T>,
        _cap: &AdminCap,
        treasury: &mut Treasury,
        saving_rate_bps: u64,
        clock: &Clock,
        ctx: &mut TxContext,
    ) {
        abort 0
    }

    /// Updates the maximum deposit cap limit for the pool
    /// Set to None to remove deposit limits
    public fun update_deposit_cap<T>(
        self: &mut SavingPool<T>,
        _cap: &AdminCap,
        deposit_cap_amount: Option<u64>,
    ) {
        abort 0
    }

    /// Adds a required witness type check for deposit operations
    /// The witness must be provided during deposit response validation
    public fun add_deposit_response_check<T, R: drop>(self: &mut SavingPool<T>, _cap: &AdminCap) {
        abort 0
    }

    /// Removes a witness type check requirement for deposit operations
    public fun remove_deposit_response_check<T, R: drop>(
        self: &mut SavingPool<T>,
        _cap: &AdminCap,
    ) {
        abort 0
    }

    /// Adds a required witness type check for withdraw operations
    /// The witness must be provided during withdraw response validation
    public fun add_withdraw_response_check<T, R: drop>(self: &mut SavingPool<T>, _cap: &AdminCap) {
        abort 0
    }

    /// Removes a witness type check requirement for withdraw operations
    public fun remove_withdraw_response_check<T, R: drop>(
        self: &mut SavingPool<T>,
        _cap: &AdminCap,
    ) {
        abort 0
    }

    // === Public Functions ===
    /// Validates and consumes a deposit response hot potato
    /// Ensures all required witness checks have been satisfied before unlocking the position
    public fun check_deposit_response<T>(
        res: DepositResponse<T>,
        self: &mut SavingPool<T>,
        treasury: &Treasury,
    ) {
        abort 0
    }

    /// Validates and consumes a withdraw response hot potato
    /// Ensures all required witness checks have been satisfied before unlocking the position
    public fun check_withdraw_response<T>(
        res: WithdrawResponse<T>,
        self: &mut SavingPool<T>,
        treasury: &Treasury,
    ) {
        abort 0
    }

    /// Adds a witness proof to the deposit response for validation
    /// Each witness type can only be added once per response
    public fun add_deposit_witness<T, W: drop>(response: &mut DepositResponse<T>, _witness: W) {
        abort 0
    }

    /// Adds a witness proof to the withdraw response for validation
    /// Each witness type can only be added once per response
    public fun add_withdraw_witness<T, W: drop>(response: &mut WithdrawResponse<T>, _witness: W) {
        abort 0
    }

    /// Deposits USDB into the saving pool and mints LP tokens
    /// Collects accumulated interest before processing the deposit
    /// Returns a DepositResponse hot potato that must be validated
    public fun deposit<T>(
        self: &mut SavingPool<T>,
        treasury: &mut Treasury,
        account: address,
        usdb: Coin<USDB>,
        clock: &Clock,
        ctx: &mut TxContext,
    ): DepositResponse<T> {
        abort 0
    }

    /// Withdraws USDB from the saving pool by burning LP tokens
    /// Collects accumulated interest before processing the withdrawal
    /// Returns USDB coin and WithdrawResponse hot potato that must be validated
    public fun withdraw<T>(
        self: &mut SavingPool<T>,
        treasury: &mut Treasury,
        account_req: &AccountRequest,
        burned_lp: u64,
        clock: &Clock,
        ctx: &mut TxContext,
    ): (Coin<USDB>, WithdrawResponse<T>) {
        abort 0
    }

    /// Validates that a deposit won't exceed the pool's deposit cap limit
    /// Only enforced when deposit_cap_amount is set
    fun assert_deposit_cap<T>(self: &SavingPool<T>, clock: &Clock) {
        abort 0
    }

    /// Distributes accumulated interest and adds them to pool reserves
    /// Mints new USDB from treasury based on time elapsed and interest rate
    fun distribute_interest<T>(
        self: &mut SavingPool<T>,
        treasury: &mut Treasury,
        clock: &Clock,
        ctx: &mut TxContext,
    ) {
        abort 0
    }

    /// Internal function to handle USDB deposits and LP token minting
    /// Calculates LP tokens based on current pool ratio
    fun deposit_<T>(self: &mut SavingPool<T>, usdb: Balance<USDB>): Balance<T> {
        abort 0
    }

    /// Internal function to handle LP token burning and USDB withdrawal
    /// Calculates withdrawal amount based on current pool ratio
    fun withdraw_<T>(self: &mut SavingPool<T>, lp_balance: Balance<T>): Balance<USDB> {
        abort 0
    }
}
