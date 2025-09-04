/// Module for aggregating prices from multiple sources with weighted rules and threshold logic.
module bucket_v2_oracle::aggregator {
    use bucket_v2_framework::float::{Self, Float};
    use bucket_v2_oracle::{
        collector::PriceCollector,
        listing::ListingCap,
        result::{Self, PriceResult}
    };
    use std::{ascii::String, type_name::{get, TypeName}};
    use sui::{event, vec_map::{Self, VecMap}};

    /// Errors

    const EMissingPriceSource: u64 = 201;

    fun err_missing_price_source() { abort EMissingPriceSource }

    const EInvalidWeight: u64 = 202;

    fun err_invalid_weight() { abort EInvalidWeight }

    const EInvalidThreshold: u64 = 203;

    fun err_invalid_threshold() { abort EInvalidThreshold }

    const ETotalWeightNotEnough: u64 = 204;

    fun err_total_weight_not_enough() { abort ETotalWeightNotEnough }

    /// Events

    /// Emitted when a new PriceAggregator is created
    public struct NewPriceAggregator has copy, drop {
        aggregator_id: ID,
        coin_type: String,
        weight_threshold: u64,
        outlier_tolerance_bps: u64,
    }

    /// Emitted when a rule's weight is updated
    public struct WeightUpdated<phantom T> has copy, drop {
        aggregator_id: ID,
        rule_type: String,
        weight: u8,
    }

    /// Emitted when the weight threshold is updated
    public struct ThresholdUpdated<phantom T> has copy, drop {
        aggregator_id: ID,
        weight_threshold: u64,
    }

    /// Emitted when the outlier tolerance is updated
    public struct OutlierToleranceUpdated<phantom T> has copy, drop {
        aggregator_id: ID,
        outlier_tolerance_bps: u64,
    }

    /// Emitted when a price is aggregated
    public struct PriceAggregated<phantom T> has copy, drop {
        aggregator_id: ID,
        sources: vector<String>,
        prices: vector<u128>,
        weights: vector<u8>,
        current_threshold: u64,
        result: u128,
    }

    /// Object

    /// Stores weights for each rule and the threshold for aggregation
    public struct PriceAggregator<phantom T> has key, store {
        id: UID,
        weights: VecMap<TypeName, u8>, // Mapping from rule type to weight
        weight_threshold: u64, // Minimum total weight required to aggregate
        outlier_tolerance: Float, // Maximum allowed deviation from the median price
    }

    /// Admin Funs

    /// Create a new PriceAggregator object for a given coin type
    public fun new<T>(
        cap: &mut ListingCap,
        weight_threshold: u64,
        outlier_tolerance_bps: u64,
        ctx: &mut TxContext,
    ): PriceAggregator<T> {
        abort 0
    }

    /// Entry function to create and share a new PriceAggregator object
    #[allow(lint(share_owned))]
    entry fun create<T>(
        cap: &mut ListingCap,
        weight_threshold: u64,
        outlier_tolerance_bps: u64,
        ctx: &mut TxContext,
    ) {
        abort 0
    }

    /// Set or update the weight for a specific rule type
    public fun set_rule_weight<T, R>(
        self: &mut PriceAggregator<T>,
        _cap: &ListingCap,
        new_weight: u8,
    ) {
        abort 0
    }

    /// Set the minimum total weight required for aggregation
    public fun set_weight_threshold<T>(
        self: &mut PriceAggregator<T>,
        _cap: &ListingCap,
        weight_threshold: u64,
    ) {
        abort 0
    }

    public fun set_outlier_tolerance<T>(
        self: &mut PriceAggregator<T>,
        _cap: &ListingCap,
        outlier_tolerance_bps: u64,
    ) {
        abort 0
    }

    /// Public Funs

    /// Aggregate prices from the collector using the weights and threshold
    public fun aggregate<T>(
        self: &PriceAggregator<T>,
        mut collector: PriceCollector<T>,
    ): PriceResult<T> {
        abort 0
    }

    /// Getter Functions

    /// Get the weights map
    public fun weights<T>(self: &PriceAggregator<T>): &VecMap<TypeName, u8> {
        &self.weights
    }

    /// Get the current weight threshold
    public fun weight_threshold<T>(self: &PriceAggregator<T>): u64 {
        self.weight_threshold
    }

    /// Get the current weight threshold
    public fun outlier_tolerance<T>(self: &PriceAggregator<T>): Float {
        self.outlier_tolerance
    }

    /// Internal fun to remove outlier
    fun remove_outliers<T>(self: &PriceAggregator<T>, collector: &mut PriceCollector<T>) {
        abort 0
    }
}
