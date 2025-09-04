module bucket_v2_psm::version {
    use bucket_v2_psm::witness::{BucketV2PSM};
    use bucket_v2_usd::usdb::Treasury;

    /// Constants

    const PACKAGE_VERSION: u16 = 1;

    /// Public Funs

    public fun package_version(): u16 { PACKAGE_VERSION }

    public(package) fun assert_valid_package(treasury: &Treasury) {
        treasury.assert_valid_module_version<BucketV2PSM>(package_version());
    }
}
