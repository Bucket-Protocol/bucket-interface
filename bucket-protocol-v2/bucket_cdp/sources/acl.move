/// Vault module for assigning managers for each security level
module bucket_v2_cdp::acl {
    use sui::vec_map::{Self, VecMap};

    const EInvalidRole: u64 = 201;

    fun err_invalid_role() { abort EInvalidRole }

    public struct Acl has store {
        abort 0;
    }

    public(package) fun new(): Acl {
        abort 0;
    }

    public(package) fun set_role(self: &mut Acl, manager: address, level: u8) {
        abort 0;
    }

    public(package) fun remove_role(self: &mut Acl, manager: address) {
        abort 0;
    }

    public(package) fun exists_role(self: &Acl, manager: address): bool {
        abort 0;
    }

    public fun role_level(self: &Acl, manager: address): u8 {
        abort 0;
    }
}
