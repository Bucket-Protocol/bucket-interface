/// Module for managing Credit and Debt for DeFi protocol usage
module bucket_v2_framework::liability;

/// Errors

const EDestroyNonZeroCredit: u64 = 401;
fun err_destroy_not_zero_credit() { abort EDestroyNonZeroCredit }

const EDestroyNonZeroDebt: u64 = 402;
fun err_destroy_not_zero_debt() { abort EDestroyNonZeroDebt }

/// Structs

public struct Credit<phantom T> has store {
    value: u64,
}

public struct Debt<phantom T> has store {
    value: u64,
}

/// Public Funs

public fun new<T>(value: u64): (Credit<T>, Debt<T>) {
    (Credit { value }, Debt { value })
}

public fun zero_credit<T>(): Credit<T> {
    Credit<T> { value: 0 }
}

public fun zero_debt<T>(): Debt<T> {
    Debt<T> { value: 0 }
}

public use fun destroy_zero_credit as Credit.destroy_zero;
public fun destroy_zero_credit<T>(credit: Credit<T>) {
    let Credit { value } = credit;
    if (value > 0) err_destroy_not_zero_credit();
}

public use fun destroy_zero_debt as Debt.destroy_zero;
public fun destroy_zero_debt<T>(debt: Debt<T>) {
    let Debt { value } = debt;
    if (value > 0) err_destroy_not_zero_debt();
}

public use fun add_credit as Credit.add;
public fun add_credit<T>(self: &mut Credit<T>, credit: Credit<T>): u64 {
    let Credit { value } = credit;
    let final_value = self.value() + value;
    self.value = final_value;
    final_value
}

public use fun add_debt as Debt.add;
public fun add_debt<T>(self: &mut Debt<T>, debt: Debt<T>): u64 {
    let Debt { value } = debt;
    let final_value = self.value() + value;
    self.value = final_value;
    final_value
}

public fun auto_settle<T>(credit: &mut Credit<T>, debt: &mut Debt<T>): (u64, u64) {
    let credit_value = credit.value();
    let debt_value = debt.value();
    if (credit_value >= debt_value) {
        credit.value = credit_value - debt_value;
        debt.value = 0;
    } else {
        debt.value = debt_value - credit_value;
        credit.value = 0;
    };
    (credit.value(), debt.value())
}

public use fun settle_debt as Credit.settle;
public fun settle_debt<T>(credit: &mut Credit<T>, mut debt: Debt<T>): Option<Debt<T>> {
    let (_, debt_value) = auto_settle(credit, &mut debt);
    if (debt_value > 0) {
        option::some(debt)
    } else {
        debt.destroy_zero();
        option::none()
    }
}

public use fun settle_credit as Debt.settle;
public fun settle_credit<T>(debt: &mut Debt<T>, mut credit: Credit<T>): Option<Credit<T>> {
    let (credit_value, _) = auto_settle(&mut credit, debt);
    if (credit_value > 0) {
        option::some(credit)
    } else {
        credit.destroy_zero();
        option::none()
    }
}

/// Getter Funs

public use fun credit_value as Credit.value;
public fun credit_value<T>(credit: &Credit<T>): u64 {
    credit.value
}

public use fun debt_value as Debt.value;
public fun debt_value<T>(debt: &Debt<T>): u64 {
    debt.value
}

/// Test-only Funs

#[test_only]
public use fun destroy_credit_for_testing as Credit.destroy_for_testing;
public fun destroy_credit_for_testing<T>(credit: Credit<T>): u64 {
    let Credit { value } = credit;
    value
}

#[test_only]
public use fun destroy_debt_for_testing as Debt.destroy_for_testing;
public fun destroy_debt_for_testing<T>(debt: Debt<T>): u64 {
    let Debt { value } = debt;
    value
}

/// Tests

#[test]
fun test_settle() {
    use sui::sui::SUI;
    let value_1 = 100_000_000_000;
    let value_2 = 20_000_000_000;
    let value_3 = 60_000_000_000;
    let value_4 = 1_000_000_000;
    let value_5 = 40_000_000_000;
    let (mut credit_1, mut debt_1) = new<SUI>(value_1);
    let (credit_2, mut debt_2) = new<SUI>(value_2);
    let (mut credit_3, debt_3) = new<SUI>(value_3);
    let (credit_4, debt_4) = new<SUI>(value_4);
    let (credit_5, debt_5) = new<SUI>(value_5);

    assert!(credit_1.value() == value_1);
    assert!(debt_1.value() == value_1);

    credit_1.add(credit_2);
    assert!(credit_1.value() == value_1 + value_2);

    debt_2.add(debt_3);
    assert!(debt_2.value() == value_2 + value_3);

    auto_settle(&mut credit_1, &mut debt_2);
    assert!(credit_1.value() == value_1 - value_3);
    assert!(debt_2.value() == 0);
    debt_2.destroy_zero();

    auto_settle(&mut credit_3, &mut debt_1);
    assert!(credit_3.value() == 0);
    assert!(debt_1.value() == value_1 - value_3);
    credit_3.destroy_zero();

    let debt_out = credit_1.settle_debt(debt_4);
    assert!(credit_1.value() == value_1 - value_3 - value_4);
    assert!(debt_out.is_none());
    debt_out.destroy_none();

    let credit_out = debt_1.settle_credit(credit_4);
    assert!(debt_1.value() == value_1 - value_3 - value_4);
    assert!(credit_out.is_none());
    credit_out.destroy_none();


    let mut debt_out = credit_1.settle_debt(debt_5).destroy_some();
    assert!(credit_1.value() == 0);
    assert!(debt_out.value() == value_4);
    credit_1.destroy_zero();

    let credit_out = debt_1.settle_credit(credit_5).destroy_some();
    assert!(debt_1.value() == 0);
    assert!(credit_out.value() == value_4);
    debt_1.destroy_zero();

    let credit_left = debt_out.settle_credit(credit_out);
    assert!(debt_out.value() == 0);
    debt_out.destroy_zero();
    assert!(credit_left.is_none());
    credit_left.destroy_none();

    let (mut credit, mut debt) = new<SUI>(100);
    assert!(credit.add(zero_credit()) == 100);
    assert!(debt.add(zero_debt()) == 100);
    credit.destroy_for_testing();
    debt.destroy_for_testing();
}

#[test, expected_failure(abort_code = EDestroyNonZeroCredit)]
fun test_destroy_non_zero_credit() {
    use sui::sui::SUI;
    let (credit, debt) = new<SUI>(1);
    credit.destroy_zero();
    debt.destroy_zero();
}

#[test, expected_failure(abort_code = EDestroyNonZeroDebt)]
fun test_destroy_non_zero_debt() {
    use sui::sui::SUI;
    let (credit, debt) = new<SUI>(1);
    debt.destroy_zero();
    credit.destroy_zero();
}
