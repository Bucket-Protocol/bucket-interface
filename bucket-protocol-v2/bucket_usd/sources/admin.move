// This module defines the admin capabilities for the bucket_v2_usd package.
module bucket_v2_usd::admin;

/// The AdminCap struct represents the admin capability object for the module.
/// It is used to control privileged operations within the module.
public struct AdminCap has key, store {
    id: UID, // Unique identifier for the admin capability object
}

/// Initializes the admin capability and transfers it to the sender.
/// This function should be called once during module deployment or setup.
fun init(ctx: &mut TxContext) {
    abort 0;
}

/// Test-only Functions

/// Initializes the admin capability for testing purposes.
/// This function is only available in test builds.
#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    abort 0;
}
