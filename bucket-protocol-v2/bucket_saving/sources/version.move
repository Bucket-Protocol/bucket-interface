module bucket_v2_saving::version {
    use bucket_v2_saving::witness::BucketV2Saving;
    use bucket_v2_usd::usdb::Treasury;

    /// Constants

    const PACKAGE_VERSION: u16 = 1;

    /// Public Funs

    public fun package_version(): u16 { PACKAGE_VERSION }

    public(package) fun assert_valid_package(treasury: &Treasury) {
        treasury.assert_valid_module_version<BucketV2Saving>(package_version());
    }
}
