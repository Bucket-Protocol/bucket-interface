// Module for collecting price data from different rule types
module bucket_v2_oracle::collector {
    use bucket_v2_framework::float::Float;
    use std::type_name::{get, TypeName};
    use sui::vec_map::{Self, VecMap};

    /// PriceCollector is a generic struct that collects prices for different rule types.
    /// The phantom type parameter T allows the collector to be specialized for different contexts.
    public struct PriceCollector<phantom T> has drop {
        // Maps a rule's TypeName to its collected Float price value.
        contents: VecMap<TypeName, Option<Float>>,
    }

    /// Creates a new, empty PriceCollector for a given context T.
    public fun new<T>(): PriceCollector<T> {
        abort 0;
    }

    // Collects a price for a rule type R into the collector.
    // If a price for this rule type already exists, it is overwritten.
    // - collector: the mutable PriceCollector to update
    // - _witenss: a witness value of type R (not used, but enforces type tracking)
    // - price: the Float price to record
    public fun collect<T, R: drop>(
        collector: &mut PriceCollector<T>,
        _witenss: R,
        price: Option<Float>,
    ) {
        abort 0;
    }

    /// Returns an immutable reference to the contents VecMap of the collector.
    /// This allows inspection of all collected prices by rule type.
    public fun contents<T>(collector: &PriceCollector<T>): &VecMap<TypeName, Option<Float>> {
        abort 0;
    }

    /// Package fun to for aggregator module to remove outlier
    public(package) fun remove<T>(collector: &mut PriceCollector<T>, rule_type: &TypeName) {
        abort 0;
    }
}
