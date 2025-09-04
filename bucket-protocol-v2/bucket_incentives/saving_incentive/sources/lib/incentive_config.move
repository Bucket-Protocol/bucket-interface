module bucket_saving_incentive::incentive_config {
    use bucket_v2_framework::account::AccountRequest;
    use bucket_v2_usd::admin::AdminCap;
    use sui::vec_set::{Self, VecSet};

    /// Constant

    const PACKAGE_VERSION: u16 = 2;

    public fun package_version(): u16 { PACKAGE_VERSION }

    /// Errors

    const EInvalidPackageVersion: u64 = 101;

    fun err_invalid_package_version() { abort EInvalidPackageVersion }

    const ESenderIsNotManager: u64 = 102;

    fun err_sender_is_not_manager() { abort ESenderIsNotManager }

    /// Object

    public struct GlobalConfig has key {
        id: UID,
        versions: VecSet<u16>,
        managers: VecSet<address>,
    }

    /// Init

    fun init(ctx: &mut TxContext) {
        abort 0
    }

    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(ctx)
    }

    /// Admin Funs

    public fun add_version(_cap: &AdminCap, config: &mut GlobalConfig, version: u16) {
        abort 0
    }

    public fun remove_version(_cap: &AdminCap, config: &mut GlobalConfig, version: u16) {
        abort 0
    }

    public fun add_manager(_cap: &AdminCap, config: &mut GlobalConfig, manager: address) {
        abort 0
    }

    public fun remove_manager(_cap: &AdminCap, config: &mut GlobalConfig, manager: address) {
        abort 0
    }

    /// Public Funs

    public fun assert_valid_package_version(config: &GlobalConfig) {
        abort 0
    }

    public fun assert_sender_is_manager(config: &GlobalConfig, request: &AccountRequest) {
        abort 0
    }
}
