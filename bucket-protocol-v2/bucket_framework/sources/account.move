/// Module for Account Abstraction
module bucket_v2_framework::account;

use std::string::String;
use sui::transfer::{Receiving};

/// Constants

const ALIAS_LENGTH_LIMIT: u64 = 32;

/// Errors

const EAliasLengthTooLong: u64 = 101;
fun err_alias_length_too_long() { abort EAliasLengthTooLong }

/// OTW

public struct ACCOUNT has drop {}

/// Object

public struct Account has key, store {
    id: UID,
    alias: Option<String>,
}

/// Struct

public struct AccountRequest has drop {
    account: address,
}

/// Init

fun init(otw: ACCOUNT, ctx: &mut TxContext) {
    sui::package::claim_and_keep(otw, ctx);
}

/// Public Funs

public fun new(
    alias: Option<String>,
    ctx: &mut TxContext,
): Account {
    if (alias.is_some() && alias.borrow().length() > alias_length_limit()) {
        err_alias_length_too_long();
    };
    Account {
        id: object::new(ctx),
        alias,
    }
}

public fun request(ctx: &TxContext): AccountRequest {
    AccountRequest { account: ctx.sender() }
}

public use fun request_with_account as Account.request;
public fun request_with_account(account: &Account): AccountRequest { // FIXED: ACC-2
    AccountRequest { account: object::id(account).to_address() }
}

public fun receive<T: key + store>(
    account: &mut Account,
    receiving: Receiving<T>,
): T {
    transfer::public_receive(&mut account.id, receiving)
}

public fun update_alias(
    account: &mut Account,
    alias: String,
) {
    if (alias.length() > alias_length_limit()) {
        err_alias_length_too_long();
    };
    if (account.alias.is_some()) {
        *account.alias.borrow_mut() = alias;
    } else {
        account.alias.fill(alias);
    };
}

/// Entry Funs

entry fun create(
    alias: Option<String>,
    ctx: &mut TxContext,
) {
    let account = new(alias, ctx);
    transfer::transfer(account, ctx.sender());
}

/// Getter Funs

public use fun account_address as Account.address;
public fun account_address(account: &Account): address {
    account.id.to_address()
}

public use fun request_address as AccountRequest.address;
public fun request_address(req: &AccountRequest): address {
    req.account
}

public fun alias_length_limit(): u64 { ALIAS_LENGTH_LIMIT }

/// Tests

#[test]
fun test_init() {
    use sui::test_scenario::{Self as ts};
    use sui::package::{Publisher};
    let dev = @0xde1;
    let mut scenario = ts::begin(dev);
    let s = &mut scenario;
    init(ACCOUNT {}, s.ctx());

    s.next_tx(dev);
    let publisher = s.take_from_sender<Publisher>();
    assert!(publisher.from_module<ACCOUNT>());
    assert!(publisher.from_module<Account>());
    assert!(publisher.from_module<AccountRequest>());
    s.return_to_sender(publisher);

    let user = @0xcafe;
    s.next_tx(user);
    let request = request(s.ctx());
    assert!(request.address() == user);
    let account = new(option::none(), s.ctx());
    let account_id = object::id(&account);
    transfer::public_transfer(account, user);

    s.next_tx(user);
    let account = s.take_from_sender<Account>();
    assert!(account.address() == account_id.to_address());
    let request = account.request();
    assert!(request.address() == account_id.to_address());
    s.return_to_sender(account);
    scenario.end();
}
