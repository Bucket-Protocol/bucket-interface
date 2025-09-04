/// Module for double precision floating points
module bucket_v2_framework::double {
    use bucket_v2_framework::float::{Self, Float};

    /// Errors

    const EDividedByZero: u64 = 301;

    fun err_divided_by_zero() { abort EDividedByZero }

    const ESubtrahendTooLarge: u64 = 302;

    fun err_subtrahend_too_large() { abort ESubtrahendTooLarge }

    const ENumberTooLarge: u64 = 303;

    fun err_number_too_large() { abort ENumberTooLarge }

    /// Constants

    const PRECISION: u256 = 1_000_000_000_000_000_000; // 1e18

    /// Struct

    public struct Double has copy, drop, store {
        value: u256,
    }

    /// Public Funs

    public fun zero(): Double {
        Double { value: 0 }
    }

    public fun one(): Double {
        Double { value: PRECISION }
    }

    public fun ten(): Double {
        from(10)
    }

    public fun from(v: u64): Double {
        Double { value: (v as u256) * PRECISION }
    }

    public fun from_percent(v: u8): Double {
        Double { value: (v as u256) * PRECISION / 100 }
    }

    public fun from_percent_u64(v: u64): Double {
        Double { value: (v as u256) * PRECISION / 100 }
    }

    public fun from_bps(v: u64): Double {
        Double { value: (v as u256) * PRECISION / 10_000 }
    }

    public fun from_fraction(n: u64, m: u64): Double {
        if (m == 0) err_divided_by_zero();
        Double { value: (n as u256) * PRECISION / (m as u256) }
    }

    public fun from_scaled_val(v: u256): Double {
        Double { value: v }
    }

    public fun from_float(f: Float): Double {
        let precision_diff = PRECISION / (float::precision() as u256);
        Double { value: (f.to_scaled_val() as u256) * precision_diff }
    }

    public fun to_scaled_val(v: Double): u256 {
        v.value
    }

    public fun try_into_float(v: Double): Option<Float> {
        // WARING: downscaling will lose precision
        let precision_diff = PRECISION / (float::precision() as u256);
        let new_value = v.value / precision_diff;
        if (new_value <= (std::u128::max_value!() as u256)) {
            option::some(float::from_scaled_val(new_value as u128))
        } else {
            option::none()
        }
    }

    public fun add(a: Double, b: Double): Double {
        if (std::u256::max_value!() - b.value < a.value) {
            err_number_too_large();
        };
        Double { value: a.value + b.value }
    }

    public fun sub(a: Double, b: Double): Double {
        if (b.value > a.value) err_subtrahend_too_large();
        Double { value: a.value - b.value }
    }

    public fun saturating_sub(a: Double, b: Double): Double {
        if (a.value < b.value) {
            Double { value: 0 }
        } else {
            Double { value: a.value - b.value }
        }
    }

    public fun mul(a: Double, b: Double): Double {
        if (b.value > 0 && std::u256::max_value!() / b.value < a.value) {
            err_number_too_large();
        };
        Double { value: (a.value * b.value) / PRECISION }
    }

    public fun div(a: Double, b: Double): Double {
        if (b.value == 0) err_divided_by_zero();

        if (a.value > std::u256::max_value!() / PRECISION) {
            err_number_too_large();
        };
        Double { value: (a.value * PRECISION) / b.value }
    }

    public fun add_u64(a: Double, b: u64): Double {
        a.add(from(b))
    }

    public fun sub_u64(a: Double, b: u64): Double {
        a.sub(from(b))
    }

    public fun saturating_sub_u64(a: Double, b: u64): Double {
        a.saturating_sub(from(b))
    }

    public fun mul_u64(a: Double, b: u64): Double {
        if (b > 0 && std::u256::max_value!() / (b as u256) < a.value) {
            err_number_too_large();
        };
        Double { value: a.value * (b as u256) }
    }

    public fun div_u64(a: Double, b: u64): Double {
        if (b == 0) err_divided_by_zero();
        Double { value: a.value / (b as u256) }
    }

    public fun pow(b: Double, mut e: u64): Double {
        let mut cur_base = b;
        let mut result = from(1);

        while (e > 0) {
            if (e % 2 == 1) {
                result = mul(result, cur_base);
            };
            cur_base = mul(cur_base, cur_base);
            e = e / 2;
        };

        result
    }

    public fun floor(v: Double): u64 {
        ((v.value / PRECISION) as u64)
    }

    public fun ceil(v: Double): u64 {
        (((v.value + PRECISION - 1) / PRECISION) as u64)
    }

    public fun round(v: Double): u64 {
        if (v.value > std::u256::max_value!() - PRECISION / 2) {
            err_number_too_large();
        };
        (((v.value + PRECISION / 2) / PRECISION) as u64)
    }

    public fun eq(a: Double, b: Double): bool {
        a.value == b.value
    }

    public fun gt(a: Double, b: Double): bool {
        a.value > b.value
    }

    public fun gte(a: Double, b: Double): bool {
        a.value >= b.value
    }

    public fun lt(a: Double, b: Double): bool {
        a.value < b.value
    }

    public fun lte(a: Double, b: Double): bool {
        a.value <= b.value
    }

    public fun min(a: Double, b: Double): Double {
        if (a.value < b.value) {
            a
        } else {
            b
        }
    }

    public fun max(a: Double, b: Double): Double {
        if (a.value > b.value) {
            a
        } else {
            b
        }
    }

    public fun diff(a: Double, b: Double): Double {
        if (a.lte(b)) {
            b.sub(a)
        } else {
            a.sub(b)
        }
    }

    public fun precision(): u256 { PRECISION }

    /// Tests

    #[test]
    fun test_basic() {
        let a = from(1);
        let b = from(2);

        assert!(a.add(b) == from(3));
        assert!(b.sub(a) == from(1));
        assert!(a.mul(b) == from(2));
        assert!(b.div(a) == from(2));
        assert!(from_percent(150).floor() == 1);
        assert!(from_percent(150).ceil() == 2);
        assert!(a.lt(b));
        assert!(b.gt(a));
        assert!(a.lte(b));
        assert!(b.gte(a));
        assert!(a.saturating_sub(b) == zero());
        assert!(b.saturating_sub(a) == one());
        assert!(from_fraction(1, 4).eq(from_percent(25)));
        assert!(from_scaled_val(precision()).eq(one()));
    }

    #[test]
    fun test_pow() {
        assert!(from(5).pow(4) == from(625));
        assert!(from(3).pow(0) == from(1));
        assert!(from(3).pow(1) == from(3));
        assert!(from(3).pow(7) == from(2187));
        assert!(from(3).pow(8) == from(6561));
    }

    #[test]
    fun test_advenced() {
        assert!(from_percent(5).eq(from_bps(500)));
        assert!(from_percent_u64(900) == from(8).add_u64(1));
        assert!(from_percent_u64(911) == from_scaled_val(9_110_000_000_000_000_000));
        assert!(from(5).sub_u64(1).mul_u64(2) == from(24).div_u64(3));
        assert!(from(500).min(from(100)).eq(from(100)));
        assert!(from(100).min(from(500)).eq(from(100)));
        assert!(from(500).max(from(100)).lte(from(500)));
        assert!(from(100).max(from(500)).gte(from(500)));
        assert!(from(2).saturating_sub_u64(1) == from(1));
        assert!(from(1).saturating_sub_u64(2) == from(0));
        assert!(float::from_percent(12).into_double() == from_bps(1200));
        assert!(ten().pow(30).try_into_float().is_none());
        assert!(
            ten().pow(29).try_into_float().destroy_some() == float::from_scaled_val(std::u128::pow(10, 29 + 9)),
        );
        assert!(from_percent(249).round() == 2);
        assert!(from_percent(250).round() == 3);
        assert!(from_percent(251).round() == 3);
    }

    #[test, expected_failure(abort_code = EDividedByZero)]
    fun test_div_by_zero() {
        from(1).div_u64(0);
    }

    #[test, expected_failure(abort_code = EDividedByZero)]
    fun test_fraction_by_zero() {
        from_fraction(1, 0);
    }

    #[test, expected_failure(abort_code = ESubtrahendTooLarge)]
    fun test_sub_too_much() {
        from(1).sub_u64(2);
    }

    #[test, expected_failure(abort_code = ENumberTooLarge)]
    fun test_number_too_large_when_add() {
        from_scaled_val(std::u256::max_value!() - (10u64.pow(18) as u256) + 1).add_u64(1);
    }

    #[test, expected_failure(abort_code = ENumberTooLarge)]
    fun test_number_too_large_when_mul() {
        from_scaled_val(std::u256::max_value!()/2 + 1).mul_u64(2);
    }

    #[test, expected_failure(abort_code = ENumberTooLarge)]
    fun test_number_too_large_when_div() {
        let overflow_threshold = std::u256::max_value!() / PRECISION + 1;
        let large_float = from_scaled_val(overflow_threshold);
        let _result = large_float.div(one());
    }
}
