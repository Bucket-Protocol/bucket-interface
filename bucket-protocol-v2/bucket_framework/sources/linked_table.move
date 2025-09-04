module bucket_v2_framework::linked_table;

use sui::dynamic_field::{Self as df};

// Attempted to destroy a non-empty table
const ETableNotEmpty: u64 = 501;
fun err_table_not_empty() { abort ETableNotEmpty }
// Attempted to remove the front or back of an empty table
const ETableIsEmpty: u64 = 502;
fun err_table_is_empty() { abort ETableIsEmpty }

public struct LinkedTable<K: copy + drop + store, phantom V: store> has key, store {
    /// the ID of this table
    id: UID,
    /// the number of key-value pairs in the table
    size: u64,
    /// the front of the table, i.e. the key of the first entry
    head: Option<K>,
    /// the back of the table, i.e. the key of the last entry
    tail: Option<K>,
}

public struct Node<K: copy + drop + store, V: store> has store {
    /// the previous key
    prev: Option<K>,
    /// the next key
    next: Option<K>,
    /// the value being stored
    value: V,
}

/// Creates a new, empty table
public fun new<K: copy + drop + store, V: store>(ctx: &mut TxContext): LinkedTable<K, V> {
    LinkedTable {
        id: object::new(ctx),
        size: 0,
        head: option::none(),
        tail: option::none(),
    }
}

/// Returns the key for the first element in the table, or None if the table is empty
public fun front<K: copy + drop + store, V: store>(table: &LinkedTable<K, V>): &Option<K> {
    &table.head
}

/// Returns the key for the last element in the table, or None if the table is empty
public fun back<K: copy + drop + store, V: store>(table: &LinkedTable<K, V>): &Option<K> {
    &table.tail
}

/// Inserts a key-value pair at the front of the table, i.e. the newly inserted pair will be
/// the first element in the table
/// Aborts with `sui::dynamic_df::EFieldAlreadyExists` if the table already has an entry with
/// that key `k: K`.
public fun push_front<K: copy + drop + store, V: store>(
    table: &mut LinkedTable<K, V>,
    k: K,
    value: V,
) {
    let old_head = table.head.swap_or_fill(k);
    if (table.tail.is_none()) table.tail.fill(k);
    let prev = option::none();
    let next = if (old_head.is_some()) {
        let old_head_k = old_head.destroy_some();
        df::borrow_mut<K, Node<K, V>>(&mut table.id, old_head_k).prev = option::some(k);
        option::some(old_head_k)
    } else {
        option::none()
    };
    df::add(&mut table.id, k, Node { prev, next, value });
    table.size = table.size + 1;
}

/// Inserts a key-value pair at the back of the table, i.e. the newly inserted pair will be
/// the last element in the table
/// Aborts with `sui::dynamic_df::EFieldAlreadyExists` if the table already has an entry with
/// that key `k: K`.
public fun push_back<K: copy + drop + store, V: store>(
    table: &mut LinkedTable<K, V>,
    k: K,
    value: V,
) {
    if (table.head.is_none()) table.head.fill(k);
    let old_tail = table.tail.swap_or_fill(k);
    let prev = if (old_tail.is_some()) {
        let old_tail_k = old_tail.destroy_some();
        df::borrow_mut<K, Node<K, V>>(&mut table.id, old_tail_k).next = option::some(k);
        option::some(old_tail_k)
    } else {
        option::none()
    };
    let next = option::none();
    df::add(&mut table.id, k, Node { prev, next, value });
    table.size = table.size + 1;
}

#[syntax(index)]
/// Immutable borrows the value associated with the key in the table `table: &LinkedTable<K, V>`.
/// Aborts with `sui::dynamic_df::EFieldDoesNotExist` if the table does not have an entry with
/// that key `k: K`.
public fun borrow<K: copy + drop + store, V: store>(table: &LinkedTable<K, V>, k: K): &V {
    &df::borrow<K, Node<K, V>>(&table.id, k).value
}

#[syntax(index)]
/// Mutably borrows the value associated with the key in the table `table: &mut LinkedTable<K, V>`.
/// Aborts with `sui::dynamic_df::EFieldDoesNotExist` if the table does not have an entry with
/// that key `k: K`.
public fun borrow_mut<K: copy + drop + store, V: store>(
    table: &mut LinkedTable<K, V>,
    k: K,
): &mut V {
    &mut df::borrow_mut<K, Node<K, V>>(&mut table.id, k).value
}

/// Borrows the key for the previous entry of the specified key `k: K` in the table
/// `table: &LinkedTable<K, V>`. Returns None if the entry does not have a predecessor.
/// Aborts with `sui::dynamic_df::EFieldDoesNotExist` if the table does not have an entry with
/// that key `k: K`
public fun prev<K: copy + drop + store, V: store>(table: &LinkedTable<K, V>, k: K): &Option<K> {
    &df::borrow<K, Node<K, V>>(&table.id, k).prev
}

/// Borrows the key for the next entry of the specified key `k: K` in the table
/// `table: &LinkedTable<K, V>`. Returns None if the entry does not have a predecessor.
/// Aborts with `sui::dynamic_df::EFieldDoesNotExist` if the table does not have an entry with
/// that key `k: K`
public fun next<K: copy + drop + store, V: store>(table: &LinkedTable<K, V>, k: K): &Option<K> {
    &df::borrow<K, Node<K, V>>(&table.id, k).next
}

/// Removes the key-value pair in the table `table: &mut LinkedTable<K, V>` and returns the value.
/// This splices the element out of the ordering.
/// Aborts with `sui::dynamic_df::EFieldDoesNotExist` if the table does not have an entry with
/// that key `k: K`. Note: this is also what happens when the table is empty.
public fun remove<K: copy + drop + store, V: store>(table: &mut LinkedTable<K, V>, k: K): V {
    let Node<K, V> { prev, next, value } = df::remove(&mut table.id, k);
    table.size = table.size - 1;
    if (prev.is_some()) {
        df::borrow_mut<K, Node<K, V>>(&mut table.id, *prev.borrow()).next = next
    };
    if (next.is_some()) {
        df::borrow_mut<K, Node<K, V>>(&mut table.id, *next.borrow()).prev = prev
    };
    if (table.head.borrow() == &k) table.head = next;
    if (table.tail.borrow() == &k) table.tail = prev;
    value
}

/// Removes the front of the table `table: &mut LinkedTable<K, V>` and returns the value.
/// Aborts with `ETableIsEmpty` if the table is empty
public fun pop_front<K: copy + drop + store, V: store>(table: &mut LinkedTable<K, V>): (K, V) {
    if (table.head.is_none()) err_table_is_empty();
    let head = *table.head.borrow();
    (head, table.remove(head))
}

/// Removes the back of the table `table: &mut LinkedTable<K, V>` and returns the value.
/// Aborts with `ETableIsEmpty` if the table is empty
public fun pop_back<K: copy + drop + store, V: store>(table: &mut LinkedTable<K, V>): (K, V) {
    if (table.tail.is_none()) err_table_is_empty();
    let tail = *table.tail.borrow();
    (tail, table.remove(tail))
}

/// Returns true iff there is a value associated with the key `k: K` in table
/// `table: &LinkedTable<K, V>`
public fun contains<K: copy + drop + store, V: store>(table: &LinkedTable<K, V>, k: K): bool {
    df::exists_with_type<K, Node<K, V>>(&table.id, k)
}

/// Returns the size of the table, the number of key-value pairs
public fun length<K: copy + drop + store, V: store>(table: &LinkedTable<K, V>): u64 {
    table.size
}

/// Returns true iff the table is empty (if `length` returns `0`)
public fun is_empty<K: copy + drop + store, V: store>(table: &LinkedTable<K, V>): bool {
    table.size == 0
}

/// Destroys an empty table
/// Aborts with `ETableNotEmpty` if the table still contains values
public fun destroy_empty<K: copy + drop + store, V: store>(table: LinkedTable<K, V>) {
    let LinkedTable { id, size, head: _, tail: _ } = table;
    if (size != 0) err_table_not_empty();
    id.delete()
}

/// Drop a possibly non-empty table.
/// Usable only if the value type `V` has the `drop` ability
public fun drop<K: copy + drop + store, V: drop + store>(table: LinkedTable<K, V>) {
    let LinkedTable { id, size: _, head: _, tail: _ } = table;
    id.delete()
}

/// Insert a key-value pair in front of the given key
/// If the given key is none, then set the key-value pair as back
public fun insert_front<K: copy + drop + store, V: store>(
    table: &mut LinkedTable<K, V>,
    next_k: Option<K>,
    k: K,
    value: V,
) {
    if (next_k.is_none()) {
        table.push_back(k, value);
    } else {
        let next_k = next_k.destroy_some();
        let prev_k = *table.prev(next_k);
        if (prev_k.is_none()) {
            table.push_front(k, value);
        } else {
            let prev_k = prev_k.destroy_some();
            df::borrow_mut<K, Node<K, V>>(&mut table.id, next_k).prev = option::some(k);
            df::borrow_mut<K, Node<K, V>>(&mut table.id, prev_k).next = option::some(k);
            let prev = option::some(prev_k);
            let next = option::some(next_k);
            df::add(&mut table.id, k, Node { prev, next, value });
            table.size = table.size + 1;
        }
    }
}

/// Insert a key-value pair behind the given key
/// If the given key is none, then set the key-value pair as front
public fun insert_back<K: copy + drop + store, V: store>(table: &mut LinkedTable<K, V>, prev_k: Option<K>, k: K, value: V) {
    if (prev_k.is_none()) {
        table.push_front(k, value);
    } else {
        let prev_k = prev_k.destroy_some();
        let next_k = *table.next(prev_k);
        if (next_k.is_none()) {
            table.push_back(k, value);
        } else {
            let next_k = next_k.destroy_some();
            df::borrow_mut<K, Node<K, V>>(&mut table.id, next_k).prev = option::some(k);
            df::borrow_mut<K, Node<K, V>>(&mut table.id, prev_k).next = option::some(k);
            let prev = option::some(prev_k);
            let next = option::some(next_k);
            df::add(&mut table.id, k, Node { prev, next, value });
            table.size = table.size + 1;
        };
    };
}

/// Unit tests
#[test]
fun test_insertable_linked_table() {
    use sui::test_scenario::{Self as ts};

    let dev = @0xde;
    let mut scenario = ts::begin(dev);
    let s = &mut scenario;

    let mut table = new<address, u64>(s.ctx());
    table.insert_front(option::none(), @0x2, 2);
    table.insert_back(option::none(), @0x1, 1);
    table.insert_back(option::some(@0x2), @0x4, 4);
    table.insert_front(option::some(@0x4), @0x3, 3);
    table.insert_back(option::some(@0x4), @0x6, 6);
    table.insert_front(option::some(@0x6), @0x5, 5);
    table.insert_front(option::none(), @0x8, 8);
    table.insert_back(option::some(@0x6), @0x7, 7);
    table.insert_front(option::some(@0x1), @0x0, 0);

    let mut cursor = *table.front();
    table.length().do!(|idx| {
        if (cursor.is_some()) {
            let curr_address = *cursor.borrow();
            assert!(curr_address == sui::address::from_u256(idx as u256));
            let value = *table.borrow(curr_address);
            // std::debug::print(&curr_address);
            // std::debug::print(&value);
            assert!(value == idx);
            cursor = *table.next(curr_address);
        };
    });

    scenario.end();
    table.drop();
}
