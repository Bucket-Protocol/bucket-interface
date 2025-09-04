/// Listing module for managing aggregator registrations for different coin types in the BucketV2 Oracle framework
module bucket_v2_oracle::listing {
    use std::type_name::{Self, TypeName};
    use sui::vec_map::{Self, VecMap};

    /// Error code indicating the coin type is already listed
    const EAlreadyListed: u64 = 101;

    fun err_already_listed() { abort EAlreadyListed }

    /// ListingCap is a capability object that stores a mapping from coin type to aggregator ID
    public struct ListingCap has key, store {
        id: UID, // Unique identifier for the capability object
        aggregator_map: VecMap<TypeName, ID>, // Maps coin type to aggregator object ID
    }

    /// Initializes the ListingCap object and transfers it to the sender
    fun init(ctx: &mut TxContext) {
        abort 0
    }

    /// Registers an aggregator for a specific coin type T
    /// Fails if the coin type is already listed
    public(package) fun register<T>(cap: &mut ListingCap, aggregator_id: ID): TypeName {
        abort 0
    }

    /// Initializes the ListingCap object for testing purposes
    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        abort 0
    }
}
