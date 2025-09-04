// Module for handling price aggregation results in the BucketV2 Oracle system
module bucket_v2_oracle::result;

use bucket_v2_framework::float::{Float};

/// Struct
/// PriceResult holds the result of an aggregated price computation for a given asset type T.
/// The phantom type parameter T allows associating the result with a specific asset without storing it.
public struct PriceResult<phantom T> has copy, drop {
    /// The aggregated price value as a Float
    aggregated_price: Float,
}

/// Package Funs

/// Creates a new PriceResult for a given asset type T with the provided aggregated price.
/// This function is only visible within the current package.
public(package) fun new<T>(aggregated_price: Float): PriceResult<T> {
    abort 0
}

/// Getter Funs

/// Returns the aggregated price from the PriceResult for the given asset type T.
public fun aggregated_price<T>(self: &PriceResult<T>): Float {
    abort 0
}

/// Test-only Funs

/// Creates a new PriceResult for testing purposes.
/// This function is only available in test builds.
#[test_only]
public fun new_for_testing<T>(aggreated_price: Float): PriceResult<T> {
    abort 0
}
